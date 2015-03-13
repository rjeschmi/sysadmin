#!/usr/bin/perl

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;


#====================================================================
#
#           QUERY MAC ADDRESSES FROM 3COM SWITCH
#
#    The following program automatically gets a list of MAC 
#    addresses on a 3com switch and which port each address 
#    is on using Ethernet MIB:dot1dTpFdbTable.
#
#    NOTE:  Portions of this code used from David M. Town <dtown@cpan.  +org>
#           table.pl
#
#====================================================================


use strict;
use Net::SNMP qw(snmp_dispatcher oid_lex_sort);

#=== Setup session to remote host ===
my ($session, $error) = Net::SNMP->session(
   -hostname  => $ARGV[0] || '192.168.160.3',
   -community => $ARGV[1] || 'public',
   -port      => $ARGV[2] || 161
);
#=====================================

#=== Was the session created? ===
if (!defined($session)) {
   printf("ERROR: %s\n", $error);
   exit 1;
}
#==================================

#=== OIDs queried to retrieve information ====
# my $TpFdbAddress = '1.3.6.1.2.1.17.4.3.1.1';
# my $TpFdbPort    = '1.3.6.1.2.1.17.4.3.1.2';
my $TpFdbAddress = '1.3.6.1.2.1.4.22';
my $TpFdbPort    = '1.3.6.1.2.1.17.7.1.2';
#=============================================


#=== Print the returned MAC addresses ===
# printf("\n== MAC Addresses: %s ==\n\n", $TpFdbAddress);

# my $result;

# if (defined($result = $session->get_table(-baseoid => $TpFdbAddress)))
# {
#    foreach (oid_lex_sort(keys(%{$result}))) {
#       printf("%s => %s\n", $_, $result->{$_});
#    }
#    print "\n";
# } else {
#    printf("ERROR: %s\n\n", $session->error());
# }
#==========================================

#=== Print the returned MAC ports ===
# printf("\n== MAC Ports: %s ==\n\n", $TpFdbPort);

my $result;
my %MACS = ();
my $port;
my $key;
my $MAC;
my @tuples;
my $MACsfile = "/etc/etherswitch";

# read existing file into %MACS hash

open( FMACS, "<" . $MACsfile ) or die "Could not open $MACsfile for reading, $!";
while ( <FMACS> ) {
	chop;
	( $MAC, $port ) = split( /\s+/ );
	$MACS{ $MAC } = $port;
}
# foreach $key ( keys %MACS ) {
# 	printf(  "%s %s\n", $key, $MACS{ $key } ) ;
# }

# now query switch and get a dump of current MAC table
# note that any computers which have moved since the file
# was last updated will automatically get updated in this process

if (defined($result = $session->get_table(-baseoid => $TpFdbPort))) {
	foreach (oid_lex_sort(keys(%{$result}))) {
		$port = $result->{$_};
		@tuples = split( /\./, $_ );

#		s/1.3.6.1.2.1.17.7.1.2.2.1.2.1.//;
#		s/1.3.6.1.2.1.17.7.1.2.2.1.3.1.//;
#		I admit I do not fully understand what SNMP is returning but I do know that 
#		every MAC seems to get returned once via the first string above and each
#		MAC has a unique port number associated with it.   The MAC also gets
#		returned a second time at the end of the 2nd string and in this case
#		the port number is always 3 for some reason.  So we ingore the 2nd ones.
#		note that tuple 12 is 2 in the first case or 3 in the 2nd case

		if ( @tuples[12] == "2" ) {
			$MAC = sprintf( "%02x:%02x:%02x:%02x:%02x:%02x", @tuples[14], @tuples[15],@tuples[16],@tuples[17],@tuples[18],@tuples[19]);
#			printf( "%d %02x:%02x:%02x:%02x:%02x:%02x %d\n", @tuples[12], @tuples[14], @tuples[15],@tuples[16],@tuples[17],@tuples[18],@tuples[19], $port);
			$MACS{ $MAC } = $port;
		}
	}
} else {
    printf("ERROR: %s\n\n", $session->error());
}

# write the MACs out to our file

open( FMACS, ">" . $MACsfile ) or die "Could not open $MACsfile for writing, $!";
foreach $key ( keys %MACS ) {
	printf(  FMACS  "%s %s\n", $key, $MACS{ $key } ) ;
}
close (FMACS);
#=============================================

#=== Close the session and exit the program ===
$session->close;
exit 0;
