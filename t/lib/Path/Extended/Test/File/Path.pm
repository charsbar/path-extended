package Path::Extended::Test::File::Path;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;
use File::Spec;

sub constructor : Tests(4) {
  my $class = shift;

  my $file = file('t/tmp/file.txt');

  ok $file->path, $class->message('constructor contains the path');

  ok( File::Spec->file_name_is_absolute( $file->path ),
    $class->message('and the path is absolute'));

  ok !$file->_handle, $class->message('and its handle is not open');

  ok !$file->exists, $class->message('and the file does not exist');
}

sub input_path_is_absolute : Test(2) {
  my $class = shift;

  my $file_rel = file('a/relative/../path/to/file');

  ok ( ! $file_rel->is_absolute, $class->message('input path is not absolute') );

  my $file_abs = file('/is/an/absolute/path/to/file');

  ok ( $file_abs->is_absolute, $class->message('input path is absolute' ) );
}

sub forward_slashes : Test {
  my $class = shift;

  unless ( $^O eq 'MSWin32' ) {
    return $class->skip_this_test('this test is for Win32');
  }

  my $file = file('t\\tmp\\file.txt');

  ok $file->path !~ /\\/,
    $class->message('path does not contain back slashes');
}

sub absolute : Tests(3) {
  my $class = shift;

  my $file = file('t/tmp/file.txt');

  ok( File::Spec->file_name_is_absolute($file->absolute),
    $class->message('file name is absolute')
  );

  unless ( $^O eq 'MSWin32' ) {
    return $class->abort_this_test('native check is only for Win32');
  }

  ok $file->absolute ne $file->absolute( native => 1 ),
    $class->message('paths vary according to the native option');

  ok $file->absolute( native => 1 ) =~ /\\/,
    $class->message('native path does contain back slashes');
}

sub relative : Tests(3) {
  my $class = shift;

  my $file = file('t/tmp/file.txt');

  ok( !File::Spec->file_name_is_absolute($file->relative),
    $class->message('file name is relative')
  );

  unless ( $^O eq 'MSWin32' ) {
    return $class->abort_this_test('native check is only for Win32');
  }

  ok $file->relative ne $file->relative( native => 1 ),
    $class->message('paths vary according to the native option');

  ok $file->relative( native => 1 ) =~ /\\/,
    $class->message('native path does contain back slashes');
}

sub relative_with_explicit_base : Test {
  my $class = shift;

  my $file = file('t/tmp/file.txt');
  ok $file->relative( base => 't/' ) eq 'tmp/file.txt',
    $class->message('base path option works');
}

sub basename : Test {
  my $class = shift;

  my $file = file('t/tmp/file.txt');
  ok $file->basename eq 'file.txt', $class->message('got basename');
}

sub touch : Tests(4) {
  my $class = shift;

  my $file = file('t/tmp/touch.txt');
  ok !$file->exists, $class->message('file does not exist');
  ok $file->touch, $class->message('created file');
  ok $file->exists, $class->message('file does exist');
  ok $file->touch, $class->message('changed mtime');

  $file->unlink;
}

1;
