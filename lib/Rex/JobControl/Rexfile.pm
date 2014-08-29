#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Rexfile;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  $self->render;
}

sub rexfile_new {
  my $self = shift;
  $self->render;
}

sub rexfile_new_create {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_dir"));
  $self->app->log->debug("Got rexfile name: " . $self->param("rexfile_name"));

  my $pr = $self->project($self->param("project_dir"));
  $pr->create_rexfile(directory => $self->param("rexfile_name"), url => $self->param("rexfile_url"));

  $self->redirect_to("/project/" . $self->param("project_dir"));
}

sub view {
  my $self = shift;

  my $project = $self->project($self->param("project_dir"));
  my $rexfile = $project->get_job($self->param("rexfile_dir"));

  $self->stash(project => $project);
  $self->stash(rexfile => $rexfile);

  $self->render;
}

1;
