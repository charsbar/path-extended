package Path::Extended::Test::Dir::Mkdir;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub mkdir : Tests(3) {
  my $class = shift;

  my $dir = dir('t/tmp/dir');
  ok !$dir->exists, $class->message('directory does not exist');

  $dir->mkdir;

  ok $dir->exists, $class->message('directory does exist');

  $dir->rmdir;

  ok !$dir->exists, $class->message('directory does not exist');
}

sub already_exists : Tests(3) {
  my $class = shift;

  my $dir = dir('t/tmp/dir')->mkdir;
  ok $dir->exists, $class->message('directory does exist');

  ok $dir->mkdir, $class->message('does not cause error');

  ok $dir->exists, $class->message('and directory still exists');

  $dir->rmdir;
}

1;
