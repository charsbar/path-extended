package Path::Extended::Test::File::Grep;

use strict;
use warnings;
use Test::Classy::Base;

__PACKAGE__->mk_classdata( target => 'Path::Extended' );

sub initialize {
  my $class = shift;

  my $target = $class->target;
  eval "require $target" or $class->skip_this_class($@);
  $target->import;
}

sub prepare_file {
  my $class = shift;

  my $file = file('t/tmp/grep.txt');
     $file->save("foo\nbar\nbaz\n");

  $file;
}

sub grep_with_string : Test {
  my $class = shift;

  my $file = $class->prepare_file;

  my @lines = $file->grep('bar');
  ok @lines == 1 && $lines[0] eq "bar\n", $class->message;

  $file->unlink;
}

sub grep_with_regex : Test {
  my $class = shift;

  my $file = $class->prepare_file;

  my @lines = $file->grep(qr/^b/);
  ok @lines == 2 && $lines[0] eq "bar\n", $class->message;

  $file->unlink;
}


1;
