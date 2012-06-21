package Path::Extended::Test::Dir::Path;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;
use File::Spec;

sub constructor : Tests(4) {
  my $class = shift;

  my $dir = dir('t/tmp/tmpdir');

  ok $dir->path, $class->message('constructor contains the path');

  ok( File::Spec->file_name_is_absolute( $dir->path ),
    $class->message('and the path is absolute'));

  ok !$dir->_handle, $class->message('and its handle is not open');

  ok !$dir->exists, $class->message('and the dir does not exist');
}

sub input_path_is_absolute : Test(2) {
  my $class = shift;

  my $dir_rel = dir('a/relative/../path');

  ok ( ! $dir_rel->is_absolute, $class->message('input path is not absolute') );

  my $dir_abs = dir('/is/an/absolute/path');

  ok ( $dir_abs->is_absolute, $class->message('input path is absolute' ) );
}

sub forward_slashes : Test {
  my $class = shift;

  unless ( $^O eq 'MSWin32' ) {
    return $class->skip_this_test('this test is for Win32');
  }

  my $dir = dir('t\\tmp\\tmpdir');

  ok $dir->path !~ /\\/,
    $class->message('path does not contain back slashes');
}

sub absolute : Tests(3) {
  my $class = shift;

  my $dir = dir('t/tmp/tmpdir');

  ok( File::Spec->file_name_is_absolute($dir->absolute),
    $class->message('dir name is absolute')
  );

  unless ( $^O eq 'MSWin32' ) {
    return $class->abort_this_test('native check is only for Win32');
  }

  ok $dir->absolute ne $dir->absolute( native => 1 ),
    $class->message('paths vary according to the native option');

  ok $dir->absolute( native => 1 ) =~ /\\/,
    $class->message('native path does contain back slashes');
}

sub relative : Tests(3) {
  my $class = shift;

  my $dir = dir('t/tmp/tmpdir');

  ok( !File::Spec->file_name_is_absolute($dir->relative),
    $class->message('dir name is relative')
  );

  unless ( $^O eq 'MSWin32' ) {
    return $class->abort_this_test('native check is only for Win32');
  }

  ok $dir->relative ne $dir->relative( native => 1 ),
    $class->message('paths vary according to the native option');

  ok $dir->relative( native => 1 ) =~ /\\/,
    $class->message('native path does contain back slashes');
}

sub relative_with_explicit_base : Test {
  my $class = shift;

  my $dir = dir('t/tmp/tmpdir/tmp');
  ok $dir->relative( base => 't/tmp' ) eq 'tmpdir/tmp',
    $class->message('base path option works');
}

sub default_directory : Test {
  my $class = shift;

  my $dir = dir();
  ok $dir->absolute eq dir('.')->absolute, $class->message('default directory is current directory');
}

1;
