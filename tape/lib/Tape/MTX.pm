package Tape::MTX;

use strict;

use Moose;

has 'tapechanger_device' => ( is => 'rw', default => '/dev/sg1' );

has 'mtx_cmd' => ( is => 'rw', default => '/usr/sbin/mtx');


1;
