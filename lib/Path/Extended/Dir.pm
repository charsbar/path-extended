package Path::Extended::Dir;

use strict;
use warnings;
use base qw( Path::Extended::Entity );
use Path::Extended::File;

sub _initialize {
  my ($self, @args) = @_;

  my $dir = @args ? File::Spec->catdir( @args ) : File::Spec->curdir;

  $self->{_absolute} = 1; # always true for ::Extended::Dir
  $self->{is_dir}    = 1;
  $self->{path}      = $self->_unixify( File::Spec->rel2abs($dir) );

  $self;
}

sub new_from_file {
  my ($class, $file) = @_;

  require File::Basename;
  my $dir = File::Basename::dirname( $file );

  my $self = $class->new( $dir );
}

sub _parts {
  my ($self, $abs) = @_;

  my $path = $abs ? $self->absolute : $self->path;
  my ($vol, $dir, $file) = File::Spec->splitpath( $path );
  return split '/', "$dir$file";
}

sub basename {
  my $self = shift;

  return ($self->_parts)[-1];
}

sub open {
  my $self = shift;

  $self->close if $self->is_open;

  opendir my $dh, $self->absolute
    or do { $self->log( error => $! ); return; };

  return $dh if $self->{_compat} && defined wantarray;

  $self->{handle} = $dh;

  $self;
}

sub close {
  my $self = shift;

  if ( my $dh = delete $self->{handle} ) {
    closedir $dh;
  }
}

sub read {
  my $self = shift;

  return unless $self->is_open;

  my $dh = $self->_handle;
  readdir $dh;
}

sub seek {
  my ($self, $pos) = @_;

  return unless $self->is_open;

  my $dh = $self->_handle;
  seekdir $dh, $pos || 0;
}

sub tell {
  my $self = shift;

  return unless $self->is_open;

  my $dh = $self->_handle;
  telldir $dh;
}

sub rewind {
  my $self = shift;

  return unless $self->is_open;

  my $dh = $self->_handle;
  rewinddir $dh;
}

sub find {
  my ($self, $rule, %options) = @_;

  $self->_find( file => $rule, %options );
}

sub find_dir {
  my ($self, $rule, %options) = @_;

  $self->_find( directory => $rule, %options );
}

sub _find {
  my ($self, $type, $rule, %options) = @_;

  return unless $type =~ /^(?:directory|file)$/;

  require File::Find::Rule;

  my @items = grep { $_->relative($self->absolute) !~ m{/\.} }
              map  { $self->_related( $type, $_ ) }
              File::Find::Rule->$type->name($rule)->in($self->absolute);

  if ( $options{callback} ) {
    @items = $options{callback}->( @items );
  }

  return @items;
}

sub rmdir {
  my $self = shift;

  $self->close if $self->is_open;

  if ( $self->exists ) {
    require File::Path;
    eval { File::Path::rmtree( $self->absolute ) };
    do { $self->log( error => $@ ); return; } if $@;
  }
  $self;
}

*rmtree = *remove = \&rmdir;

sub mkdir {
  my $self = shift;

  unless ( $self->exists ) {
    require File::Path;
    eval { File::Path::mkpath( $self->absolute ) };
    do { $self->log( error => $@ ); return; } if $@;
  }
  $self;
}

*mkpath = \&mkdir;

sub next {
   my $self = shift;

  $self->open unless $self->is_open;
  my $next = $self->read;
  unless ( defined $next ) {
    $self->close;
    return;
  }
  if ( -d File::Spec->catdir( $self->absolute, $next ) ) {
    return $self->_related( dir => $next );
  }
  else {
    return $self->_related( file => $next );
  }
}

sub file   { shift->_related( file => @_ ); }
sub subdir { shift->_related( dir  => @_ ); }

sub file_or_dir {
  my ($self, @args) = @_;

  my $file = $self->_related( file => @args );
  return $self->_related( dir => @args ) if -d $file->absolute;
  return $file;
}

sub dir_or_file {
  my ($self, @args) = @_;

  my $dir = $self->_related( dir => @args );
  return $self->_related( file => @args ) if -f $dir->absolute;
  return $dir;
}

sub children {
  my ($self, %options) = @_;

  my $dh = $self->open or Carp::croak "Can't open directory $self: $!";

  my @children;
  while ( my $entry = readdir $dh ) {
    next if (!$options{all} && ( $entry eq '.' || $entry eq '..' ));
    my $type = ( -d File::Spec->catdir($self->absolute, $entry) )
               ? 'dir' : 'file';
    my $child = $self->_related( $type => $entry );
    if ($options{prune}) {
      if (ref $options{prune} eq 'Regexp') {
        next if $entry =~ /$options{prune}/;
      }
      elsif (ref $options{prune} eq 'CODE') {
        next if $options{prune}->($child);
      }
      else {
        next if $entry =~ /^\./;
      }
    }
    push @children, $child;
  }
  $self->close;
  return @children;
}

sub recurse { # adapted from Path::Class::Dir
  my $self = shift;
  my %opts = (preorder => 1, depthfirst => 0, prune => 1, @_);

  my $callback = $opts{callback}
    or Carp::croak "Must provide a 'callback' parameter to recurse()";

  my @queue = ($self);

  my $visit_entry;
  my $visit_dir = 
    $opts{depthfirst} && $opts{preorder}
    ? sub {
      my $dir = shift;
      $callback->($dir);
      unshift @queue, $dir->children( prune => $opts{prune} );
    }
    : $opts{preorder}
    ? sub {
      my $dir = shift;
      $callback->($dir);
      push @queue, $dir->children( prune => $opts{prune} );
    }
    : sub {
      my $dir = shift;
      $visit_entry->($_) for $dir->children( prune => $opts{prune} );
      $callback->($dir);
    };

  $visit_entry = sub {
    my $entry = shift;
    if ($entry->is_dir) { $visit_dir->($entry) }
    else { $callback->($entry) }
  };

  while (@queue) {
    $visit_entry->( shift @queue );
  }
}

1;

__END__

=head1 NAME

Path::Extended::Dir

=head1 SYNOPSIS

  use Path::Extended::Dir;

  my $dir = Path::Extended::Dir->new('path/to/somewhere');
  my $parent_dir = Path::Extended::Dir->new_from_file('path/to/some.file');

  foreach my $file ( $dir->find('*.txt') ) {
    print $file->relative, "\n";  # each $file is a L<Path::Extended::File> object.
  }

=head1 DESCRIPTION

This class implements several directory-specific methods. See also L<Path::Class::Entity> for common methods like copy and move.

=head1 METHODS

=head2 new, new_from_file

takes a path or parts of a path of a directory (or a file in the case of C<new_from_file>), and creates a L<Path::Extended::Dir> object. If the path specified is a relative one, it will be converted to the absolute one internally. 

=head2 basename

returns the last part of the directory.

=head2 open, close, read, seek, tell, rewind

are simple wrappers of the corresponding built-in functions (with the trailing 'dir').

=head2 mkdir, mkpath

makes the directory via C<File::Path::mkpath>.

=head2 rmdir, rmtree, remove

removes the directory via C<File::Path::rmtree>.

=head2 find, find_dir

takes a L<File::Find::Rule>'s rule and a hash option, and returns C<Path::Extended::*> objects of the matched files (C<find>) or directories (C<find_dir>) under the directory the $self object points to. Options are:

=over 4

=item callback

You can pass a code reference to filter the objects.

=back

=head2 next

  while (my $file = $dir->next) {
    next unless -f $file;
    $file->openr or die "Can't read $file: $!";
    ...
  }

returns a L<Path::Extended::Dir> or L<Path::Extended::File> object while iterating through the directory (or C<undef> when there's no more items there). The directory will be open with the first C<next>, and close with the last C<next>.

=head2 children

returns a list of L<Path::Extended::Class::File> and/or L<Path::Extended::Class::Dir> objects listed in the directory. See L<Path::Class::Dir> for details.

As of 0.13, this may take a C<prune> option to exclude some of the children. See below for details.

=head2 file, subdir

returns a child L<Path::Extended::Class::File>/L<Path::Extended::Class::Dir> object in the directory.

=head2 file_or_dir

takes a file/subdirectory path and returns a L<Path::Extended::File> object if it doesn't point to an existing directory (if it does point to a directory, it returns a L<Path::Extended::Dir> object). This is handy if you don't know a path is a file or a directory. You can tell which is the case by calling ->is_dir method (if it's a file, ->is_dir returns false, otherwise true).

=head2 dir_or_file

does the same above but L<Path::Extended::Dir> has precedence.

=head2 recurse

  dir('path/to/somewhere')->recurse( callback => sub {
    my $file_or_dir = shift;
    ...
  });

takes a hash and iterates through the directory and all its subdirectories recursively, and call the callback function for each entry. Options are:

=over 4

=item callback

a code reference to call for each entry.

=item depthfirst, preorder

flags to change the order of processing.

=item prune

As of 0.13, you can use this option to prune some of the directory tree. You can provide a regular expression, a code reference, or a boolean value:

  # all the dot files/directories will be pruned (current default)
  $dir->recurse( prune => 1, callback => sub { ... });

  # nothing will be pruned (previous default)
  $dir->recurse( prune => 0, callback => sub { ... });

  # files/directories whose "basename" has a ".bak" suffix
  # will be pruned
  $dir->recurse( prune => qr/\.bak$/, callback => sub { ... });

  # ditto
  $dir->recurse( prune => \&prune, callback => sub { ... });

  sub prune {
    my $entry = shift;
    return $entry->basename =~ /\.bak$/ ? 1 : 0;
  }

=back

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
