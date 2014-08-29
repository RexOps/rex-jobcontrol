package Rex::JobControl::Project;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub prepare_stash {
  my $self = shift;

  my $project = $self->project($self->param("project_dir"));
  $self->stash(project => $project);
}

sub index {
  my $self = shift;
  $self->render;
}

sub project_new {
  my $self = shift;
  $self->render;
}

sub project_new_create {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_name"));

  my $pr = $self->project($self->param("project_name"));
  $pr->create;

  $self->redirect_to("/");
}

sub view {
  my $self = shift;

  $self->prepare_stash;

  $self->render;
}

1;