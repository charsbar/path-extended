package Path::Extended::Test::File::Copy;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub copy : Tests(16) {
  my $class = shift;

  foreach my $flag (0, 1) {
    my $file = file('t/tmp/copy.txt');
    $file->save('content');
    my $size = $file->size;

    ok $file->exists, $class->message('original file created');
    ok $size,         $class->message('and not zero sized');

    $file->openr if $flag;

    $file->copy_to('t/tmp/copied.txt');

    my $original = file('t/tmp/copy.txt');
    my $copied   = file('t/tmp/copied.txt');

    ok $original->exists, $class->message('original file still exists');
    ok $original->size == $size, $class->message('and the same size');
    ok $copied->exists, $class->message('copied file exists');
    ok $copied->size == $size, $class->message('and the same size');

    ok $file->absolute eq $original->absolute,
      $class->message('file is not moved');

    $file->close;

    ok $original->unlink;
    $copied->unlink;
  }
}

sub move : Tests(12) {
  my $class = shift;

  foreach my $flag (0, 1) {
    my $file = file('t/tmp/move.txt');
    $file->save('content');
    my $size = $file->size;

    ok $file->exists, $class->message('original file created');
    ok $size,         $class->message('and not zero sized');

    $file->openr if $flag;

    $file->move_to('t/tmp/moved.txt');

    my $original = file('t/tmp/move.txt');
    my $moved    = file('t/tmp/moved.txt');

    ok !$original->exists, $class->message('original file does not exist');
    ok $moved->exists, $class->message('moved file exists');
    ok $moved->size == $size, $class->message('and the same size');

    ok $file->absolute eq $moved->absolute,
      $class->message('file is moved');

    $file->close;

    $original->unlink;
    $moved->unlink;
  }
}

sub rename : Tests(12) {
  my $class = shift;

  foreach my $flag (0, 1) {
    my $file = file('t/tmp/rename.txt');
    $file->save('content');
    my $size = $file->size;

    ok $file->exists, $class->message('original file created');
    ok $size,         $class->message('and not zero sized');

    $file->openr if $flag;

    $file->rename_to('t/tmp/renamed.txt');

    my $original = file('t/tmp/rename.txt');
    my $renamed  = file('t/tmp/renamed.txt');

    ok !$original->exists, $class->message('original file does not exist');
    ok $renamed->exists, $class->message('renamed file exists');
    ok $renamed->size == $size, $class->message('and the same size');

    ok $file->absolute eq $renamed->absolute,
      $class->message('file is renamed');

    $file->close;

    $original->unlink;
    $renamed->unlink;
  }
}

sub errors : Tests(3) {
  my $class = shift;

  my $file = file('t/tmp/errors.txt');
     $file->logger(0);

  ok !$file->copy_to, $class->message('requires destination');
  ok !$file->move_to, $class->message('requires destination');
  ok !$file->rename_to, $class->message('requires destination');
}

1;
