package Path::Extended::Test::Dir::Next;

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

sub next : Tests(4) {
  my $class = shift;

  my $dir = dir('t/tmp/next')->mkdir;

  ok $dir->exists, $class->message('made directory');

  my $file1 = file('t/tmp/next/file1.txt')->save('content1');
  my $file2 = file('t/tmp/next/file2.txt')->save('content2');

  ok !$dir->is_open, $class->message('directory is not open');

  my (@files, @dirs);
  while ( my $item = $dir->next ) {
    push @files, $item if -f $item;
    push @dirs,  $item if -d $item; # including '.' and '..'
  }
  ok @files == 2, $class->message('found two files');

  ok !$dir->is_open, $class->message('directory is not open');

  $dir->rmdir;
}

1;
