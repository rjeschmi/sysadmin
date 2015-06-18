#!/usr/bin/env perl 
#
#


use strict;
use warnings;
my $md5sum = shift;
my $md5sum_fh;
open($md5sum_fh, "<", $md5sum);
while (<$md5sum_fh>) {
    chomp;
    s/\r$//;
    if( /^([a-f0-9]+)\s+\*{0,1}(.*)$/) {
    if ($hd->{$1}) {
           print "[$1] $2 :: ".$hd->{$1} ."\n";
           delete $hd->{$1};
    }
    else {
           print "[$1] $2 :: ERROR\n";
        }
    }


}
