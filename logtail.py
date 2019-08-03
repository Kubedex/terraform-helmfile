#!/usr/bin/env python
from __future__ import print_function
import subprocess
import sys

logs = subprocess.Popen(['docker','logs', '-f', sys.argv[1]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

while True:
    line = logs.stdout.readline()
    if len(line) > 0:
        print(line)
    if "INFO: cleaning up sensitive and temp files" in line:
        sys.exit(0)
    if "Error:" in line:
        sys.exit(1)
