package Path::Extended::Test::File::Read;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;
use Fcntl qw( :DEFAULT :seek );

sub basic : Tests(17) {
  my $class = shift;

  my $file = file('t/tmp/read.txt');

  ok $file->open('w'), $class->message('opened file to write');
     $file->binmode;
     $file->autoflush(1);
  ok $file->lock_ex, $class->message('exclusive lock');
  ok $file->print("first line\n"), $class->message('print works');
  ok $file->printf("%s line\n", "second"), $class->message('printf works');
  ok $file->say("third line"), $class->message('say works');
  ok $file->write("fourth line\n"), $class->message('write works');
  ok $file->syswrite("fifth line\n"), $class->message('syswrite works');

  ok $file->close, $class->message('close works');

  ok $file->open('r'), $class->message('opened file to read');
  ok $file->lock_sh, $class->message('shared lock');
  ok $file->getline eq "first line\n", $class->message('read first line');
  my $pos = $file->tell;
  ok $pos, $class->message('tell works');
  my @lines = $file->getlines;
  ok @lines == 4 && $lines[0] eq "second line\n", $class->message('read remaining lines');
  ok $file->seek(0, SEEK_SET), $class->message('rewinded');
  $file->read(my $read, 5);
  ok $read eq 'first', $class->message('read works');
  ok $file->sysseek($pos, SEEK_SET), $class->message('moved pointer to second line');
  $file->sysread($read, 6);
  ok $read eq 'second', $class->message('sysread works');

  $file->close;

  $file->unlink;
}

sub read_before_open : Tests(18) {
  my $class = shift;

  my $file = file('t/tmp/not_readable.txt');

  ok !$file->is_open, $class->message('file is not open');
  ok !$file->close, $class->message("can't close before open");
  ok !$file->binmode, $class->message("ignored binmode before open");
  ok !$file->print("ignored"), $class->message("ignored print before open");
  ok !$file->printf("ignored"), $class->message("ignored printf before open");
  ok !$file->say("ignored"), $class->message("ignored say before open");
  ok !$file->getline, $class->message("ignored getline before open");
  ok !$file->getlines, $class->message("ignored getlines before open");
  ok !$file->read, $class->message("ignored read before open");
  ok !$file->sysread, $class->message("ignored sysread before open");
  ok !$file->write("ignored"), $class->message("ignored write before open");
  ok !$file->syswrite("ignored"), $class->message("ignored syswrite before open");
  ok !$file->autoflush(1), $class->message("ignored autoflush before open");
  ok !$file->lock_ex, $class->message("ignored lock_ex before open");
  ok !$file->lock_sh, $class->message("ignored lock_sh before open");
  ok !$file->seek(0, SEEK_SET), $class->message("ignored seek before open");
  ok !$file->sysseek(0, SEEK_SET), $class->message("ignored sysseek before open");
  ok !$file->tell, $class->message("ignored tell before open");
}

sub reopen : Tests(4) {
  my $class = shift;

  my $file = file('t/tmp/reopen.txt');

  ok $file->open('w'), $class->message("file opened");
     $file->write('test');
  ok $file->open('<:raw'), $class->message("reopened");

  $file->close;

  ok $file->sysopen(O_RDONLY), $class->message("file opened with sysopen");
  ok $file->sysopen(O_RDONLY), $class->message("reopened with sysopen");

  $file->unlink;
}

1;
