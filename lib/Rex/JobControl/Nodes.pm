package Rex::JobControl::Nodes;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index {
  my $self = shift;

  my $project = $self->project( $self->param("project_dir") );
  $self->stash(rexfiles => $project->rexfiles);

  $self->render;
}

1;
