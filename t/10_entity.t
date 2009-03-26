use strict;
use warnings;
use lib 't/lib';
use Test::Classy;
use File::Path;

mkpath('t/tmp');

load_tests_from 'Path::Extended::Test::Entity';

run_tests;

END { rmtree('t/tmp') }
