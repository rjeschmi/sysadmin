#!/usr/bin/env python

import re
import os,sys
import signal
import subprocess
import multiprocessing

class KeyboardInterruptError(Exception): pass


def call_hashdeep(args):
    keyfile=args[0]
    base = args[1]
    print "calling hashdeep with keyfile: %s base: %s" % (keyfile, base)
    try: 
        cmd = [
            "hashdeep",
            "-k", keyfile,
            "-l", "-Fm",
            "-a", 
            "-r", base
        ]
        print "calling cmd %s " % cmd
        proc =subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        while proc.poll() is None:
            print proc.stdout.readline()

        print "returned: %s " % proc.returncode


    except KeyboardInterrupt:
        proc.terminate()
        raise KeyboardInterruptError()

    except Exception:
        print "caught exception"

if __name__ == '__main__':
    dirs = []
    for file in sys.argv[1:]:
        print "file: %s" % file
        matches = re.match(r'([^.]*)(?:\.solexa)?\.hashdeep', file)
        if (os.path.isdir(matches.groups()[0])):
            dirs.append([file, matches.groups()[0]])
            print "Found dir: %s " % matches.groups()[0]

    workers = multiprocessing.Pool(1)
    print "calling with dirs: %s" % dirs
    try:
        workers.map(call_hashdeep, dirs)
    except KeyboardInterrupt:
        workers.terminate()
        workers.join()


