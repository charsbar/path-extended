package Path::Extended::Test::Subclass::Dir;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Test;

sub parents : Tests(3) {
  my $class = shift;

  my $dir = dir('t/tmp/subclass');
  $dir->mkdir;
  ok $dir->exists, $class->message('created tmpdir');

  my $parent = $dir->parent;
  ok $parent->isa('Path::Extended::Test::Dir'), $class->message('parent is a ::Test::Dir');

  my $grandparent = $parent->parent;
  ok $grandparent->isa('Path::Extended::Test::Dir'), $class->message('grand parent is a ::Test::Dir');

  $dir->rmdir;
}

sub children : Tests(7) {
  my $class = shift;

  my $dir = dir('t/tmp/subclass');
  $dir->mkdir;
  ok $dir->exists, $class->message('created tmpdir');

  my $file = $dir->file('file');
  $file->save('content');
  ok $file->exists, $class->message('created file');
  ok $file->isa('Path::Extended::Test::File'), $class->message('file is a ::Test::File');

  my $subdir = $dir->subdir('dir');
  $subdir->mkdir;
  ok $subdir->exists, $class->message('created subdir');
  ok $subdir->isa('Path::Extended::Test::Dir'), $class->message('subdir is a ::Test::Dir');

  foreach my $entry ($dir->children) {
    ok $entry->_class eq 'Path::Extended::Test', $class->message('entry is a Path::Extended::Test child');
  }

  $dir->rmdir;
}

sub next : Tests(9) {
  my $class = shift;

  my $dir = dir('t/tmp/subclass');
  $dir->mkdir;
  ok $dir->exists, $class->message('created tmpdir');

  my $file = $dir->file('file');
  $file->save('content');
  ok $file->exists, $class->message('created file');
  ok $file->isa('Path::Extended::Test::File'), $class->message('file is a ::Test::File');

  my $subdir = $dir->subdir('dir');
  $subdir->mkdir;
  ok $subdir->exists, $class->message('created subdir');
  ok $subdir->isa('Path::Extended::Test::Dir'), $class->message('subdir is a ::Test::Dir');

  while( my $entry = $dir->next ) {
    ok $entry->_class eq 'Path::Extended::Test', $class->message('entry is a Path::Extended::Test child');
  }

  $dir->rmdir;
}

sub find : Tests(6) {
  my $class = shift;

  my $dir = dir('t/tmp/subclass');
  $dir->mkdir;
  ok $dir->exists, $class->message('created tmpdir');

  my $file = $dir->file('file');
  $file->save('content');
  ok $file->exists, $class->message('created file');
  ok $file->isa('Path::Extended::Test::File'), $class->message('file is a ::Test::File');

  my $subdir = $dir->subdir('dir');
  $subdir->mkdir;
  ok $subdir->exists, $class->message('created subdir');
  ok $subdir->isa('Path::Extended::Test::Dir'), $class->message('subdir is a ::Test::Dir');

  foreach my $file ( $dir->find('*') ) {
    ok $file->_class eq 'Path::Extended::Test', $class->message('entry is a Path::Extended::Test child');
  }

  $dir->rmdir;
}

sub find_dir : Tests(6) {
  my $class = shift;

  my $dir = dir('t/tmp/subclass');
  $dir->mkdir;
  ok $dir->exists, $class->message('created tmpdir');

  my $file = $dir->file('file');
  $file->save('content');
  ok $file->exists, $class->message('created file');
  ok $file->isa('Path::Extended::Test::File'), $class->message('file is a ::Test::File');

  my $subdir = $dir->subdir('dir');
  $subdir->mkdir;
  ok $subdir->exists, $class->message('created subdir');
  ok $subdir->isa('Path::Extended::Test::Dir'), $class->message('subdir is a ::Test::Dir');

  foreach my $subdir ( $dir->find_dir('*') ) {
    ok $subdir->_class eq 'Path::Extended::Test', $class->message('entry is a Path::Extended::Test child');
  }

  $dir->rmdir;
}

END { dir('t/tmp')->remove; }

1;
