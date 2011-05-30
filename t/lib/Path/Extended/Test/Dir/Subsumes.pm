package Path::Extended::Test::Dir::Subsumes;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub tests01_subsumes : Tests(2) {
  my $class = shift;

  ok dir('t/foo/bar')->subsumes('t/foo/bar/baz'), $class->message('t/foo/bar subsumes t/foo/bar/baz');

  ok !dir('t/foo/bar')->subsumes('t/foo/baz/bar'), $class->message('t/foo/bar does not subsume t/foo/baz/bar');
}

sub tests02_subsumes_win32 : Tests(3) {
  my $class = shift;

  return $class->skip_this_test('this is Win32 only') unless $^O eq 'MSWin32';

  ok dir('C:/foo/bar')->subsumes('C:/foo/bar/baz'), $class->message('C:/foo/bar subsumes C:/foo/bar/baz');
  ok !dir('C:/foo/bar')->subsumes('D:/foo/bar/baz'), $class->message('C:/foo/bar does not subsume D:/foo/bar/baz');

  ok !dir('C:/foo/bar')->subsumes('C:/foo/baz/bar'), $class->message('t/foo/bar does not subsume t/foo/baz/bar');
}

1;
