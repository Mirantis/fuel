#!/usr/bin/env python
# -*- coding: utf-8 -*-

##
## To deploy use
## $ python ./setup.py sdist upload
##
## Your need increase version before it !!!
##

from __future__ import unicode_literals
import setuptools

setuptools.setup(
    setup_requires=[
        'pbr',
        'setuptools'
    ],
    pbr=True
)

# vim: tabstop=4 shiftwidth=4 softtabstop=4
