#!/usr/bin/env python
# encoding: utf-8
#
# Description:
# Copyright (C) 2017 Robin Černín (rcernin@redhat.com)
#                    Lars Kellogg-Stedman <lars@oddbit.com>
#                    Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)
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

import argparse
import gettext
import logging
import os
import subprocess

logger = logging.getLogger("citellus")
logger.setLevel(logging.DEBUG)

citellusdir = os.path.abspath(os.path.dirname(__file__))
localedir = os.path.join(citellusdir, 'locale')

trad = gettext.translation('citellus', localedir, fallback=True)
_ = trad.ugettext


# Implement switch from http://code.activestate.com/recipes/410692/
class Switch(object):
    """
    Defines a class that can be used easily as traditional switch commands
    """

    def __init__(self, value):
        self.value = value
        self.fall = False

    def __iter__(self):
        """Return the match method once, then stop"""
        yield self.match
        raise StopIteration

    def match(self, *args):
        """Indicate whether or not to enter a case suite"""
        if self.fall or not args:
            return True
        elif self.value in args:  # changed for v1.5, see below
            self.fall = True
            return True
        else:
            return False


class bcolors:
    black = '\033[30m'
    red = '\033[31m'
    green = '\033[32m'
    orange = '\033[33m'
    blue = '\033[34m'
    purple = '\033[35m'
    cyan = '\033[36m'
    lightgrey = '\033[37m'
    darkgrey = '\033[90m'
    lightred = '\033[91m'
    lightgreen = '\033[92m'
    yellow = '\033[93m'
    lightblue = '\033[94m'
    pink = '\033[95m'
    lightcyan = '\033[96m'
    end = '\033[0m'


def show_logo():
    logo = "_________ .__  __         .__  .__                ", \
           "\_   ___ \|__|/  |_  ____ |  | |  |  __ __  ______", \
           "/    \  \/|  \   __\/ __ \|  | |  | |  |  \/  ___/", \
           "\     \___|  ||  | \  ___/|  |_|  |_|  |  /\___ \ ", \
           " \______  /__||__|  \___  >____/____/____//____  >", \
           "        \/              \/                     \/ "
    for line in logo:
        print line


def findplugins(folder):
    """
    Finds plugins in path and returns array of them
    :param folder: Folder to use as source for plugin search
    :return:
    """
    plugins = []
    for root, dir, files in os.walk(folder):
        for file in files:
            script = os.path.join(folder, file)
            if os.access(script, os.X_OK):
                plugins.append(script)
        for subfolder in dir:
            plugins.extend(findplugins(os.path.join(folder, subfolder)))
    return plugins


def runplugin(plugin):
    """
    Runs provided plugin and outputs message
    :param plugin:  plugin to execute
    :return: result, out, err
    """
    try:
        p = subprocess.Popen(plugin, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        returncode = p.returncode
    except:
        returncode = 3
        out = ""
        err = ""

    for case in Switch(returncode):
        if case(0):
            # OK
            text = bcolors.green + _("okay") + bcolors.end
            break
        if case(1):
            # FAILED
            text = bcolors.red + _("failed") + bcolors.end
            break
        if case(2):
            # SKIPPED
            text = bcolors.orange + _("skipped") + bcolors.end
            break
        if case():
            # UNEXPECTED
            text = bcolors.red + _("unexpected result") + bcolors.end
            break

    print "# %s: %s" % (plugin, text)

    if returncode != 0 and returncode != 2:
        if err != "":
            print err
        if out != "":
            print out

    return returncode, out, err


def main():

    description = _('Citellus allows to analyze a directory against common set of tests, useful for finding common configuration errors')

    # Option parsing
    p = argparse.ArgumentParser("citellus.py [arguments]", description=description)
    p.add_argument("-l", "--live", dest="live", help=_("Work on a live system instead of a snapshot"), default=False,
                   action='store_true')
    p.add_argument("-v", "--verbose", dest="verbose", help=_("Execute in verbose mode"), default=False,
                   action='store_true')

    options, unknown = p.parse_known_args()

    # Enable LIVE mode if parameter passed
    if options.live:
        CITELLUS_LIVE = 1
    else:
        CITELLUS_LIVE = 0

    CITELLUS_PLUGINS = False
    CITELLUS_ROOT = False

    plugin_path = os.path.join(citellusdir, 'plugins')

    if unknown:
        # We've additional arguments passed so it must be the folder to use or plugins
        if len(unknown) == 1:
            CITELLUS_ROOT = unknown[0]
        elif len(unknown) == 2:
            CITELLUS_PLUGINS = unknown[1]
    else:
        CITELLUS_ROOT = ""

    # Save environment variables for plugins executed
    os.environ['CITELLUS_ROOT'] = "%s" % CITELLUS_ROOT
    os.environ['CITELLUS_LIVE'] = "%s" % CITELLUS_LIVE

    if options.verbose:
        # Enable verbose on scripts
        os.environ['CITELLUS_DEBUG'] = "%s" % options.verbose

    # Find plugins available
    if CITELLUS_PLUGINS:
        plugin_path = CITELLUS_PLUGINS

    plugins = findplugins(plugin_path)

    show_logo()
    print _("found %s tests at %s") % (len(plugins), plugin_path)
    if CITELLUS_LIVE == 1:
        print _("mode: live")
    else:
        print _("mode: fs snapshot %s" % CITELLUS_ROOT)

    # Do the actual execution of plugins
    for plugin in plugins:
        # prepare functions for plugin
        returncode, out, err = runplugin(plugin)


if __name__ == "__main__":
    main()
