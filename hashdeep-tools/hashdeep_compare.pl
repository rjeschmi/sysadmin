#!/usr/bin/env perl

#
# Compare two hash files 
# <hashdeep> <md5sum>
#

use Data::Printer;

my $hashdeep_file = shift(@ARGV);

my $md5sum = shift(@ARGV);

my $hashdeep_fh;

open ($hashdeep_fh, "<", $hashdeep_file);

my $hd = {};

my $depth=1;
while (<$hashdeep_fh>) {
    chomp;
    if ( /(^%|^#)/ ) { next; };
    my @line = split (/,/);
    if (@line > 1) {
        #print $line[1]."\n";
        $line[3]=~/(?:^[^\/]+\/){1}(.*)$/;
        #print "1: $1 2: $line[1]\n";
        $hd->{$1} = $line[1];
    }
    
}
close($hashdeep_fh);

my $md5sum_fh;
open($md5sum_fh, "<", $md5sum);
while (<$md5sum_fh>) {
    chomp;
    s/\r$//;
    if( /^([a-f0-9]+)\s+\*{0,1}(?:\.\/)?(.*)$/) {
	if ($hd->{$2} && $hd->{$2} eq $1) {
           #print "[$1] $2 :: ".$hd->{$2} ."\n";
           delete $hd->{$2};
	}
	else {
           print "[$1] $2 :: ERROR\n";
        }
    }
    

}

print "unused hashes: \n";
print p $hd;

