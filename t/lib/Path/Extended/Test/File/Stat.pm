package Path::Extended::Test::File::Stat;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub stat_for_file : Test {
  my $class = shift;

  my $file = file('t/tmp/stat.txt');
     $file->touch;

  ok ref $file->stat eq 'File::stat', $class->message('got a stat object');

  $file->unlink;
}

sub stat_for_handle : Test {
  my $class = shift;

  my $file = file('t/tmp/stat.txt');
     $file->openw;

  ok ref $file->stat eq 'File::stat', $class->message('got a stat object');

  $file->unlink;
}

sub mtime : Tests(3) {
  my $class = shift;

  my $file = file('t/tmp/stat.txt');

  ok !$file->mtime, $class->message('no mtime as file does not exist');

  $file->touch;

  ok $file->mtime, $class->message('valid mtime');

  ok $file->mtime(time), $class->message('set mtime');

  $file->unlink;
}

sub size : Tests(4) {
  my $class = shift;

  my $file = file('t/tmp/stat.txt');

  ok !$file->size, $class->message('zero size as file does not exist');

  $file->touch;

  ok !$file->size, $class->message('zero size');

  $file->save('content');

  ok $file->size, $class->message('non zero size');

  $file->openr;

  ok $file->size, $class->message('non zero size');

  $file->unlink;
}

sub exists : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/stat.txt');

  $file->unlink;

  ok !$file->exists, $class->message('file does not exist');

  $file->touch;

  ok $file->exists, $class->message('file exists');

  $file->unlink;
}

1;
