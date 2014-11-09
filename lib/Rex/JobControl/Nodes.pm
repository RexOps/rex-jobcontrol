package Rex::JobControl::Nodes;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index {
  my ($self) = @_;

  my $project = $self->project( $self->param("project_dir") );
  $self->stash( rexfiles => $project->rexfiles );
  my $nodegroups = $project->nodegroups;

  $self->stash( firstgroup => $nodegroups->[0] );

  $self->render;
}

sub add_node {
  my ($self) = @_;

  my $project = $self->project( $self->param("project_dir") );
  $project->add_node( { name => $self->param("nodename") } );

  $self->redirect_to( "/project/" . $project->directory );
}

sub get_nodes_from_group {
  my ($self) = @_;

  my $project = $self->project( $self->param("project_dir") );
  my $nodegroup = $project->get_nodegroup( $self->param("nodegroup_id") );

  my $nodes = $nodegroup->get_nodes;

  my @ret;

  for my $node ( @{$nodes} ) {
    push @ret, [ $node->{name}, ];
  }

  $self->render( json => { data => \@ret } );
}

1;
