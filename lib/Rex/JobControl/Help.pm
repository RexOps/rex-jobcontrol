package Rex::JobControl::Help;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index {
  my $self = shift;
  $self->render;
}

1;
