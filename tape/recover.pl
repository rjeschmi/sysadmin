#!/usr/bin/env perl
#
#

use FindBin;
use lib "$FindBin::Bin/lib";

use File::Spec;
use Tape::MT;


my $tape_device = "/dev/nst0";

$mt = new Tape::MT( device=>$tape_device);

my $tape_script_root = "/ohri/archive/archive_scripts";
my $dest_root = "/ohri/archive/tapes";

my $tape_no = shift @ARGV;

my $dest_dir = File::Spec->catfile($dest_root, $tape_no);

if($tape_no =~ /^1\d+/) {
    if ( ! -d $dest_dir) {
        mkdir $dest_dir;
    }
    else {
        die (" $dest_dir already exists ");
    }
    chdir $dest_dir;
    my $tape_inv_dir = File::Spec->catfile($tape_script_root, 'tapes', $tape_no);
    opendir(my $dh, $tape_inv_dir) || die;
    my @volumes = grep { /^\d+/ } readdir ($dh) ;
   
    $mt->asf(2);

    for (my $i=1; $i<=@volumes; $i++) {
        $mt->fsf();
        $mt->cat( File::Spec->catfile($dest_dir, "$i.headers"));
        my $volume_dir=File::Spec->catfile($dest_dir, $i); 
        mkdir $volume_dir;
        $mt->tar($volume_dir) ;
    }

}
else {

    die (" we need a tape number that starts with 1 ");
}



