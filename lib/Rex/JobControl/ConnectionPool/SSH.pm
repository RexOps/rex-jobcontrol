#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;
use warnings;

package Rex::JobControl::ConnectionPool::SSH;

use Moo;
use Carp;
use Rex -feature => ['0.55'];

has connections => ( is => 'rwp', default => sub { {} } );

sub add_connection {
  my ( $self, $name, %opts ) = @_;

  my $conn = Rex::connect(%opts);
  $self->connections->{$name} = $conn;
}

sub has_connection {
  my ( $self, $name ) = @_;

  if ( exists $self->connections->{$name} ) {
    return 1;
  }
}

sub use_connection {
  my ( $self, $name, %opts ) = @_;

  if ( exists $self->connections->{$name} ) {
    Rex::connect( cached_connection => $self->connections->{$name} );
  }
  else {
    confess "No connection found: $name.";
  }
}

1;
