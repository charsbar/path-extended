package Path::Extended::Test::Dir::Recurse;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended;

sub pm_files : Test {
  my $class = shift;

  my @found;
  dir('lib')->recurse( callback => sub {
    my $item = shift;
    return unless $item->basename =~ /\.pm$/;

    push @found, $item->absolute;
  });

  ok @found == 7, $class->message("found ".@found." items");
}

sub preorder : Tests(5) {
  my $class = shift;

  $class->_recurse_test(
    preorder => 1, depthfirst => 0,
    precedences => [qw(
      a    a/b
      a/b  a/b/e/h
      a/b  a/c/f/i
      a/c  a/b/e/h
      a/c  a/c/f/i
    )],
  );
}

sub preorder_depthfirst : Tests(5) {
  my $class = shift;

  $class->_recurse_test(
    preorder => 1, depthfirst => 1,
    precedences => [qw(
      a    a/b
      a    a/c
      a/b  a/b/e/h
      a/c  a/c/f/i
    )],
  );
}

sub depthfirst : Tests(5) {
  my $class = shift;

  $class->_recurse_test(
    preorder => 0, depthfirst => 1,
    precedences => [qw(
      a/b      a
      a/c      a
      a/b/e/h  a/b
      a/c/f/i  a/c
    )],
  );
}

sub _recurse_test {
  my ($class, %options) = @_;

  my @precedences = @{ delete $options{precedences} };

  my $root = dir('a');
  my $abe = $root->subdir(qw( b e ))->mkdir;
  my $acf = $root->subdir(qw( c f ))->mkdir;
  $acf->file('i')->touch;
  $abe->file('h')->touch;
  $abe->file('g')->touch;
  $root->file(qw( b d ))->touch;

  my %orders;
  my $count = 0;
  $root->recurse( %options, callback => sub {
    my $entry = shift;
    my $rel = $entry->relative($root->parent);
    $orders{$rel} = $count++;
  });

  $root->remove;

  if ($options{depthfirst}) {
    if ($orders{"a/b"} < $orders{"a/c"}) {
      cmp_ok $orders{"a/b/e"}, '<', $orders{"a/c"}, $class->message('ensure depth-first search');
    }
    else {
      cmp_ok $orders{"a/c/f"}, '<', $orders{"a/b"}, $class->message('ensure depth-first search');
    }
  }

  while ( my ($pre, $post) = splice @precedences, 0, 2 ) {
    cmp_ok $orders{$pre}, '<', $orders{$post}, $class->message("$pre should come before $post");
  }
}

1;
