package Tape::MT;

=head1 NAME

Tape::MT - a wrapper around a bunch of MT commands

=head1 SYNOPSIS

use Tape::MT;

my $tape_device = "/dev/nst0";

$mt = new MT( device=>$tape_device);

$mt->asf(2); # go to second file on tape

$mt->fsf(); # move forward

my $header_file = "/tmp/volume/header_file
my $volume_dir = "/tmp/volume/volume_dir";

$mt->cat($header_file); # cat the contents of tape plaintext file to disk file
$mt->tar($volume_dir); # extract tarball into volume dir


=head1 DESCRIPTION

Tape::MT wraps a bunch of the mt commands and adds a couple of useful redirection commands (cat, tar) to take tape archives and recover them
onto disk

=cut


use strict;

use Moose;
use Data::Printer;
use IPC::Run qw(run);

with 'Tape::cmd';

has 'tape_device' => ( is => 'rw', default => '/dev/nst0' );
has 'mt_cmd' => ( is=>'rw', default => '/bin/mt');


sub run_mt {
    my ($self, $cmd) = @_;
    
    my $cmd_out_ref;
    print "cmd is a ref: ".ref($cmd)."\n".p($cmd)."\n";
    if(ref($cmd) eq "ARRAY") {
        print "cmd is an array\n";
        my @cmd_out =  ( $self->mt_cmd, "-f", $self->tape_device, @$cmd) ;
        $cmd_out_ref = \@cmd_out;     
    }
    else {
        my @cmd_out = ( $self->mt_cmd, "-f", $self->tape_device, $cmd);
        $cmd_out_ref = \@cmd_out;     
    }

    my $out = $self->run_cmd($cmd_out_ref);
    
    return $out
}

sub file_number {
    my ($self, $cmd) = @_;

    my $out = $self->run_mt("status");

    $out =~ /File\snumber=(\d+),/;
    return $1;
}

sub rewind {
    my ($self) = @_;

    $self->run_mt("rewind");

    
}

sub asf {
    my ($self, $asf_no) = @_;

    unless ($asf_no=~/^\d+$/) {
        die ("the file number needs to be a number");
    }
    $self->run_mt(["asf",$asf_no]);
}

sub fsf {
    my ($self) = @_;
    $self->run_mt("fsf");
}

sub cat {
    my ($self, $dest) = @_;

    my @cat = qw( cat );
    my $out;
    open (my $tape_fh, "<", $self->tape_device()) or die $!;
    run \@cat, $tape_fh, \$out;

    open(my $dest_fh, ">", $dest) or die $!;

    print $dest_fh $out;

    
}

sub tar {
    my ($self, $chdir) = @_;

    run "tar", "-C", $chdir, "-xvf", $self->tape_device or die ("tar failed: $? ");
}


1;
