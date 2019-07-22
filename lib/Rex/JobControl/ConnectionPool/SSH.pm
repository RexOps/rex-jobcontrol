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
has app => (is => 'ro');

sub connect_to {
  my ($self, $server, %data) = @_;

  my $conn_id = $self->_get_connection_id($server, %data);

  if($self->has_connection($conn_id)) {
    $self->use_connection($conn_id);
  }
  else {
    $self->add_connection($server, %data);
  }
}

sub add_connection {
  my ( $self, $name, %opts ) = @_;

  $opts{server} = $name;
  my $conn_id = $self->_get_connection_id($name, %opts);

  $self->app->log->debug("[SSH] Connecting to: $name");

  my $conn = Rex::connect(%opts);
  $self->connections->{$conn_id} = $conn;
}

sub has_connection {
  my ( $self, $name ) = @_;

  if ( exists $self->connections->{$name} ) {
    return 1;
  }
}

sub use_connection {
  my ( $self, $name ) = @_;

  if ( exists $self->connections->{$name} ) {
    Rex::connect( cached_connection => $self->connections->{$name} );
  }
  else {
    confess "No connection found: $name.";
  }
}

sub _get_connection_id {
  my ($self, $name, %opts) = @_;
  return "$name-$opts{user}";
}

1;
