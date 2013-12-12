# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import eventlet

eventlet.monkey_patch()
from keystoneclient.v2_0 import client as ks_client

try:
    from neutronclient.neutron import client as n_client
except ImportError:
    from quantumclient.quantum import client as n_client
from fuel_utils.core.daemonize_green import Daemonize
from fuel_utils.fdb_cleaner.config import AuthConfig
from fuel_utils.fdb_cleaner.settings import API_VER
import sys
import os
import re
import random
import time
import paramiko


class Daemon(Daemonize):
    """
    Main FDB-cleaner daemon class
    """

    def __init__(self, cfg, logger=None, green_pool_size=2000):
        self.options = cfg
        self.auth_config = AuthConfig.read(cfg.get('authconf'))
        self.debug = cfg.get('debug')
        self.loglevel = cfg.get('loglevel')
        self.os_credentials = None
        self.keystone = None
        self.neutron = None
        super(Daemon, self).__init__(
            cfg['pid'], logger, green_pool_size=green_pool_size)

    def _get_keystone(self):
        if not (self.os_credentials is None):
            return self.os_credentials
        ret_count = self.options.get('retries', 50)
        while True:
            if ret_count <= 0:
                self.logger.error(
                    ">>> Keystone error: "
                    "no more retries for connect to keystone server.")
                sys.exit(1)
            try:
                self.keystone = ks_client.Client(
                    username=self.auth_config.get('OS_USERNAME'),
                    password=self.auth_config.get('OS_PASSWORD'),
                    tenant_name=self.auth_config.get('OS_TENANT_NAME'),
                    auth_url=self.auth_config.get('OS_AUTH_URL')
                )
                break
            except Exception as e:
                errmsg = e.message.strip()
                # COMMENT: Very bad idea to think we can
                # catch all known ways here
                if re.search(r"Connection\s+refused$", errmsg, re.I) or \
                    re.search(r"Connection\s+timed\s+out$", errmsg, re.I) or \
                    re.search(r"Service\s+Unavailable$", errmsg, re.I) or \
                    re.search(
                        r"'*NoneType'.*attribute\s+'*__getitem__'*$",
                        errmsg, re.I) or \
                    re.search(
                        r"No\s+route\s+to\s+host$", errmsg, re.I):
                        self.logger.info(
                            ">>> Can't connect to "
                            "{0}, wait for server ready...".format(
                                self.auth_config.get('OS_AUTH_URL')))
                        time.sleep(self.options.sleep)
                # COMMENT: I'm not sure the way how keystone client work's
                # So 'else' branch can't be always a keystone error
                else:
                    self.logger.error(">>> Keystone error:\n"
                                      "{0}".format(e.message))
                    sys.exit(1)
            ret_count -= 1
        self.os_credentials = {
            'net_endpoint': self.keystone.service_catalog.url_for(
                service_type='network',
                endpoint_type=self.options.get('endpoint_type')
            ),
            'nova_endpoint': self.keystone.service_catalog.url_for(
                service_type='compute',
                endpoint_type=self.options.get('endpoint_type')
            ),
            'token': self.keystone.auth_token
        }

    def _get_neutron(self):
        if (self.os_credentials is None) or \
           (self.os_credentials.get('net_endpoint') is None):
            self.logger.error("Neutron: credentials not given.")
            sys.exit(1)
        self.neutron = n_client.Client(
            API_VER,
            endpoint_url=self.os_credentials.get('net_endpoint'),
            token=self.os_credentials.get('token')
        )

    def _get_another_agents_list(self):
        #todo: catch some exceptions for retry
        return self.neutron.list_agents()

    def __run(self):
        time.sleep(60)
        self.remove_pidfile()

    def run(self):
        # get credentials
        self._get_keystone()
        # get neutron interface object
        self._get_neutron()
        # ask neutron-api for list nodes with have ovs-agent
        agents = self._get_another_agents_list()
        if type(agents) != dict or type(agents.get('agents')) != list:
            return None
        nodes = [
            i for i in agents.get('agents')
            if i.get('agent_type') == 'Open vSwitch agent'
            and i.get('alive')
            and i.get('host') != os.getenv('HOSTNAME')
        ]
        # process nodes
        for node in nodes:
            self.logger.debug("+spawning: {0}".format(node.get('host')))
            self.green_pool.spawn_n(self.worker, node)
            self.logger.debug("+spawned: {0}".format(node.get('host')))
        self.green_pool.waitall()
        self.logger.info("*** end of work")
        time.sleep(10)
        self.remove_pidfile()

    def worker(self, node_hash):
        # ssh to node
        self.logger.info(
            " ssh to '{node}:{port}'".format(
                node=node_hash.get('host'),
                port=self.options.get('ssh_port', '22')))
        try:
            ssh = paramiko.SSHClient()
            ssh.load_system_host_keys()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                node_hash.get('host'),
                port=self.options.get('ssh_port') or None,
                username=self.options.get('ssh_username'),
                password=self.options.get('ssh_password') or None,
                timeout=self.options.get('ssh_timeout') or None,
                key_filename=self.options.get('ssh_keyfile') or None,
                #compress=False,
            )
        except paramiko.SSHException as e:
            self.logger.error(
                "Can't connect to '{node}:{port}'\n{error}".format(
                    node=node_hash.get('host'),
                    port=self.options.get('ssh_port', '22'),
                    error=e))
            return None
        except:
            self.logger.error(
                "Can't connect to '{node}:{port}'\nUnrecognized error".format(
                    node=node_hash.get('host'),
                    port=self.options.get('ssh_port', '22')))
            return None
        w = int(random.random() * 120)
        rcommands = [
            "ovs-appctl fdb/flush",
        ]
        for rcmd in rcommands:
            try:
                stdin, stdout, stderr = ssh.exec_command(
                    rcmd,
                    # COMMENT: What about default timeout for a command?
                    # timeout=0.0,
                    # for non-blocking mode (False -- for blocking mode)
                    # get_pty=False
                )
                #for line in stdout:
                #    # pass
                #    self.logger.debug("remote say: '{0}'".format(line.rstrip("\n")))
                # waiting execute command and get return-code.
                rc = stdout.channel.recv_exit_status()
                err_msg = "{node}: '{cmd}', rc={rc}".format(
                    node=node_hash.get('host'),
                    cmd=rcmd,
                    rc=rc
                )
                if rc == 0:
                    self.logger.debug(err_msg)
                else:
                    self.logger.error(err_msg)
            except paramiko.SSHException as e:
                self.logger.error(
                    "{node}: '{cmd}', exception:\n{error}".format(
                        node=node_hash.get('host'),
                        cmd=rcmd,
                        error=e))
            except:
                self.logger.error(
                    "{node}: '{cmd}', exception:\nUnrecognized error".format(
                        node=node_hash.get('host'),
                        cmd=rcmd))
        self.logger.debug(
            "session to '{node}' done.".format(node=node_hash.get('host')))

# vim: tabstop=4 shiftwidth=4 softtabstop=4
