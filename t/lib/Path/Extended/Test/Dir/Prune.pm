package Path::Extended::Test::Dir::Prune;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub prune : Tests(5) {
  my $class = shift;

  my @expected = qw(
    prune
    prune/file
    prune/dir
    prune/dir/file
  );

  $class->_prune_test(1, @expected);
}

sub no_prune : Tests(10) {
  my $class = shift;

  my @expected = qw(
    prune
    prune/.dot
    prune/.ignore
    prune/dir
    prune/file
    prune/.dot/.dotfile
    prune/.dot/file
    prune/dir/.dotfile
    prune/dir/file
  );

  $class->_prune_test(0, @expected);
}

sub prune_by_regex : Tests(7) {
  my $class = shift;

  my @expected = qw(
    prune
    prune/.ignore
    prune/dir
    prune/file
    prune/dir/.dotfile
    prune/dir/file
  );

  $class->_prune_test(qr/^\.dot$/, @expected);
}

sub prune_by_code : Tests(7) {
  my $class = shift;

  my @expected = qw(
    prune
    prune/.dot
    prune/.ignore
    prune/file
    prune/.dot/.dotfile
    prune/.dot/file
  );

  $class->_prune_test(sub { return shift->basename eq 'dir' ? 1 : 0 }, @expected);
}

sub _prune_test {
  my ($class, $rule, @expected) = @_;

  my $root = dir('t/prune');
     $root->mkdir;
     $root->file('.ignore')->touch;
     $root->file('file')->touch;

  foreach my $dirname (qw( .dot dir )) {
    my $dir = $root->subdir($dirname);
    $dir->mkdir;
    $dir->file('.dotfile')->touch;
    $dir->file('file')->touch;
  }

  my @found;
  $root->recurse( prune => $rule, callback => sub {
    push @found, shift->relative($root->parent);
  });
  ok @found == @expected, $class->message("found ".@found." items");

  foreach my $item (@found) {
    my $is_found = grep { $_ eq $item } @expected;
    ok $is_found, $class->message("found $item");
  }

  $root->remove;
}

1;
