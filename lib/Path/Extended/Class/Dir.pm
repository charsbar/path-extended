package Path::Extended::Class::Dir;

use strict;
use warnings;
use base qw( Path::Extended::Dir );

sub _initialize {
  my ($self, @args) = @_;

  return if @args && !defined $args[0];

  my $dir = @args ? File::Spec->catdir( @args ) : File::Spec->curdir;

  $self->{path}      = $self->_unixify( File::Spec->rel2abs($dir) );
  $self->{is_dir}    = 1;
  $self->{_compat}   = 1;
  $self->{_absolute} = File::Spec->file_name_is_absolute( $dir );

  $self;
}

sub new_foreign {
  my ($class, $type, @args) = @_;
  $class->new(@args);
}

sub cleanup    { shift } # is always clean
sub as_foreign { shift } # does nothing

sub dir_list {
  my $self = shift;

  my @parts = $self->_parts;
  return @parts unless @_;

  my $offset = shift;
  $offset = @parts + $offset if $offset < 0;

  return wantarray ? @parts[$offset .. $#parts] : $parts[$offset] unless @_;

  my $length = shift;
  $length = @parts + $length - $offset if $length < 0;
  return @parts[$offset .. $length + $offset - 1];
}

sub tempfile {
  my $self = shift;
  require File::Temp;
  return File::Temp::tempfile(@_, DIR => $self->stringify);
}

1;

__END__

=head1 NAME

Path::Extended::Class::Dir

=head1 DESCRIPTION

L<Path::Extended::Class::Dir> behaves pretty much like L<Path::Class::Dir> and can do some extra things. See appropriate pods for details.

=head1 COMPATIBLE METHODS

=head2 dir_list

returns parts of the path. See L<Path::Class::Dir> for details.

=head2 tempfile

returns a temporary file handle (and its corresponding file name in a list context). See L<Path::Class::Dir> and L<File::Temp> for details

=head1 INCOMPATIBLE METHODS

=head2 cleanup

does nothing but returns the object to chain. L<Path::Extended::Class> should always return a canonical path.

=head2 as_foreign

does nothing but returns the object to chain. L<Path::Extended::Class> doesn't support foreign path expressions.

=head2 new_foreign

returns a new L<Path::Extended::Class::Dir> object whatever the type is specified.

=head1 SEE ALSO

L<Path::Extended::Class>, L<Path::Extended::Dir>, L<Path::Class::Dir>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
