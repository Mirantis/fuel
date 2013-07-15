#!/usr/bin/env python
import re
import time
import os
import sys
import argparse
import logging
import logging.handlers
import subprocess
from quantumclient.quantum import client as q_client
from keystoneclient.v2_0 import client as ks_client

LOG_NAME='q-agent-cleanup'

API_VER = '2.0'



def get_authconfig(cfg_file):
    # Read OS auth config file
    rv = {}
    stripchars=" \'\""
    with open(cfg_file) as f:
        for line in f:
            rg = re.match(r'\s*export\s+(\w+)\s*=\s*(.*)',line)
            if rg :
                #print("[{}]-[{}]".format(rg.group(1),rg.group(2).strip()))
                rv[rg.group(1).strip(stripchars)]=rg.group(2).strip(stripchars)
    return rv


class QuantumCleaner(object):
    PORT_NAME_PREFIXES_BY_DEV_OWNER = {
        'network:dhcp':             'tap',
        'network:router_gateway':   'qg-',
        'network:router_interface': 'qr-',
    }    
    PORT_NAME_PREFIXES = {
        'dhcp': PORT_NAME_PREFIXES_BY_DEV_OWNER['network:dhcp'],
        'l3': [
            PORT_NAME_PREFIXES_BY_DEV_OWNER['network:router_gateway'],
            PORT_NAME_PREFIXES_BY_DEV_OWNER['network:router_interface']
        ]
    }
    PORT_OWNER_PREFIXES = {
        'dhcp': ['network:dhcp'],
        'l3': ['network:router_gateway', 'network:router_interface']
    }
    NS_NAME_PREFIXES = {
        'dhcp': 'qdhcp',
        'l3':   'qrouter',
    }

    CMD__remove_ovs_port = ['ovs-vsctl', '--', '--if-exists', 'del-port']

    def __init__(self, openrc, options, log=None):
        self.log = log
        self.auth_config = openrc
        self.options = options
        self.debug = options.get('debug')
        ret_count = self.options.get('retries',1)
        while True:
            if ret_count <= 0 :
                print(">>> Keystone error: no more retries for connect to keystone server.")
                sys.exit(1)
            try:
                self.keystone = ks_client.Client(
                    username=openrc['OS_USERNAME'],
                    password=openrc['OS_PASSWORD'],
                    tenant_name=openrc['OS_TENANT_NAME'],
                    auth_url=openrc['OS_AUTH_URL'],
                )
                break
            except Exception as e:
                errmsg = e.message.strip()
                if re.search(r"Connection\s+refused$", errmsg, re.I) or \
                   re.search(r"Connection\s+timed\s+out$", errmsg, re.I) or\
                   re.search(r"Service\s+Unavailable$", errmsg, re.I) or\
                   re.search(r"'*NoneType'*\s+object\s+has\s+no\s+attribute\s+'*__getitem__'*$", errmsg, re.I) or \
                   re.search(r"No\s+route\s+to\s+host$", errmsg, re.I):
                      print(">>> Can't connect to {0}, wait for server ready...".format(self.auth_config['OS_AUTH_URL']))
                      time.sleep(self.options.sleep)
                else:
                    print(">>> Keystone error:\n{0}".format(e.message))
                    raise e
            ret_count -= 1
        self.token = self.keystone.auth_token
        self.client = q_client.Client(
            API_VER,
            endpoint_url=self.keystone.service_catalog.url_for(service_type='network'),
            token=self.token,
        )

    def _get_ports(self):
        self.log.debug("__get_ports: start.")
        ret_count = self.options.get('retries')
        while True:
            if ret_count <= 0 :
                self.log.error("Q-server error: no more retries for connect to keystone server.")
                sys.exit(1)
            try:
                rv = self.client.list_ports()['ports']
                break
            except Exception as e:
                errmsg = e.message.strip()
                if re.search(r"Connection\s+refused", errmsg, re.I) or\
                   re.search(r"Connection\s+timed\s+out", errmsg, re.I) or\
                   re.search(r"503\s+Service\s+Unavailable", errmsg, re.I) or\
                   re.search(r"No\s+route\s+to\s+host", errmsg, re.I):
                      self.log.info("Can't connect to {0}, wait for server ready...".format(self.keystone.service_catalog.url_for(service_type='network')))
                      time.sleep(self.sleep)
                else:
                    self.log.error("Quantum error:\n{0}".format(e.message))
                    raise e
            ret_count -= 1
        self.log.debug("__get_ports: rv='{0}'".format(rv))
        self.log.debug("__get_ports: end.")
        return rv

    def _get_ports_by_agent(self, agent, activeonly=False):
        self.log.debug("__get_ports_by_agent: start, agent='{0}', activeonly='{1}'".format(agent, activeonly))
        rv = []
        ports = self._get_ports()
        if activeonly:
            tmp = []
            for i in ports:
                if i['status'] == 'ACTIVE':
                    tmp.append(i)
                ports = tmp
        for i in ports:
            if i['device_owner'] in self.PORT_OWNER_PREFIXES.get(agent):
                rv.append(i)
        self.log.debug("__get_ports_by_agent: end, rv='{0}'".format(rv))
        return rv

    def _get_portnames_and_IPs_for_agent(self, agent, port_id_part_len=11):
        self.log.debug("_get_portnames_and_IPs_for_agent: start, agent='{0}'".format(agent))
        port_name_prefix = self.PORT_NAME_PREFIXES.get(agent)
        if port_name_prefix is None:
            self.log.debug("port_name_prefix is None")
            return []
        rv = []
        for i in self._get_ports_by_agent(agent, activeonly=self.options.get('activeonly')):
            # _rr = "{0}{1} {2}".format(self.PORT_NAME_PREFIXES_BY_DEV_OWNER[i['device_owner']], i['id'][:port_id_part_len], i['fixed_ips'][0]['ip_address'])
            _rr = ("{0}{1}".format(self.PORT_NAME_PREFIXES_BY_DEV_OWNER[i['device_owner']], i['id'][:port_id_part_len]), i['fixed_ips'][0]['ip_address'])
            #self.log.debug(_rr)
            rv.append(_rr)
        self.log.debug("_get_portnames_and_IPs_for_agent: end, rv='{0}'".format(rv))
        return rv

    def _cleanup_ports(self, agent, activeonly=False):
        self.log.debug("_cleanup_ports: start.")
        rv = False
        port_ip_list = self._get_portnames_and_IPs_for_agent(agent)
        # Cleanup ports
        port_list = [x[0] for x in port_ip_list]
        self.log.debug("_cleanup_ports: ports {0} will be cleaned.".format(port_list))
        for port in port_list:
            cmd = []
            cmd.extend(self.CMD__remove_ovs_port)
            cmd.append(port)
            if self.options.get('noop'):
                self.log.info("NOOP-execution:{0}".format(cmd))
            else:
                process = subprocess.Popen(
                    cmd,
                    shell=False,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE
                )
                rc = process.wait()
                if rc != 0:
                    self.log.error("ERROR (rc={0}) while execution {1}".format(rc,cmd))            
        self.log.debug("_cleanup_ports: end.")
        return rv



    def _cleanup_ns(self, agent):
        self.log.debug("_cleanup_ns -- not implemented")
        pass

    def _cleanup_agent(self, agent):
        self.log.debug("_cleanup_agent -- not implemented")
        
    def do(self, agent):
        if self.options.get('cleanup-ports'):
            self._cleanup_ports(agent)
        if self.options.get('cleanup-ns'):
            self._cleanup_ns(agent)
        if self.options.get('remove-agent'):
            self._cleanup_agent(agent)



if __name__ == '__main__':
    # parser = optparse.OptionParser()
    parser = argparse.ArgumentParser(description='Quantum network node cleaning tool.')
    parser.add_argument("-c", "--auth-config", dest="authconf", default="/root/openrc",
                      help="Authenticating config FILE", metavar="FILE")
    parser.add_argument("--retries", dest="retries", type=int, default=50,
                      help="try NN retries for get keystone token", metavar="NN")
    parser.add_argument("-a", "--agent", dest="agent", action="append",
                      help="specyfy agents for cleaning", required=True)
    parser.add_argument("--cleanup-ports", dest="cleanup-ports", action="store_true", default=False,
                      help="cleanup ports for given agents")
    parser.add_argument("--activeonly", dest="activeonly", action="store_true", default=False,
                      help="cleanup only active ports")
    parser.add_argument("--cleanup-ns", dest="cleanup-ns", action="store_true", default=False,
                      help="cleanup namespaces for given agents")
    parser.add_argument("--remove-agent", dest="remove-agent", action="store_true", default=False,
                      help="cleanup namespaces for given agents")
    parser.add_argument("--external-bridge", dest="external-bridge", default="br-ex",
                      help="external bridge name", metavar="IFACE")
    parser.add_argument("--integration-bridge", dest="integration-bridge", default="br-int",
                      help="integration bridge name", metavar="IFACE")
    parser.add_argument("-l", "--log", dest="log", action="store",
                      help="log file or logging.conf location")
    parser.add_argument("--noop", dest="noop", action="store_true", default=False,
                      help="do not execute, print to log instead")
    parser.add_argument("--debug", dest="debug", action="store_true", default=False,
                      help="debug")

    # (options, args) = parser.parse_args()
    args = parser.parse_args()
    # if len(args) != 1:
    #     parser.error("incorrect number of arguments")
    #     parser.print_help()    args = parser.parse_args()

    #setup logging
    if args.debug:
        _log_level = logging.DEBUG
    else:
        _log_level = logging.INFO
    if not args.log:
        # log config or file not given -- log to console
        LOG = logging.getLogger(LOG_NAME)   # do not move to UP of file
        _log_handler = logging.StreamHandler(sys.stdout)
        _log_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
        LOG.addHandler(_log_handler)
        LOG.setLevel(_log_level)
    elif args.log.split(os.sep)[-1] == 'logging.conf':
        # setup logging by external file
        import logging.config
        logging.config.fileConfig(args.log)
        LOG = logging.getLogger(LOG_NAME)   # do not move to UP of file
    else:
        # log to given file
        LOG = logging.getLogger(LOG_NAME)   # do not move to UP of file
        LOG.addHandler(logging.handlers.WatchedFileHandler(args.log))
        LOG.setLevel(_log_level)

    LOG.debug("Started")
    cleaner = QuantumCleaner(get_authconfig(args.authconf), options=vars(args), log=LOG)
    for i in args.agent:
        cleaner.do(i)
    LOG.debug("End.")
#
###