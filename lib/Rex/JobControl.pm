package Rex::JobControl;
use Mojo::Base 'Mojolicious';

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

  #######################################################################
  # Define routes
  #######################################################################
  my $base_routes = $self->routes;

  # Normal route to controller

  my $r     = $base_routes->bridge('/')->to('dashboard#prepare_stash');
  my $job_r = $r->bridge('/project/:project_dir/job')->to('project#prepare_stash');
  my $rex_r = $r->bridge('/project/:project_dir/rexfile')->to('project#prepare_stash');

  $r->get('/')->to('dashboard#index');
  $r->get('/project/new')->to('project#project_new');
  $r->get('/project/:project_dir')->to('project#view');

  $job_r->get('/new')->to('job#job_new');
  $rex_r->get('/new')->to('rexfile#rexfile_new');

  $rex_r->post('/new')->to('rexfile#rexfile_new_create');

  $r->post('/project/new')->to('project#project_new_create');
}

1;
