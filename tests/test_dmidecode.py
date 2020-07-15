#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2019, 2020 Pablo Iranzo Gómez <Pablo.Iranzo@gmail.com>

from citellusclient.tools.dmidecode import profile
from citellusclient.tools.dmidecode import parse_dmi
from citellusclient.tools.dmidecode import _show
from citellusclient.tools.dmidecode import _parse_handle_section
from citellusclient.tools.dmidecode import _get_output
import os
from unittest import TestCase
import sys

sys.path.append(os.path.abspath(os.path.dirname(__file__) + "/" + "../"))


class CitellusTest(TestCase):
    def test_dmidecode(self):
        with open("tests/other/dmidecode", "r") as f:
            content = f.read()
            output = parse_dmi(content)
            assert output != "1"