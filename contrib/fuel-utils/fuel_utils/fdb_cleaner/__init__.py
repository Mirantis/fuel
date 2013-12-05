# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import eventlet

eventlet.monkey_patch()
import os
import sys
import argparse
import logging.handlers
from fuel_utils.fdb_cleaner.settings import LOG_NAME
from fuel_utils.fdb_cleaner.daemon import Daemon


def main():
    parser = argparse.ArgumentParser(
        description='Quantum network node cleaning tool.')
    parser.add_argument(
        "-c", "--auth-config", dest="authconf", default="/root/openrc",
        help="Authenticating config FILE", metavar="FILE")
    parser.add_argument(
        "-l", "--log", dest="log", action="store", default=None,
        help="log file or logging.conf location")
    parser.add_argument(
        "-p", "--pid", dest="pid", action="store",
        help="PID file", default="/tmp/{0}.pid".format(LOG_NAME))
    parser.add_argument(
        "--retries", dest="retries", type=int, default=50,
        help="try NN retries for OpenStack API call", metavar="NN")
    parser.add_argument(
        "--sleep", dest="sleep", type=int, default=2,
        help="sleep seconds between retries", metavar="SEC")
    parser.add_argument(
        "--endpoint-type", dest="endpoint_type", action="store",
        default="adminURL",
        help="Endpoint type ('admin' or 'public') for use.", metavar="TYPE")
    parser.add_argument(
        "--ssh-username", dest="ssh_username", action="store", default='root',
        help="Username for ssh connect", metavar="UNAME")
    parser.add_argument(
        "--ssh-password", dest="ssh_password", action="store", default=None,
        help="Password for ssh connect", metavar="PASSWD")
    parser.add_argument(
        "--ssh-keyfile", dest="ssh_keyfile", action="append",
        help="SSH key file", metavar="FILE")
    parser.add_argument(
        "--ssh-port", dest="ssh_port", type=int, default=22,
        help="Port for SSH connection", metavar="NN")
    parser.add_argument(
        "--ssh-timeout", dest="ssh_timeout", type=int, default=120,
        help="Connection timeout for SSH session", metavar="SEC")
    parser.add_argument(
        "--debug", dest="debug", action="store_true", default=False,
        help="debug")
    args = parser.parse_args()

    # setup logging
    import logging  # must be here due Py.logging design

    _log_level = logging.DEBUG if args.debug else logging.INFO
    LOG = logging.getLogger(LOG_NAME)   # do not move to UP of file
    if not args.log:
        # log config or file not given -- log to console
        _log_handler = logging.StreamHandler(sys.stdout)
        _log_handler.setFormatter(logging.Formatter(
            "%(asctime)s - %(levelname)s - %(message)s"))
        LOG.addHandler(_log_handler)
        LOG.setLevel(_log_level)
    elif args.log.split(os.sep)[-1] == 'logging.conf':
        # setup logging by external file
        import logging.config

        logging.config.fileConfig(args.log)
    else:
        # log to given file
        _log_handler = logging.handlers.WatchedFileHandler(args.log)
        _log_handler.setFormatter(logging.Formatter(
            "%(asctime)s - %(levelname)s - %(message)s"))
        LOG.addHandler(_log_handler)
        LOG.setLevel(_log_level)

    LOG.info("Try to start daemon: {0}".format(' '.join(sys.argv)))
    cfg = vars(args)
    cfg['loglevel'] = _log_level
    fdb_daemon = Daemon(cfg, logger=LOG)
    fdb_daemon.start()
    sys.exit(0)


if __name__ == '__main__':
    main()

# vim: tabstop=4 shiftwidth=4 softtabstop=4
