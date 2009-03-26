package Path::Extended::Test::Subclass::Import;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Test;

sub file_class : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/import');
  ok $file->isa('Path::Extended::Test::File'), $class->message("isa ::Test::File");
  ok $file->isa('Path::Extended::File'), $class->message("isa ::File");
}

sub dir_class : Tests(2) {
  my $class = shift;

  my $dir = dir('t/tmp/import');
  ok $dir->isa('Path::Extended::Test::Dir'), $class->message("isa ::Test::Dir");
  ok $dir->isa('Path::Extended::Dir'), $class->message("isa ::Dir");
}

1;
