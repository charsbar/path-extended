package Path::Extended;

use strict;
use warnings;
use Sub::Install;

our $VERSION = '0.10';

sub import {
  my ($class, @imports) = @_;

  my $caller = caller;

  @imports = qw( file dir ) unless @imports;
  foreach my $import (@imports) {
    next unless $import =~ /^(?:file|dir)$/;
    my $target = $class.'::'.ucfirst($import);
    eval "require $target" or die $@;
    Sub::Install::install_sub({
      as   => $import,
      into => $caller,
      code => sub { $target->new(@_) },
    });
    Sub::Install::reinstall_sub({
      as   => $import,
      into => $class,
      code => sub { $target->new(@_) },
    });
  }
}

1;

__END__

=head1 NAME

Path::Extended - yet another Path class

=head1 SYNOPSIS

    use Path::Extended;
    my $file = file('path/to/file.txt');
    my $dir  = dir('path/to/somewhere');

=head1 DESCRIPTION

This is yet another file/directory handler that does a bit more than L<Path::Class> for some parts, and a bit less for other parts. One of the main difference is L<Path::Extended> always tries to use forward slashes when possible, ie. even when you're on the MS Windows, so that you don't need to care about escaping paths that annoys you from time to time when you want to apply regexen to a path, especially in file tests that use 'like' or 'compare'.

Also, L<Path::Extended> can do some basic file/directory operations such as copy, move, and rename as well as file I/O stuff like open, close, and slurp (and some of these may behave differently from the equivalents of L<Path::Class>).

On the other hand, L<Path::Extended> doesn't care (or care little) about converting foreign path names or ascending/descending path tree.

In short, this is not for manipulating a path name itself, but for doing some meaningful thing to or with something the path points to.

=head1 CAVEATS

L<Path::Extended> always holds an absolute path of a file/directory internally, even when you pass a relative path (instead of volume/directory/basename combo as L<Path::Class> does). And this is done by File::Spec, which tends to confuse when you set a wrong $^O just to use unix-style path name (as File::Spec fails to determine if the path is relative or not). So, don't pretend.

=head1 FUNCTIONS

Both of these two functions are exported by default.

=head2 file

takes a file name and returns a L<Path::Extended::File> object. The file doesn't need to exist.

=head2 dir

takes a directory name and returns a L<Path::Extended::Dir> object. The directory doesn't need to exist.

=head1 KNOWN LIMITATIONS

Apparently this slash-converting approach of L<Path::Extended> doesn't work under some environments like (older) MacPerl that allow slashes in a file name.

I'm not sure if I should also convert other separators like colons (:) to forward slashes under those environments, though I believe most of you (at least you of programmers) won't use slashes in file names no matter what OSes you use. This conversion may break things sometimes but one of the main aims of this module is not to break tests just because path separators differ, and tests usually don't require OS-specific paths, so I may convert them in the future releases. Patches and suggestions are welcome.

=head1 SEE ALSO

L<Path::Extended::File>, L<Path::Extended::Dir>,

L<Path::Class>, L<Path::Abstract>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
