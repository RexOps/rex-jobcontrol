package Rex::JobControl;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use Rex::JobControl::Mojolicious::Command::jobcontrol;

our $VERSION = '0.0.1';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  # $self->plugin('PODRenderer');

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg = (
    "/etc/rex/jobcontrol.conf", "/usr/local/etc/rex/jobcontrol.conf",
    "jobcontrol.conf"
  );
  my $cfg;
  for my $file (@cfg) {
    if ( -f $file ) {
      $cfg = $file;
      last;
    }
  }

  #######################################################################
  # Load plugins
  #######################################################################
  $self->plugin( "Config", file => $cfg );
  $self->plugin("Rex::JobControl::Mojolicious::Plugin::Project");

  $self->plugin( Minion => { File => $self->app->config->{minion_db_file} } );
  $self->plugin("Rex::JobControl::Mojolicious::Plugin::MinionJobs");
  $self->plugin("Rex::JobControl::Mojolicious::Plugin::User");
  $self->plugin("Rex::JobControl::Mojolicious::Plugin::Audit");
  $self->plugin(
    "Authentication" => {
      autoload_user => 1,
      session_key   => $self->config->{session}->{key},
      load_user     => sub {
        my ( $app, $uid ) = @_;

        my $user = $app->get_user($uid);
        return $user;    # user objekt
      },
      validate_user => sub {
        my ( $app, $username, $password ) = @_;
        return $app->check_password( $username, $password );
      },
    }
  );

  #######################################################################
  # Define routes
  #######################################################################
  my $base_routes = $self->routes;

  # Normal route to controller

  my $r = $base_routes->bridge('/')->to('dashboard#prepare_stash');

  $r->get('/login')->to('dashboard#login');
  $r->post('/login')->to('dashboard#login_post');

  my $r_auth = $r->bridge('/')->to("dashboard#check_login");

  $r_auth->get('/logout')->to('dashboard#ctrl_logout');
  $r_auth->get('/')->to('dashboard#index');

  $r_auth->get('/project/new')->to('project#project_new');
  $r_auth->post('/project/new')->to('project#project_new_create');

  my $project_r =
    $r_auth->bridge('/project/:project_dir')->to('project#prepare_stash');
  my $rex_r = $r_auth->bridge('/project/:project_dir/rexfile/:rexfile_dir')
    ->to('rexfile#prepare_stash');
  my $job_r = $r_auth->bridge('/project/:project_dir/job/:job_dir')
    ->to('job#prepare_stash');

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

  #######################################################################
  # for the package
  #######################################################################

  # Switch to installable home directory
  $self->home->parse( catdir( dirname(__FILE__), 'JobControl' ) );

  # Switch to installable "public" directory
  $self->static->paths->[0] = $self->home->rel_dir('public');

  # Switch to installable "templates" directory
  $self->renderer->paths->[0] = $self->home->rel_dir('templates');

}

1;
