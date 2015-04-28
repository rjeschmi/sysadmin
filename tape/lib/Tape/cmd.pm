package Tape::cmd;


use Moose::Role;
use IPC::Run qw(run);
use Data::Printer;

sub run_cmd {
    my ($self, $cmd) = @_;

    my $out;
    p $cmd;
    run $cmd, ">", \$out or die("cmd: ".p($cmd)." : $?");

    return $out


}


1;
