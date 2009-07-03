package Path::Extended::Test::FileOrDir::ForDir;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub initialize {
  my $class = shift;

  dir('t/tmp/dir')->mkdir;
  file('t/tmp/file')->touch;
}

sub file_or_dir_for_an_existing_file : Test {
  my $class = shift;

  my $maybe_file = dir('t/tmp/')->file_or_dir('file');
  ok $maybe_file->isa('Path::Extended::File'), $class->message('got a File object for an existing file');
}

sub file_or_dir_for_an_existing_dir : Test {
  my $class = shift;

  my $maybe_file = dir('t/tmp/')->file_or_dir('dir');
  ok $maybe_file->isa('Path::Extended::Dir'), $class->message('got a Dir object for an existing directory');
}

sub file_or_dir_for_an_unknown_path : Test {
  my $class = shift;

  my $maybe_file = dir('t/tmp/')->file_or_dir('unknown');
  ok $maybe_file->isa('Path::Extended::File'), $class->message('got a File object for an unknown path');
}

sub dir_or_file_for_an_existing_file : Test {
  my $class = shift;

  my $maybe_dir = dir('t/tmp/')->dir_or_file('file');
  ok $maybe_dir->isa('Path::Extended::File'), $class->message('got a File object for an existing file');
}

sub dir_or_file_for_an_existing_dir : Test {
  my $class = shift;

  my $maybe_dir = dir('t/tmp/')->dir_or_file('dir');
  ok $maybe_dir->isa('Path::Extended::Dir'), $class->message('got a Dir object for an existing directory');
}

sub dir_or_file_for_an_unknown_path : Test {
  my $class = shift;

  my $maybe_dir = dir('t/tmp/')->dir_or_file('unknown');
  ok $maybe_dir->isa('Path::Extended::Dir'), $class->message('got a Dir object for an unknown path');
}

1;
