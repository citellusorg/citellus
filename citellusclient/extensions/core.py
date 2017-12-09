#!/usr/bin/env python
# encoding: utf-8
#
# Description: Extension for processing core Citellus plugins
# Author: Pablo Iranzo Gomez (Pablo.Iranzo@gmail.com)

from __future__ import print_function

import os

import citellusclient.shell as citellus

extension = "core"
pluginsdir = os.path.join(citellus.citellusdir, 'plugins', extension)


def init():
    """
    Initializes module
    :return: List of triggers for extension
    """
    triggers = ['core']
    return triggers


def listplugins(options):
    """
    List available plugins
    :param options: argparse options provided
    :return: plugin object generator
    """
    yield citellus.findplugins(folders=[pluginsdir], include=options.include, exclude=options.exclude)


def get_description(plugin):
    """
    Gets description for plugin
    :param plugin: plugin object
    :return: description string for that plugin
    """
    return citellus.regexpfile(filename=plugin['plugin'], regexp='\A# description:')


def run(plugin):  # do not edit this line
    """
    Executes plugin
    :return: returncode, out, err
    """
    return citellus.execonshell(filename=plugin['plugin'])


def help():  # do not edit this line
    """
    Returns help for plugin
    :return: help text
    """

    commandtext = "This extension proceses Citellus core plugins"
    return commandtext
