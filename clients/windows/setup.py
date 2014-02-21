#!/usr/bin/env python2
# -*- coding: utf-8 -*-

#
# to build self-contained .exe with py2exe
# call me like this:
# python setup.py py2exe
#

from distutils.core import setup
import py2exe
import sys

opts = {
    'py2exe': {
        'compressed': 1,
        'optimize': 1,
        'bundle_files': 1,
        'dll_excludes': [
            "IPHLPAPI.DLL",
            "NSI.dll",
            "WINNSI.DLL",
            "WTSAPI32.dll",
            "MSWSOCK.DLL",
            "POWRPROF.DLL",
            "PSAPI.DLL"
        ],
        'includes': [
            'psutil',
            '_psutil_mswindows'
        ]
    }
}

setup(console=["client.py"], options=opts, zipfile=None)