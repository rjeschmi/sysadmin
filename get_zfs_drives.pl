#!/usr/bin/env perl
#
# to reference drives by wwn
#

use Data::Printer;
use Array::Utils qw(array_diff);

my $LSSCSI = '/software/binaries/bin/lsscsi';
my $ZPOOL  = '/sbin/zpool';


my $ZPOOL_STATUS = qx!$ZPOOL status -v!;

print $ZPOOL_STATUS."\n";

my @z_drives = $ZPOOL_STATUS =~ /(wwn-0x[0-9a-z]+)/mg;

my $lsscsi_w = qx!$LSSCSI -w!;

#seagate only 0x5000c5
my @av_drives = $lsscsi_w =~ /(0x5000c5[0-9a-z]+)/mg;

@av_drives = map { "wwn-".$_ } @av_drives;

my @unused = array_diff (@av_drives, @z_drives);
print join ("\n",@unused)."\n";


