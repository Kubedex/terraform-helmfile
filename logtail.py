#!/usr/bin/env python
from __future__ import print_function
import subprocess
import sys
import re

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

for logline in execute(['docker','logs', '-f', sys.argv[1]]):
    print(logline, end="")

inspect_command = ["docker", "inspect", sys.argv[1], "--format='{{.State.ExitCode}}'"]
output, error = subprocess.Popen(inspect_command, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
status = int(re.search(r'\d+', output).group())
sys.exit(status)
