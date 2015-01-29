#!/usr/bin/env perl

my $LSSCSI="/software/packages/lsscsi-0.28b4r120/bin/lsscsi";
my $SG_SES="/software/packages/sg3_utils-1.40b9r614/bin/sg_ses";

my @SASs;

while (<>) {
	print "got line $_\n";
	m/(0x[0-9a-f]+)/ or next;
	my @lines = qx/$LSSCSI --wwn -t|grep $1/;
	$lines[0] =~ /sas:([0-9a-fx]+)/;
	print "found sas: ".$1."\n";
	push @SASs,$1;
}

foreach my $sasaddr(@SASs){
	my $DEV="sg16";
	qx!$SG_SES --sas-addr=$sasaddr --set=ident /dev/$DEV 2>&1!;
	if ($?) {
		print "exit code: ".$?."\n";
		$DEV="sg37";
		qx!$SG_SES --sas-addr=$sasaddr --set=ident /dev/$DEV 2>&1!;
	}
} 

sleep 50;

foreach my $sasaddr (@SASs){
	my $DEV = "sg16";
	qx!$SG_SES --sas-addr=$sasaddr --clear=ident /dev/$DEV 2>&1!;
	if ($?) {
		$DEV="sg37";
		qx!$SG_SES --sas-addr=$sasaddr --clear=ident /dev/$DEV 2>&1!;
	}

} 
