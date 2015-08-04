#!/usr/bin/env perl
#
#

use strict;
my $last = {};

while (<>) {

	if(/^(FREE|WRITE|OBJECT)\sobject\s=\s(\d+)/) {
	    if($last->{id} != $2) {
            print join ("\t", ($last->{id}, $last->{cmd}, $last->{sum}))."\n";
		    print "zdb -dddd bioinfo2/backup\@2015-07-27-000000 $2\n";
	        $last->{cmd}=$1;
            $last->{id} =$2;
            $last->{sum} = 0;
	    }

	}
    elsif(/^offset = (\d+) length = (\d+)/ ) {
        $last->{sum} += $2;
    }
	else {
		print "NOTFOUND: ".$_."\n";
	}

}
