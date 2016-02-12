#!/usr/bin/env perl
#
#

use strict;
use Redis;
use Storable qw(freeze) ;
use Data::Printer;


my $last = {};
my $stats = {};

my $redis = Redis->new;

while (<>) {

	if(/^(FREE|WRITE|OBJECT)\sobject\s=\s(\d+)/) {
	    if($last->{id} != $2 && $last->{id}) {
            #print "adding ".$last->{id}." ".$last->{sum}." ".freeze($last)." to redis\n";
            $redis->zadd("stats", $last->{sum}, freeze($last));
            print "A scan: \n";
            p $redis->zscan("stats", 0);
            print join ("\t", ($last->{id}, $last->{cmd}, $last->{sum}))."\n";
		    #print "zdb -dddd bioinfo2/backup\@2015-07-27-000000 $2\n";
	        $last->{cmd}=$1;
            $last->{id} =$2;
            $last->{sum} = 0;
	    }
        elsif (!defined($last->{id})) {
            print "setting last\n";
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



