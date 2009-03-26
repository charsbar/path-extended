package Path::Extended::Test::Dir::Copy;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub copy : Tests(7) {
  my $class = shift;

  my $file = file('t/tmp/copy/copy.txt');
  $file->save('content', mkdir => 1 );
  my $size = $file->size;

  ok $file->exists, $class->message('original file created');
  ok $size,         $class->message('and not zero sized');

  my $dir = dir('t/tmp/copy');
     $dir->copy_to('t/tmp/copied');

  my $original = dir('t/tmp/copy');
  my $copied   = dir('t/tmp/copied');

  ok $original->exists, $class->message('original dir still exists');
  ok $copied->exists, $class->message('copied dir exists');

  ok $dir->absolute eq $original->absolute,
    $class->message('dir is not moved');

  my $copied_file = file('t/tmp/copied/copy.txt');
  ok $copied_file->exists, $class->message('copied file exists');
  ok $copied_file->size == $size, $class->message('and the same size');

  $original->rmdir;
  $copied->rmdir;
}

sub move : Tests(7) {
  my $class = shift;

  my $file = file('t/tmp/move/move.txt');
  $file->save('content', mkdir => 1 );
  my $size = $file->size;

  ok $file->exists, $class->message('original file created');
  ok $size,         $class->message('and not zero sized');

  my $dir = dir('t/tmp/move');
     $dir->move_to('t/tmp/moved');

  my $original = dir('t/tmp/move');
  my $moved    = dir('t/tmp/moved');

  ok !$original->exists, $class->message('original dir does not exist');
  ok $moved->exists, $class->message('moved dir exists');

  ok $dir->absolute eq $moved->absolute,
    $class->message('dir is moved');

  my $moved_file = file('t/tmp/moved/move.txt');
  ok $moved_file->exists, $class->message('moved file exists');
  ok $moved_file->size == $size, $class->message('and the same size');
  $moved->rmdir;
}

sub rename : Tests(7) {
  my $class = shift;

  my $file = file('t/tmp/rename/rename.txt');
  $file->save('content', mkdir => 1 );
  my $size = $file->size;

  ok $file->exists, $class->message('original file created');
  ok $size,         $class->message('and not zero sized');

  my $dir = dir('t/tmp/rename');
     $dir->rename_to('t/tmp/renamed');

  my $original = dir('t/tmp/rename');
  my $renamed  = dir('t/tmp/renamed');

  ok !$original->exists, $class->message('original dir does not exist');
  ok $renamed->exists, $class->message('renamed dir exists');

  ok $dir->absolute eq $renamed->absolute,
    $class->message('dir is renamed');

  my $renamed_file = file('t/tmp/renamed/rename.txt');
  ok $renamed_file->exists, $class->message('renamed file exists');
  ok $renamed_file->size == $size, $class->message('and the same size');
  $renamed->rmdir;
}

1;
