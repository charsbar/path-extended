package Path::Extended::Test::Dir::Seek;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub seek : Tests(11) {
  my $class = shift;

  my $dir = dir('t/tmp/seek')->mkdir;

  ok $dir->exists, $class->message('made directory');

  my $file1 = file('t/tmp/seek/file1.txt')->save('content1');
  my $file2 = file('t/tmp/seek/file2.txt')->save('content2');

  ok $dir->open, $class->message('opened directory');

  ok defined $dir->tell, $class->message('current position is '. $dir->tell);

  ok $dir->read, $class->message('read directory');

  my $pos = $dir->tell;
  ok $pos, $class->message('got a current position');

  my $read = $dir->read;
  ok $read, $class->message('read more');;

  ok $dir->seek($pos), $class->message('rewinded a bit');

  ok $dir->read eq $read, $class->message('the same thing is read');

  ok $dir->rewind, $class->message('rewinded');

  ok defined $dir->tell, $class->message('current position is '. $dir->tell);

  ok $dir->close, $class->message('closed directory');

  $dir->rmdir;
}

sub seek_before_open : Tests(5) {
  my $class = shift;

  my $dir = dir('t/tmp/unseekable');

  ok !defined $dir->tell, $class->message('cannot tell');
  ok !defined $dir->read, $class->message('cannot read');
  ok !defined $dir->seek, $class->message('cannot seek');
  ok !defined $dir->rewind, $class->message('cannot rewind');
  ok !defined $dir->close, $class->message('cannot close');
}

sub cannot_open : Test {
  my $class = shift;

  my $dir = dir('t/tmp/unseekable');
     $dir->logger(0);

  ok !defined $dir->open, $class->message('cannot open');
}

sub open_opened_directory : Tests(2) {
  my $class = shift;

  my $dir = dir('t/tmp/seek')->mkdir;

  ok $dir->open, $class->message('opened directory');
  ok $dir->open, $class->message('and opened it again');

  $dir->close;

  $dir->rmdir;
}

1;
