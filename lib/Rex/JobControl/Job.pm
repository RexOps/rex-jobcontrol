#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   

package Rex::JobControl::Job;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  $self->render;
}

sub job_new {
  my $self = shift;
  $self->render;
}

sub job_new_create {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_name"));
  $self->app->log->debug("Got job name: " . $self->param("project_name"));

  my $pr = $self->project($self->param("project_name"));
  $pr->create_job(directory => $self->param("job_name"));

  $self->redirect_to("/project/" . $self->param("project_name"));
}

sub view {
  my $self = shift;

  my $project = $self->project($self->param("project_dir"));
  my $job     = $project->get_job($self->param("job_dir"));

  $self->stash(project => $project);
  $self->stash(job => $job);

  $self->render;
}

1;
