package Mojolicious::Command::jobcontrol;

use Mojo::Base 'Mojolicious::Command';

use Data::Dumper;
use Digest::Bcrypt;
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'JobControl Commands';
has usage => sub { shift->extract_usage };

sub run {
  my ( $self, $command, @args ) = @_;

  if ( !$command || $command eq "help" ) {
    print "Usage:\n";
    print "$0 jobcontrol <command> [<options>]\n";
    print "\n";
    print "adduser -u username -p password        will add a new user\n";
    print "deluser -u username                    will delete a user\n";
    print "listuser                               list all users\n";
    exit 0;
  }

  if ( $command eq "adduser" ) {
    my ( $user, $password );

    GetOptionsFromArray \@args,
      'u|user=s'     => sub { $user     = $_[1] },
      'p|password=s' => sub { $password = $_[1] };

    $self->app->log->debug("Creating new user $user with password $password");

    my $salt = $self->app->config->{auth}->{salt};
    my $cost = $self->app->config->{auth}->{cost};

    my $bcrypt = Digest::Bcrypt->new;
    $bcrypt->salt($salt);
    $bcrypt->cost($cost);
    $bcrypt->add($password);

    my $pw = $bcrypt->hexdigest;

    open( my $fh, ">>", $self->app->config->{auth}->{passwd} ) or die($!);
    print $fh "$user:$pw\n";
    close($fh);
  }

  if ( $command eq "deluser" ) {

    my $user;

    GetOptionsFromArray \@args, 'u|user=s' => sub { $user = $_[1] };

    my @lines =
      grep { !m/^$user:/ }
      eval { local (@ARGV) = ( $self->app->config->{auth}->{passwd} ); <>; };

    open( my $fh, ">", $self->app->config->{auth}->{passwd} ) or die($!);
    print $fh join( "\n", @lines );
    close($fh);
  }

  if ( $command eq "listuser" ) {
    my @lines =
      eval { local (@ARGV) = ( $self->app->config->{auth}->{passwd} ); <>; };
    chomp @lines;

    for my $l (@lines) {
      my ( $user, $pass ) = split( /:/, $l );
      print "> $user\n";
    }
  }

}

1;
