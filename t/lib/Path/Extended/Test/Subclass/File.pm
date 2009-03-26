package Path::Extended::Test::Subclass::File;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Test;

sub parents : Tests(3) {
  my $class = shift;

  my $file = file('t/tmp/subclass/file');
  $file->save('content', mkdir => 1);
  ok $file->exists, $class->message('created tmpfile');

  my $parent = $file->parent;
  ok $parent->isa('Path::Extended::Test::Dir'), $class->message('parent is a ::Test::Dir');

  my $grandparent = $parent->parent;
  ok $grandparent->isa('Path::Extended::Test::Dir'), $class->message('grand parent is a ::Test::Dir');

  dir('t/tmp')->rmdir;
}

END { dir('t/tmp')->remove; }

1;
