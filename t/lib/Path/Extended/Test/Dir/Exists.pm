package Path::Extended::Test::Dir::Exists;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub exists : Tests(2) {
  my $class = shift;

  my $dir = dir('t/tmpdir');

  $dir->rmdir;

  ok !$dir->exists, $class->message('dir does not exist');

  $dir->mkdir;

  ok $dir->exists, $class->message('dir exists');

  $dir->rmdir;
}

1;
