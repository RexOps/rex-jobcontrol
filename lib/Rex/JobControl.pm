package Rex::JobControl;

use Mojo::Base 'Mojolicious';
use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  # $self->plugin('PODRenderer');

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg = ("/etc/rex/jobcontrol.conf", "/usr/local/etc/rex/jobcontrol.conf", "jobcontrol.conf");
  my $cfg;
  for my $file (@cfg) {
    if(-f $file) {
      $cfg = $file;
      last;
    }
  }

  #######################################################################
  # Load plugins
  #######################################################################
  $self->plugin("Config", file => $cfg);
  $self->plugin("Rex::JobControl::Mojolicious::Plugin::Project");
  $self->plugin(Minion => {File  => $self->app->config->{minion_db_file}});



  #######################################################################
  # Add minion tasks
  #######################################################################
  $self->app->minion->add_task(execute_rexfile => sub {
    my ($job, $project_dir, $job_dir, @server) = @_;
    $job->app->log->debug("Project: $project_dir");
    $job->app->log->debug("Job: $job_dir");

    eval {
      my $pr = $self->app->project($project_dir);
      my $job = $pr->get_job($job_dir);
      $job->execute(@server);
      1;
    } or do {
      $self->app->log->debug("Error executing: $@");
    };
  });

  #######################################################################
  # Define routes
  #######################################################################
  my $base_routes = $self->routes;

  # Normal route to controller


  my $r         = $base_routes->bridge('/')->to('dashboard#prepare_stash');

  $r->get('/')->to('dashboard#index');

  $r->get('/project/new')->to('project#project_new');
  $r->post('/project/new')->to('project#project_new_create');

  my $project_r = $r->bridge('/project/:project_dir')->to('project#prepare_stash');
  my $rex_r     = $r->bridge('/project/:project_dir/rexfile/:rexfile_dir')->to('rexfile#prepare_stash');
  my $job_r     = $r->bridge('/project/:project_dir/job/:job_dir')->to('job#prepare_stash');

  $project_r->get('/nodes')->to('nodes#index');
  $project_r->get('/audit')->to('audit#index');

  $project_r->get('/')->to('project#view');
  $project_r->get('/job/new')->to('job#job_new');
  $project_r->post('/job/new')->to('job#job_new_create');
  $project_r->get('/delete')->to('project#remove');
  $project_r->get('/rexfile/new')->to('rexfile#rexfile_new');
  $project_r->post('/rexfile/new')->to('rexfile#rexfile_new_create');

  $rex_r->get('/')->to('rexfile#view');
  $rex_r->get('/reload')->to('rexfile#reload');
  $rex_r->get('/delete')->to('rexfile#remove');

  $job_r->get('/')->to('job#view');
  $job_r->get('/edit')->to('job#edit');
  $job_r->post('/edit')->to('job#edit_save');
  $job_r->get('/delete')->to('job#job_delete');
  $job_r->get('/execute')->to('job#job_execute');
  $job_r->post('/execute')->to('job#job_execute_dispatch');
}

1;
