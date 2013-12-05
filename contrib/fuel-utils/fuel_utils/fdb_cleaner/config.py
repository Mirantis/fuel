# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import eventlet

eventlet.monkey_patch()
import re
import sys
import errno
import logging
from settings import LOG_NAME


class BaseAuthConfig(object):
    """
    read auth config and store it.
    Try be a singletone
    """

    def __init__(self):
        self._configs = {}

    @staticmethod
    def _read_config(cfg_file):
        """
        Read OS auth config file
        cfg_file -- the path to config file
        """
        auth_conf_errors = {
            'OS_TENANT_NAME': 'Missing tenant name.',
            'OS_USERNAME': 'Missing username.',
            'OS_PASSWORD': 'Missing password.',
            'OS_AUTH_URL': 'Missing API url.',
        }
        rv = {}
        stripchars = " \'\""
        LOG = logging.getLogger(LOG_NAME)
        try:
            with open(cfg_file) as f:
                for line in f:
                    rg = re.match(r'\s*export\s+(\w+)\s*=\s*(.*)', line)
                    if rg:
                        rv[rg.group(1).strip(stripchars)] = \
                            rg.group(2).strip(stripchars)
        except IOError:
            LOG.error("Can't open file '{path}'".format(path=cfg_file))
            sys.exit(errno.ENOENT)

        # error detection
        exit_msg = []
        for i, e in auth_conf_errors.iteritems():
            if rv.get(i) is None:
                exit_msg.append(e)
        if len(exit_msg) > 0:
            for msg in exit_msg:
                LOG.error("AUTH-config error: '{msg}'".format(msg=msg))
            sys.exit(errno.EPROTO)
        return rv

    def read(self, cfg_filename='/root/openrc'):
        """
        Read or get from cache OS auth config file

        Args:
            cfg_filename (str) -- the path to config file
        Returns:
            Dict of auth params.
        Raises:
            IOError: if file can't readable or not wound.
        """
        rv = self._configs.get(cfg_filename)
        if rv:
            return rv
        rv = self._read_config(cfg_filename)
        self._configs[cfg_filename] = rv
        return self._configs.get(cfg_filename)


AuthConfig = BaseAuthConfig()

# vim: tabstop=4 shiftwidth=4 softtabstop=4
