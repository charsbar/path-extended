package Path::Extended::Test::Compatibility::Basic;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Class;

# ripped from Path::Class' t/01-basic.t

sub initialize { $Path::Extended::IgnoreVolume = 1; }
sub finalize   { $Path::Extended::IgnoreVolume = 0; }

sub test00_file1 : Tests(4) {
  my $class = shift;

  my $file = file('foo.txt');

  ok $file eq 'foo.txt', $class->message("test 02");
  ok !$file->is_absolute, $class->message("test 03");
  ok $file->dir eq '.',   $class->message("test 04");
  ok $file->basename eq 'foo.txt', $class->message("test 05");
}

sub test01_file2 : Tests(4) {
  my $class = shift;

  my $file = file('dir', 'bar.txt');

  ok $file eq 'dir/bar.txt', $class->message("test 06");
  ok !$file->is_absolute, $class->message("test 07");
  ok $file->dir eq 'dir',   $class->message("test 08");
  ok $file->basename eq 'bar.txt', $class->message("test 09");
}

sub test02_dir1 : Tests(7) {
  my $class = shift;

  my $dir = dir('tmp');
  ok $dir eq 'tmp', $class->message("test 10");
  ok !$dir->is_absolute, $class->message("test 11");
  ok $dir->basename eq 'tmp', $class->message("RT 17312");

  my $cat = file($dir, 'foo');
  ok $cat eq 'tmp/foo', $class->message("test 14");
  $cat = $dir->file('foo');
  ok $cat eq 'tmp/foo', $class->message("test 15");
  ok $cat->dir eq 'tmp', $class->message("test 16");
  ok $cat->basename eq 'foo', $class->message("test 17");
}

sub test03_dir2 : Tests(9) {
  my $class = shift;

  my $dir = dir('/tmp');
  ok $dir eq '/tmp', $class->message("test 12");
  ok $dir->is_absolute, $class->message("test 13");

  my $cat = file($dir, 'foo');
  ok $cat eq '/tmp/foo', $class->message("test 18");
  $cat = $dir->file('foo');
  ok $cat eq '/tmp/foo', $class->message("test 19");
  ok $cat->isa('Path::Extended::Class::File'), $class->message("test 20");
  ok $cat->dir eq '/tmp', $class->message("test 21");

  $cat = $dir->subdir('foo');
  ok $cat eq '/tmp/foo', $class->message("test 22");
  ok $cat->isa('Path::Extended::Class::Dir'), $class->message("test 23");
  ok $cat->basename eq 'foo', $class->message("RT 17312");
}

sub test04_cleanup : Tests(3) {
  my $class = shift;

  my $file = file('/foo//baz/./foo')->cleanup;
  ok $file eq '/foo/baz/foo', $class->message("test 24");
  ok $file->dir eq '/foo/baz', $class->message("test 25");
  ok $file->parent eq '/foo/baz', $class->message("test 26");
}

sub test05_parents : Tests(9) {
  my $class = shift;

  my $dir = dir('/foo/bar/baz');
  ok $dir->parent eq '/foo/bar', $class->message("test 27");
  ok $dir->parent->parent eq '/foo', $class->message("test 28");
  ok $dir->parent->parent->parent eq '/', $class->message("test 29");
  ok $dir->parent->parent->parent->parent eq '/', $class->message("test 30");

  $dir = dir('foo/bar/baz');
  ok $dir->parent eq 'foo/bar', $class->message("test 31");
  ok $dir->parent->parent eq 'foo', $class->message("test 32");
  ok $dir->parent->parent->parent eq '.', $class->message("test 33");
  ok $dir->parent->parent->parent->parent eq '..', $class->message("test 34");
  ok $dir->parent->parent->parent->parent->parent eq '../..', $class->message("test 35");
}

sub tests06_trailing_slash : Tests(7) {
  my $class = shift;

  my $dir = dir("foo/");
  ok $dir eq 'foo', $class->message("test 36");
  ok $dir->parent eq '.', $class->message("test 37");

  # Special cases
  ok dir('') eq '/', $class->message("test 38");
  ok dir() eq '.', $class->message("test 39");
  ok dir('', 'var', 'tmp') eq '/var/tmp', $class->message("test 40");
  ok dir()->absolute->resolve eq dir(Cwd::cwd())->resolve, $class->message("test 41");
  ok !defined dir(undef), $class->message("dir(undef)"); # added
}

sub tests07_relative : Tests(5) {
  my $class = shift;
  my $file = file('/tmp/foo/bar.txt');
  ok $file->relative('/tmp') eq 'foo/bar.txt', $class->message("test 42");
  ok $file->relative('/tmp/foo') eq 'bar.txt', $class->message("test 43");
  ok $file->relative('/tmp/') eq 'foo/bar.txt', $class->message("test 44");
  ok $file->relative('/tmp/foo/') eq 'bar.txt', $class->message("test 45");

  $file = file('one/two/three');
  ok $file->relative('one') eq 'two/three', $class->message("test 46");
}

sub tests08_dir_list : Tests(11) {
  my $class = shift;
  my $dir = dir('one/two/three/four/five');
  my @d = $dir->dir_list();
  ok "@d" eq "one two three four five", $class->message("test 47");

  @d = $dir->dir_list(2);
  ok "@d" eq "three four five", $class->message("test 48");

  @d = $dir->dir_list(-2);
  ok "@d" eq "four five", $class->message("test 49");

  @d = $dir->dir_list(2, 2);
  ok "@d" eq "three four", $class->message("test 50");

  @d = $dir->dir_list(-3, 2);
  ok "@d" eq "three four", $class->message("test 51");

  @d = $dir->dir_list(-3, -2);
  ok "@d" eq "three", $class->message("test 52");

  @d = $dir->dir_list(-3, -1);
  ok "@d" eq "three four", $class->message("test 53");

  my $d = $dir->dir_list();
  ok $d == 5, $class->message("test 54");

  $d = $dir->dir_list(2);
  ok $d eq "three", $class->message("test 55");

  $d = $dir->dir_list(-2);
  ok $d eq "four", $class->message("test 56");

  $d = $dir->dir_list(2, 2);
  ok $d eq "four", $class->message("test 57");
}

sub tests09_is_dir : Tests(2) {
  my $class = shift;
  ok  dir('foo')->is_dir == 1, $class->message("test 58");
  ok file('foo')->is_dir == 0, $class->message("test 59");
}

sub tests10_subsumes : Tests(6) {
  my $class = shift;
  ok dir('foo/bar')->subsumes('foo/bar/baz') == 1, $class->message("test 60");
  ok dir('/foo/bar')->subsumes('/foo/bar/baz') == 1, $class->message("test 61");
  ok dir('foo/bar')->subsumes('bar/baz') == 0, $class->message("test 62");
  ok dir('/foo/bar')->subsumes('foo/bar') == 0, $class->message("test 63");
  ok dir('/foo/bar')->subsumes('/foo/baz') == 0, $class->message("test 64");
  ok dir('/')->subsumes('/foo/bar') == 1, $class->message("test 65");
}

1;
