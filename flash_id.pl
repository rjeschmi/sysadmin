#!/usr/bin/env perl

while (<>) {
	print "got line $_\n";
	m/(0x[0-9a-f]+)/ or next;
	my @lines = qx/lsscsi --wwn -t|grep $1/;
	$lines[0] =~ /sas:([0-9a-fx]+)/;
	print "found sas: ".$1."\n";
	my $DEV="sg20";
	qx!sg_ses --sas-addr=$1 --set=ident /dev/$DEV 2>&1!;
	if ($?) {
		print "exit code: ".$?."\n";
		$DEV="sg37";
		qx!sg_ses --sas-addr=$1 --set=ident /dev/$DEV 2>&1!;
	}
	sleep 2;
	qx!sg_ses --sas-addr=$1 --clear=ident /dev/$DEV 2>&1!;
}

