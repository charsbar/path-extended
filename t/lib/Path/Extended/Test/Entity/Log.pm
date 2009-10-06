package Path::Extended::Test::Entity::Log;

use strict;
use warnings;
use Test::Classy::Base;
use Path::Extended::Entity;

sub no_logger : Test {
  my $class = shift;

  my $entity = Path::Extended::Entity->new;

  ok !$entity->{logger}, $class->message('no logger by default');
}

sub custom_logger : Test {
  my $class = shift;

  my $entity = Path::Extended::Entity->new;

  $entity->logger( MyTestLogger->new );

  ok $entity->log( level => 'message' ) eq 'levelmessage',
    $class->message('custom logger is used');
}

sub invalid_loggers : Test {
  my $class = shift;

  my %loggers = (
    broken => MyBrokenTestLogger->new,
#   class  => 'MyTestLogger',  # as Log::Dump allows class logger
  );

  foreach my $logger ( keys %loggers ) {
    my $entity = Path::Extended::Entity->new;
       $entity->logger($loggers{$logger});

    eval { $entity->log( fatal => 'message' ) };
    ok $@ =~ /\[fatal\] message/,
      $class->message("$logger logger falls back to the default");
  }
}

sub fatal_log : Test {
  my $class = shift;

  my $entity = Path::Extended::Entity->new;
  eval { $entity->log( fatal => 'message' ) };
  ok $@ =~ /\[fatal\] message/,
    $class->message('proper fatal message');
}

sub logs_to_stderr : Tests(3) {
  my $class = shift;

  eval { require Capture::Tiny };
  return $class->skip_this_test('this test requires Capture::Tiny') if $@;

  my $entity = Path::Extended::Entity->new;

  foreach my $level (qw( debug warn error )) {
    my ($out, $err) = Capture::Tiny::capture(sub {
      $entity->log( $level => { message => 'message' } );
    });

    # single quotations will be converted to double while dumping
    ok $err =~ /\[$level\] { message => "message" }/, 
      $class->message("proper $level message");
  }
}

package MyTestLogger;

sub new { bless {}, shift; }
sub log { shift; return join '', @_ }

package MyBrokenTestLogger;

sub new { bless {}, shift; }

1;
