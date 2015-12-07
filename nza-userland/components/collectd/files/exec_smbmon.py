#!/usr/bin/python

"""
exec_smbmon.py

collectd EXEC script that monitors SMB IO performance.

Copyright (c) 2014  Nexenta Systems
William Kettler <william.kettler@nexenta.com>
"""

import os
import sys
import socket
import subprocess

# Get the system hostname
if 'COLLECTD_HOSTNAME' in os.environ:
    hostname = os.environ['COLLECTD_HOSTNAME']
else:
    hostname = socket.gethostname()

# Define the polling interval
if 'COLLECTD_INTERVAL' in os.environ:
    interval = int(float(os.environ['COLLECTD_INTERVAL']))
else:
    interval = 10

# Start subprocess
producer = subprocess.Popen(["/usr/local/collectd/bin/smbmon.d",
                            str(interval)], stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)

# Define the output fields from nfsmon.d
keys = ["r_latency", "r_bs", "r_bytes", "r_count", "w_latency", "w_bs",
        "w_bytes", "w_count"]

while True:
    # Read the next line from STDOUT
    line = producer.stdout.readline()

    # Check subprocess status after reading stdout to prevent race condition
    # where process dies after checking status but before reading stdout
    if producer.poll() is not None:
        sys.stderr.write('ERROR subprocess has exited with retcode %s.\n'
                         % producer.retcode)
        sys.stderr.write(producer.stderr.read())
        sys.exit(1)

    # Parse the stats
    values = [int(x.strip()) for x in line.split(',')]
    stats = dict(zip(keys, values))

    # Calculate read/write throughput in KB/s
    stats['r_tput'] = stats['r_bytes'] / interval / 1024
    stats['w_tput'] = stats['w_bytes'] / interval / 1024

    # Calculate read/write IOPS
    stats['r_iops'] = stats['r_count'] / interval
    stats['w_iops'] = stats['w_count'] / interval

    # Print value to STDOUT
    for key, value in stats.iteritems():
        sys.stdout.write('PUTVAL "%s/smbmon/gauge-%s" interval=%s '
                         'N:%s\n' % (hostname, key, interval, value))
    sys.stdout.flush()
