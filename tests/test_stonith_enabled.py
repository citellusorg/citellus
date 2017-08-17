#!/usr/bin/env python
# encoding: utf-8
#
# Description: This UT run scripts to validate the rules/tests created for citellus for $NAME_OF_TEST
#
# Copyright (C) 2017  Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# TODO(Update name of script to test)
# cat test_template.py|sed "s/NAME_OF_TEST/stonith_enabled/g" > test_NAME_OF_TEST.py
#

NAME = 'stonith_enabled'


import os
import subprocess
from unittest import TestCase
import tempfile
import shutil

from citellus import citellus

testplugins = os.path.join(citellus.citellusdir, 'testplugins')
plugins = os.path.join(citellus.citellusdir, 'plugins')

# Setup commands and expected return codes
rcs = {"pass": citellus.RC_OKAY,
       "fail": citellus.RC_FAILED,
       "skipped": citellus.RC_SKIPPED}


class CitellusTest(TestCase):
    def test_stonith_enabled_pass(self):
        folder = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'UT-tests')
        uttest = citellus.findplugins(folders=[folder], include=[NAME])[0]

        # testtype will be 'pass', 'fail', 'skipped'
        testtype = 'pass'
        # Our name
        us = os.path.basename(uttest)

        # We're iterating against the different UT tests defined in UT-tests folder
        tmpdir = tempfile.mkdtemp(prefix='citellus-tmp')

        # Setup test for 'pass'
        subprocess.call([uttest, uttest, testtype, tmpdir])

        # Find plugins that match
        citplugs = citellus.findplugins(folders=[plugins], include=[us])

        # Run test against it
        res = citellus.docitellus(path=tmpdir, plugins=citplugs)

        # Get Return code
        rc = res[0]['result']['rc']

        # Remove tmp folder
        shutil.rmtree(tmpdir)

        # Check if it passed
        expected = rcs[testtype]
        assert rc == expected

    def test_stonith_enabled_fail(self):
        folder = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'UT-tests')
        uttest = citellus.findplugins(folders=[folder], include=[NAME])[0]

        # testtype will be 'pass', 'fail', 'skipped'
        testtype = 'fail'
        # Our name
        us = os.path.basename(uttest)

        # We're iterating against the different UT tests defined in UT-tests folder
        tmpdir = tempfile.mkdtemp(prefix='citellus-tmp')

        # Setup test for 'pass'
        subprocess.call([uttest, uttest, testtype, tmpdir])

        # Find plugins that match
        citplugs = citellus.findplugins(folders=[plugins], include=[us])

        # Run test against it
        res = citellus.docitellus(path=tmpdir, plugins=citplugs)

        # Get Return code
        rc = res[0]['result']['rc']

        # Remove tmp folder
        shutil.rmtree(tmpdir)

        # Check if it passed
        expected = rcs[testtype]
        assert rc == expected


    def test_stonith_enabled_skip(self):
        folder = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'UT-tests')
        uttest = citellus.findplugins(folders=[folder], include=[NAME])[0]

        # testtype will be 'pass', 'fail', 'skipped'
        testtype = 'skipped'
        # Our name
        us = os.path.basename(uttest)

        # We're iterating against the different UT tests defined in UT-tests folder
        tmpdir = tempfile.mkdtemp(prefix='citellus-tmp')

        # Setup test for 'pass'
        subprocess.call([uttest, uttest, testtype, tmpdir])

        # Find plugins that match
        citplugs = citellus.findplugins(folders=[plugins], include=[us])

        # Run test against it
        res = citellus.docitellus(path=tmpdir, plugins=citplugs)

        # Get Return code
        rc = res[0]['result']['rc']

        # Remove tmp folder
        shutil.rmtree(tmpdir)

        # Check if it passed
        expected = rcs[testtype]
        assert rc == expected
