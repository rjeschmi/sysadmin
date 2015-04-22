#!/usr/bin/env perl
#
#

use File::Spec;


my $tape_device = "/dev/nst0";
my $tape_script_root = "/ohri/archive/archive_scripts";
my $dest_root = "/ohri/archive/tapes";

my $tape_no = shift @ARGV;

my $dest_dir = File::Spec->catfile($dest_root, $tape_no);

if($tape_no =~ /^1[0-9]+/) {
    if ( ! -d $dest_dir) {
        mkdir $dest_dir;
    }
    else {
        die (" $dest_dir already exists ");
    }
    chdir $dest_dir;
    my $tape_inv_dir = File::Spec->catfile($tape_script_root, 'tapes', $tape_no);
    opendir(my $dh, $tape_inv_dir) || die;
    my @volumes = grep { /^[0-9]+/ } readdir ($dh) ;
    
    system("mt -f $tape_device asf 2");

    foreach my $i (@volumes) {
        system("mt -f $tape_device fsf");
        system("cat $tape_device > $i.headers")
        mkdir $i;
        system("tar -C $i -xvf $tape_device") 
    }

}
