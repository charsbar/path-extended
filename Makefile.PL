use strict;
use warnings;
use ExtUtils::MakeMaker;
use 5.006;

WriteMakefile(
  NAME          => 'Path::Extended',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/Path/Extended.pm',
  ABSTRACT_FROM => 'lib/Path/Extended.pm',
  PREREQ_PM => {
    'Carp'                  => 0,
    'Encode'                => 0,
    'Fcntl'                 => 0,
    'File::Basename'        => 0,
    'File::Copy::Recursive' => 0,
    'File::Find::Rule'      => 0,
    'File::Path'            => 0,
    'File::Spec'            => 3.23,
    'File::stat'            => 1.0,
    'IO'                    => 1.23,
    'Log::Dump'             => 0,
    'Scalar::Util'          => 0,
    'Sub::Install'          => 0,
    'Test::Classy'          => '0.04',
    'Test::More'            => '0.47',
    'Test::UseAllModules'   => '0.09',
  },
  ($ExtUtils::MakeMaker::VERSION >= 6.31
    ? ( LICENSE => 'perl' )
    : ()
  ),
);
