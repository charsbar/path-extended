package Path::Extended::Test::Dir::Rmdir;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub rmdir : Tests(5) {
  my $class = shift;

  my $root_dir =  dir('t/tmp/dir')->mkdir;

  ok $root_dir->exists,  $class->message('root dir exists');

  my $subdir = dir('t/tmp/dir/level1')->mkdir;

  ok $subdir->exists, $class->message('subdirectory exists');

  $root_dir->rmdir({keep_root => 1});

  ok $root_dir->exists,  $class->message('root dir exists after rmdir with keep_root');

  ok !$subdir->exists, $class->message('subdirectory does not exist after rmdir with keep_root');

  $root_dir->rmdir;
  ok !$root_dir->exists,  $class->message('root dir does not exist');
}

1;
