package Path::Extended::Test::Subclass::FileOrDir;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Test;

sub initialize {
  my $class = shift;

  dir('t/tmp/dir')->mkdir;
  file('t/tmp/file')->touch;
}

sub file_or_dir_for_an_existing_file : Test {
  my $class = shift;

  my $maybe_file = file_or_dir('t/tmp/file');
  ok $maybe_file->isa('Path::Extended::Test::File'), $class->message('got a File object for an existing file');
}

sub file_or_dir_for_an_existing_dir : Test {
  my $class = shift;

  my $maybe_file = file_or_dir('t/tmp/dir');
  ok $maybe_file->isa('Path::Extended::Test::Dir'), $class->message('got a Dir object for an existing directory');
}

sub file_or_dir_for_an_unknown_path : Test {
  my $class = shift;

  my $maybe_file = file_or_dir('t/tmp/unknown');
  ok $maybe_file->isa('Path::Extended::Test::File'), $class->message('got a File object for an unknown path');
}

sub dir_or_file_for_an_existing_file : Test {
  my $class = shift;

  my $maybe_dir = dir_or_file('t/tmp/file');
  ok $maybe_dir->isa('Path::Extended::Test::File'), $class->message('got a File object for an existing file');
}

sub dir_or_file_for_an_existing_dir : Test {
  my $class = shift;

  my $maybe_dir = dir_or_file('t/tmp/dir');
  ok $maybe_dir->isa('Path::Extended::Test::Dir'), $class->message('got a Dir object for an existing directory');
}

sub dir_or_file_for_an_unknown_path : Test {
  my $class = shift;

  my $maybe_dir = dir_or_file('t/tmp/unknown');
  ok $maybe_dir->isa('Path::Extended::Test::Dir'), $class->message('got a Dir object for an unknown path');
}

1;
