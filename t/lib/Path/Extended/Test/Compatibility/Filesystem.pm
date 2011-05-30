package Path::Extended::Test::Compatibility::Filesystem;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Class;
use File::Temp qw/tmpnam tempdir/;

# ripped from Path::Class' t/03-filesystem.t

sub initialize { $Path::Extended::IgnoreVolume = 1; }
sub finalize   { $Path::Extended::IgnoreVolume = 0; }

sub tests00_file : Tests(9) {
  my $class = shift;

  my $file = file(scalar tmpnam());
  ok $file, $class->message("test 02");

  {
    my $fh = $file->open('w');
    ok $fh, $class->message("test 03");
    ok( (print $fh "Foo\n"), $class->message("test 04"));
  }

  ok -e $file, $class->message("test 05");

  {
    my $fh = $file->open;
    is scalar <$fh>, "Foo\n", $class->message("test 06");
  }

  my $stat = $file->stat;
  ok $stat, $class->message("test 07");
  cmp_ok $stat->mtime, '>', time() - 20, $class->message("test 08");

  $stat = $file->dir->stat;
  ok $stat, $class->message("test 09");

  1 while unlink $file;
  ok( (not -e $file), $class->message("test 10"));
}

sub tests01_dir : Tests(33) {
  my $class = shift;

  my $dir = dir(tempdir(CLEANUP => 1));
  ok $dir, $class->message("test 11");
  ok -d $dir, $class->message("test 13");

  my $file = $dir->file('foo.x');
  $file->touch;
  ok -e $file, $class->message("test 14");

  {
    my $dh = $dir->open;
    ok $dh, $class->message("test 15");

    my @files = readdir $dh;
    is scalar @files, 3, $class->message("test 16");
    ok( (scalar grep { $_ eq 'foo.x' } @files), $class->message("test 17"));
  }

  ok $dir->rmtree, $class->message("test 18");
  ok !-e $dir, $class->message("test 19");

  $dir = dir('t', 'foo', 'bar');
  $dir->parent->rmtree if $dir->parent->exists;

  ok $dir->mkpath, $class->message("test 20");
  ok -d $dir, $class->message("test 21");

  $dir = $dir->parent;
  ok $dir->rmtree, $class->message("test 22");
  ok !-e $dir, $class->message("test 23");

  $dir = dir('t', 'foo');
  ok $dir->mkpath, $class->message("test 24");
  ok $dir->subdir('dir')->mkpath, $class->message("test 25");
  ok -d $dir->subdir('dir'), $class->message("test 26");

  ok $dir->file('file.x')->touch, $class->message("test 27");
  ok $dir->file('0')->touch, $class->message("test 28");
  my @contents;
  while (my $file = $dir->next) {
    push @contents, $file;
  }
  is scalar @contents, 5, $class->message("test 29");

  my $joined = join ' ', map $_->basename, sort grep {-f $_} @contents;
  is $joined, '0 file.x', $class->message("test 30");

  my ($subdir) = grep {$_ eq $dir->subdir('dir')} @contents;
  ok $subdir, $class->message("test 31");
  is -d $subdir, 1, $class->message("test 32");

  ($file) = grep {$_ eq $dir->file('file.x')} @contents;
  ok $file, $class->message("test 33");
  is -d $file, '', $class->message("test 34");

  ok $dir->rmtree, $class->message("test 35");
  ok !-e $dir, $class->message("test 36");

  # Try again with directory called '0', in curdir
  my $orig = dir()->absolute;

  ok $dir->mkpath, $class->message("test ex 01");
  ok chdir($dir), $class->message("test ex 02");
  my $dir2 = dir();
  ok $dir2->subdir('0')->mkpath, $class->message("test ex 03");
  ok -d $dir2->subdir('0'), $class->message("test ex 04");

  @contents = ();
  while (my $file = $dir2->next) {
    push @contents, $file;
  }
  ok grep({$_ eq '0'} @contents), $class->message("test ex 05");

  ok chdir($orig), $class->message("test ex 06");
  ok $dir->rmtree, $class->message("test ex 07");
  ok !-e $dir, $class->message("test ex 08");
}

sub tests02_slurp : Tests(6) {
  my $class = shift;

  my $file = file('t', 'slurp');
  ok $file, $class->message("test 37");

  my $fh = $file->open('w') or die "Can't create $file: $!";
  print $fh "Line1\nLine2\n";
  close $fh;
  ok -e $file, $class->message("test 38");

  my $content = $file->slurp;
  is $content, "Line1\nLine2\n", $class->message("test 39");

  my @content = $file->slurp;
  is_deeply \@content, ["Line1\n", "Line2\n"], $class->message("test 40");

  @content = $file->slurp(chomp => 1);
  is_deeply \@content, ["Line1", "Line2"], $class->message("test 41");

  $file->remove;
  ok((not -e $file), $class->message("test 42"));
}

sub tests02_slurp_iomode : Tests(6) {  # added
  my $class = shift;

  return $class->skip_this_test("IO modes not available until perl 5.7.1") unless $^V ge v5.7.1;

  my $file = file('t', 'slurp');
  ok $file, $class->message("test 37'");

  my $fh = $file->open('>:raw') or die "Can't create $file: $!";
  print $fh "Line1\r\nLine2\r\n\302\261\r\n";
  close $fh;
  ok -e $file, $class->message("test 38'");

  my $content = $file->slurp(iomode => '<:raw');
  is $content, "Line1\r\nLine2\r\n\302\261\r\n", $class->message("test 39'");

  my $line3 = "\302\261\n";
  utf8::decode($line3);
  my @content = $file->slurp(iomode => '<:crlf:utf8');
  is_deeply \@content, ["Line1\n", "Line2\n", $line3], $class->message("test 40'");

  chop $line3;
  @content = $file->slurp(chomp => 1, iomode => '<:crlf:utf8');
  is_deeply \@content, ["Line1", "Line2", $line3], $class->message("test 41'");

  $file->remove;
  ok((not -e $file), $class->message("test 42'"));
}

sub test03_absolute_relative : Test Skip('known incompatibility') {
  my $class = shift;

  my $cwd = dir();
  is $cwd, $cwd->absolute->relative, $class->message("test 43");
}

sub tests04_subsumes : Tests(4) {
  my $class = shift;

  my $t = dir('t');
  my $foo_bar = $t->subdir('foo','bar');
  $foo_bar->rmtree;

  ok  $t->subsumes($foo_bar), $class->message("test 44");
  ok !$t->contains($foo_bar), $class->message("test 45");

  $foo_bar->mkpath;
  ok  $t->subsumes($foo_bar), $class->message("test 46");
  ok  $t->contains($foo_bar), $class->message("test 47");

  $t->subdir('foo')->rmtree;
}

sub tests05_recurse : Tests(17) {
  my $class = shift;

  (my $abe = dir(qw(a b e)))->mkpath;
  (my $acf = dir(qw(a c f)))->mkpath;
  file($acf, 'i')->touch;
  file($abe, 'h')->touch;
  file($abe, 'g')->touch;
  file('a', 'b', 'd')->touch;

  my $d = dir('a');
  my @children = sort $d->children; # following test breaks sometimes

  is_deeply \@children, ['a/b', 'a/c'];

  {
    recurse_test( $d,
      preorder => 1, depthfirst => 0,  # The default
      precedence => [qw(
        a           a/b
        a           a/c
        a/b         a/b/e/h
        a/b         a/c/f/i
        a/c         a/b/e/h
        a/c         a/c/f/i
      )],
    );
  }

  {
    my $files = 
      recurse_test( $d,
        preorder => 1, depthfirst => 1,
        precedence => [qw(
          a           a/b
          a           a/c
          a/b         a/b/e/h
          a/c         a/c/f/i
        )],
      );
    is_depthfirst($files);
  }

  {
    my $files = 
      recurse_test( $d,
        preorder => 0, depthfirst => 1,
        precedence => [qw(
          a/b         a
          a/c         a
          a/b/e/h     a/b
          a/c/f/i     a/c
        )],
      );
    is_depthfirst($files);
  }

  $d->rmtree;

  sub is_depthfirst {
    my $files = shift;
    if ($files->{'a/b'} < $files->{'a/c'}) {
      cmp_ok $files->{'a/b/e'}, '<', $files->{'a/c'}, "Ensure depth-first search";
    } else {
      cmp_ok $files->{'a/c/f'}, '<', $files->{'a/b'}, "Ensure depth-first search";
    }
  }

  sub recurse_test {
    my ($dir, %args) = @_;
    my $precedence = delete $args{precedence};
    my ($i, %files) = (0);
    $dir->recurse( callback => sub {$files{shift->as_foreign('Unix')->stringify} = ++$i},
		 %args );
    while (my ($pre, $post) = splice @$precedence, 0, 2) {
      cmp_ok $files{$pre}, '<', $files{$post}, "$pre should come before $post";
    }
    return \%files;
  }
}

sub END {
  my $class = shift;

  dir('a')->rmtree;
  dir('t/foo')->remove;
  dir('t/testdir')->remove;
  file('t/testfile')->remove;
}

1;
