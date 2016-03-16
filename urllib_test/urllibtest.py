#!/usr/bin/env python

import os
import sys
import urllib2
import socket 
def write_file(path, txt, append=False, ):
    """Write given contents to file at given path (overwrites current file contents!)."""

    # note: we can't use try-except-finally, because Python 2.4 doesn't support it as a single block
    try:
        with open(path, 'a' if append else 'w') as handle:
            handle.write(txt)
    except IOError, err:
        raise EasyBuildError("Failed to write to %s: %s", path, err)

try:
    url_fd = urllib2.urlopen('http://download.sourceforge.net/boost/boost_1_60_0.tar.gz',timeout=60)
    print "got size: %s " % url_fd.headers['content-length']
    print "got response code: %s "  % url_fd.getcode()
    write_file("test.file", url_fd.read())
    if os.path.getsize("test.file") < url_fd.headers['content-length']:
        raise Exception("wtf, we aren't done!")
    print "got response code: %s "  % url_fd.getcode()

except urllib2.HTTPError, e:
    print "caught http error"

except urllib2.URLError, e:
    print "caught url error"

except socket.timeout as e:
    print "caught socket timeout"

except Exception, err:
    print "caught exception %s " % err




