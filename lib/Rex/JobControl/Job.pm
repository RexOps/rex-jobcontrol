#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   

package Rex::JobControl::Job;
use Mojo::Base 'Mojolicious::Controller';

sub prepare_stash {
  my $self = shift;

  my $project = $self->project($self->param("project_dir"));
  $self->stash(project => $project);

  my $job = $project->get_job($self->param("job_dir"));
  $self->stash(job => $job);
}

sub edit_save {
  my $self = shift;

  my $pr  = $self->project($self->param("project_dir"));
  my $job = $pr->get_job($self->param("job_dir"));

  $job->update(
    name => $self->param("job_name"),
    description => $self->param("job_description"),
    environment => $self->param("environment"),
    fail_strategy => $self->param("fail_strategy"),
    execute_strategy => $self->param("execute_strategy"),
    steps => [ split(/,/, $self->param("hdn_workflow_steps")) ],
  );

  $self->redirect_to("/project/" . $pr->directory . "/job/" . $job->directory);
}

sub job_delete {
  my $self = shift;

  my $pr  = $self->project($self->param("project_dir"));
  my $job = $pr->get_job($self->param("job_dir"));

  $job->remove;

  $self->redirect_to("/project/" . $pr->directory);
}

sub view {
  my $self = shift;
  $self->render;
}

sub job_new {
  my $self = shift;
  $self->render;
}

sub job_new_create {
  my $self = shift;

  $self->app->log->debug("Got project name: " . $self->param("project_dir"));
  $self->app->log->debug("Got job name: " . $self->param("job_name"));

  my $pr = $self->project($self->param("project_dir"));
  $pr->create_job(
    directory => $self->param("job_name"),
    name => $self->param("job_name"),
    description => $self->param("job_description"),
    environment => $self->param("environment"),
    fail_strategy => $self->param("fail_strategy"),
    execute_strategy => $self->param("execute_strategy"),
    steps => [ split(/,/, $self->param("hdn_workflow_steps")) ],
  );

  $self->redirect_to("/project/" . $self->param("project_dir"));
}

sub job_execute {
  my $self = shift;

  my $pr = $self->project($self->param("project_dir"));
  my $all_server = $pr->all_server;

  $self->stash(all_server => $all_server);

  $self->render('job/execute');
}

sub job_execute_dispatch {
  my $self = shift;

  my $pr  = $self->project($self->param("project_dir"));
  my $job = $pr->get_job($self->param("job_dir"));

  $self->redirect_to("/project/" . $pr->directory . "/job/" . $job->directory);
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
