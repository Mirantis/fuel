# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import eventlet

eventlet.monkey_patch()
import os
import sys
import errno
import signal
import logging


RunningGreenDaemons = set()


class StreamToLogger(object):
    """
    Fake file-like stream object that redirects writes to a logger instance.
    """

    def __init__(self, logger, log_level=logging.INFO):
        self.logger = logger
        self.log_level = log_level
        self.linebuf = ''

    def write(self, buf):
        for line in buf.rstrip().splitlines():
            self.logger.log(self.log_level, line.rstrip())


def sigterm_handler(signum, frame):
    """
    Call actions will be done after SIGTERM.
    """
    for daemon in RunningGreenDaemons:
        daemon.sigterm()
    sys.exit(0)


def sighup_handler(signum, frame):
    """
    Call actions will be done after SIGHUP.
    """
    for daemon in RunningGreenDaemons:
        daemon.sighup()


class Daemonize(object):
    """ Daemonize object
    Object constructor expects three arguments:
    - app: contains the application name which will be sent to logger.
    - pid: path to the pidfile.
    """

    def __init__(self, pidfile, logger=None, green_pool_size=1024):
        self.pidfile = pidfile
        self.debug = getattr(self, 'debug', False)
        # Initialize logging.
        self.logger = logger or logging.getLogger(__package__)
        if self.debug:
            self.loglevel = logging.DEBUG
        elif hasattr(self, 'loglevel'):
            pass
        else:
            self.loglevel = logging.ERROR
        self.logger.setLevel(self.loglevel)
        # Display log messages only on defined handlers.
        self.logger.propagate = False
        ## It will work on OS X and Linux. No FreeBSD support, guys,
        ## I don't want to import re here
        ## to parse your peculiar platform string.
        #if sys.platform == "darwin":
        #    syslog_address = "/var/run/syslog"
        #else:
        #    syslog_address = "/dev/log"
        # Try to mimic to normal syslog messages.
        self.green_pool = eventlet.greenpool.GreenPool(size=green_pool_size)

    def run(self):
        """
        Method representing the thread’s activity.
        You may override this method in a subclass.
        """
        import time

        time.sleep(25)
        self.logger.warn("green-daemon body. You must redefine run() method ")

    def sighup(self):
        """
        Method, that will be call while SIGHUP received
        """
        self.logger.warn("Caught signal HUP. Reloading.")

    def sigterm(self):
        """
        Method, that will be call while SIGTERM received
        """
        self.logger.warn("Caught signal TERM. Stopping daemon.")
        self.remove_pidfile()

    def create_pidfile(self, recurse=10):
        """
        Create a locked PID-file so that only one
        instance of this daemon is running at any time.
        """
        try:
            fd = os.open(self.pidfile, os.O_WRONLY | os.O_CREAT | os.O_EXCL)
        except OSError as e:
            self.logger.debug("errno='{0}'".format(e.errno))
            if e.errno in [errno.EACCES, errno.EAGAIN, errno.EEXIST]:
                self.logger.warn(
                    "Can't create PID-file. "
                    "Pidfile '{file}' already exists.".format(
                        file=self.pidfile))
                #find process with PID of it file
                try:
                    with open(self.pidfile, 'r') as f:
                        pid = f.readline()
                        try:
                            pid = int(pid)
                        except ValueError:
                            pid = 0
                        if pid > 0:
                            try:
                                os.kill(pid, 0)
                                self.logger.error(
                                    "Process with PID "
                                    "{0} found, exiting...".format(pid)
                                )
                                sys.exit(2)
                            except OSError as e:
                                if e.errno == errno.ESRCH and recurse > 0:
                                    self.logger.debug(
                                        "Found PID-file, but process with "
                                        "PID={0} not found".format(pid)
                                    )
                                    os.unlink(self.pidfile)
                                    return self.create_pidfile(
                                        recurse=recurse - 1)
                                elif recurse <= 0:
                                    self.logger.error(
                                        "Can't start daemon, "
                                        "due can't remove existing "
                                        "PID-file '{0}' from another.".format(
                                            self.pidfile)
                                    )
                                    sys.exit(2)
                                else:
                                    self.logger.error(
                                        "Process with PID "
                                        "{0} found, exiting...".format(pid)
                                    )
                                    sys.exit(2)
                        else:
                            self.logger.debug(
                                "Found PID-file, that contains no PID.")
                            os.unlink(self.pidfile)
                            return self.create_pidfile(recurse=recurse - 1)
                except IOError as e:
                    self.logger.error(
                        "Can't read PID from file "
                        "'{file}'\n{err}".format(file=self.pidfile, err=e))
                    sys.exit(2)
            else:
                self.logger.error("Can't create PID-file.\n{0}".format(e))
            sys.exit(1)
        pid = os.getpid()
        os.write(fd, "{pid}".format(pid=pid))
        os.fsync(fd)
        self.pidfile_fd = fd
        return pid

    def remove_pidfile(self):
        try:
            os.close(self.pidfile_fd)
        except OSError as e:
            self.logger.debug("errno='{0}'".format(e.errno))
            pass
        try:
            os.unlink(self.pidfile)
        except OSError as e:
            self.logger.debug("errno='{0}'".format(e.errno))
            if e.errno != errno.ENOENT:
                self.logger.error(e)

    def start(self):
        """ start method
        Main daemonization process.
        """
        RunningGreenDaemons.add(self)

        try:
            if os.fork() > 0:
                sys.exit(0)     # kill off parent
        except OSError as e:
            self.logger.error(
                "fork #1 failed: "
                "{errno} {errmsg}".format(
                    errno=e.errno, errmsg=e.strerror))
            sys.exit(1)
        self.logger.debug("fork #1 successful.")
        os.setsid()
        os.chdir('/')
        os.umask(0o022)

        # Second fork
        try:
            if os.fork() > 0:
                sys.exit(0)
        except OSError as e:
            self.logger.error(
                "fork #2 failed: "
                "{errno} {errmsg}".format(
                    errno=e.errno, errmsg=e.strerror))
            sys.exit(1)
        self.logger.debug("fork #2 succeful.")

        devnull = os.devnull if hasattr(os, "devnull") else "/dev/null"
        si = os.open(devnull, os.O_RDWR)
        os.dup2(si, sys.stdin.fileno())
        sys.stdout = StreamToLogger(self.logger, logging.INFO)
        sys.stderr = StreamToLogger(self.logger, logging.ERROR)

        # Set custom action on SIGTERM.
        signal.signal(signal.SIGTERM, sigterm_handler)
        signal.signal(signal.SIGHUP, sighup_handler)

        pid = self.create_pidfile()
        self.logger.info("Daemonized successfully, PID={pid}".format(pid=pid))

        self.run()

# vim: tabstop=4 shiftwidth=4 softtabstop=4
