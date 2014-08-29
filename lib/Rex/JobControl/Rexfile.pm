#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Rexfile;
use Mojo::Base 'Mojolicious::Controller';

sub prepare_stash {
  my $self = shift;

  my $project = $self->project($self->param("project_dir"));
  $self->stash(project => $project);

  my $rexfile = $project->get_rexfile($self->param("rexfile_dir"));
  $self->stash(rexfile => $rexfile);
}

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
  $pr->create_rexfile(
    directory   => $self->param("rexfile_name"),
    url         => $self->param("rexfile_url"),
    description => $self->param("rexfile_description")
  );

  $self->redirect_to("/project/" . $self->param("project_dir"));
}

sub view {
  my $self = shift;
  $self->render;
}

sub reload {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_dir"));
  $self->app->log->debug("Got rexfile name: " . $self->param("rexfile_name"));

  my $pr = $self->project($self->param("project_dir"));
  my $rexfile = $pr->get_rexfile($self->param("rexfile_dir"));

  $rexfile->reload;

  $self->redirect_to("/project/" . $pr->directory);
}

sub remove {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_dir"));
  $self->app->log->debug("Got rexfile name: " . $self->param("rexfile_name"));

  my $pr = $self->project($self->param("project_dir"));
  my $rexfile = $pr->get_rexfile($self->param("rexfile_dir"));

  $rexfile->remove;

  $self->redirect_to("/project/" . $pr->directory);
}

1;
