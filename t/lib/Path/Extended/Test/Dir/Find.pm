package Path::Extended::Test::Dir::Find;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub find : Tests(7) {
  my $class = shift;

  my $dir = dir('t/tmp/find')->mkdir;
  ok $dir->exists, $class->message('created '.$dir->relative);

  my $file1 = file('t/tmp/find/some.txt');
     $file1->save('some content');
  ok $file1->exists, $class->message('created '.$file1->relative);

  my $file2 = file('t/tmp/find/other.txt');
     $file2->save('other content');
  ok $file2->exists, $class->message('created '.$file2->relative);

  my @files = $dir->find('*.txt');
  ok @files, $class->message('found '.(scalar @files).' files');

  ok((grep { defined $_ and $_->isa('Path::Extended::File') } @files),
    $class->message('files are Path::Extended::File objects'));

  my @should_not_be_found = $dir->find('*.jpeg');
  ok @should_not_be_found == 0, $class->message('found nothing');

  my @filtered = $dir->find('*.txt',
    callback => sub { grep { $_ =~ /some/ } @_ }
  );
  ok @filtered && $filtered[0]->basename eq 'some.txt',
    $class->message('found some.txt');

  $dir->rmdir;
}

sub find_dir : Tests(6) {
  my $class = shift;

  my $dir  = dir('t/tmp/find_dir');
  my $dir1 = dir('t/tmp/find_dir/found')->mkdir;
  ok $dir1->exists, $class->message('created '.$dir1->relative);

  my $dir2 = dir('t/tmp/find_dir/not_found')->mkdir;
  ok $dir2->exists, $class->message('created '.$dir2->relative);

  my $rule = '*';

  my @dirs = $dir->find_dir($rule);
  ok @dirs, $class->message('found '.(scalar @dirs).' directories');

  ok((grep { defined $_ and $_->isa('Path::Extended::Dir') } @dirs),
    $class->message('directories are Path::Extended::Dir objects'));

  my @should_not_be_found = $dir->find('yes');
  ok @should_not_be_found == 0, $class->message('found nothing');

  my @filtered = $dir->find_dir($rule,
    callback => sub { grep { $_ =~ /not/ } @_ }
  );
  ok @filtered, $class->message('found '.($filtered[0] ? $filtered[0]->relative : 'nothing'));

  $dir->rmdir;
}

sub private_error : Test {
  my $class = shift;

  my $dir = dir('t/tmp');
  ok !$dir->_find( dir => '*' ), $class->message('invalid type');
}

1;
