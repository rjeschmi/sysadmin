#!/usr/bin/env perl
#
#

my $md5sum_file = shift(@ARGV);

my $md5sum_fh;
open($md5sum_fh, "<", $md5sum_file);
while (<$md5sum_fh>) {
    chomp;
    s/\r$//;
    #print "line: ".$_."\n";
    if( /^([a-f0-9]+)\s+\*{0,1}(.*)$/) {
        my $exists = 0;
        if (-f $2) { $exists = 1; }
        print "[$1] $2 :: $exists \n" if !$exists;
    }

}


