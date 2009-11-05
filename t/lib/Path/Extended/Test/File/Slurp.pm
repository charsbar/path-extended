package Path::Extended::Test::File::Slurp;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;
use utf8;

sub basic : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');

  ok $file->save("content"), $class->message('file saved');
  ok $file->slurp eq "content", $class->message('slurped successfully');

  $file->unlink;
}

sub multilines : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');

  my $content = "line1\nline2\nline3\n";
  ok $file->save($content), $class->message('file saved');
  ok $file->slurp eq $content, $class->message('slurped successfully');

  $file->unlink;
}

sub list : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');

  my $content = "line1\nline2\nline3\n";
  ok $file->save($content), $class->message('file saved');

  my @lines = $file->slurp;

  ok $lines[0] eq "line1\n", $class->message('slurped successfully');

  $file->unlink;
}

sub binmode : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');

  ok $file->save("first line\012second line\012", {
    binmode => 1,
  }), $class->message('file saved');

  ok $file->slurp({ binmode => 1 }) eq "first line\012second line\012", $class->message('binmode worked');

  $file->unlink;
}

sub mkdir : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp/slurp.txt');
  ok $file->save("content", mkdir => 1), $class->message('made directory');
  ok $file->slurp eq 'content', $class->message('slurped successfully');

  $file->parent->rmdir;
}

sub encode : Tests(2) {
  my $class = shift;

  my $utf8 = "テスト";

  my $file = file('t/tmp/slurp.txt');
  ok $file->save($utf8, encode => 'utf8'), $class->message('file saved as utf8');
  ok $file->slurp(decode => 'utf8') eq $utf8, $class->message('slurped successfully as utf8');

  $file->unlink;
}

sub chomp : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');
  ok $file->save("first line\nsecond line\n"), $class->message('file saved');
  my @lines = $file->slurp( chomp => 1 );
  ok $lines[0] eq 'first line', $class->message('chomped successfully');

  $file->unlink;
}

sub callback : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');
  ok $file->save("first line\nsecond line\n", callback => sub { s/line/son/; $_; }), $class->message('file saved');
  my @lines = $file->slurp( callback => sub { s/son/daughter/; $_; } );
  ok $lines[0] eq "first daughter\n", $class->message('callback worked');

  $file->unlink;
}

sub mtime : Tests(2) {
  my $class = shift;

  my $file = file('t/tmp/slurp.txt');
  ok $file->save("first line\nsecond line\n", mtime => time - 30000), $class->message('file saved');
  ok $file->mtime < time - 10000, $class->message('mtime worked');

  $file->unlink;
}

sub multiple_callbacks : Tests(2) {
  my $class = shift;

  my $utf8 = "テスト";

  my $file = file('t/tmp/slurp.txt');
  ok $file->save($utf8, encode => 'utf8', callback => sub { "$_\n" }), $class->message('file saved as utf8');
  ok $file->slurp(decode => 'utf8', callback => sub { s/\n//s; $_ }) eq $utf8, $class->message('slurped successfully as utf8');

  $file->unlink;
}

1;
