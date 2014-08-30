#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Rexfile;
use Mojo::Base 'Mojolicious::Controller';

sub prepare_stash {
  my $self = shift;

  my $project = $self->project( $self->param("project_dir") );
  $self->stash( project => $project );

  my $rexfile = $project->get_rexfile( $self->param("rexfile_dir") );
  $self->stash( rexfile => $rexfile );
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

  $self->app->log->debug( "Got project name: " . $self->param("project_dir") );
  $self->app->log->debug( "Got rexfile name: " . $self->param("rexfile_name") );

  my $pr = $self->project( $self->param("project_dir") );

  $self->minion->enqueue(
    checkout_rexfile => [
      $pr->directory,              $self->param("rexfile_name"),
      $self->param("rexfile_url"), $self->param("rexfile_description")
    ]
  );

  $self->flash(
    {
      title => "Rexfile will be downloaded in background.",
      message =>
        "Rexfile will be downloaded in background. Once it it finished it will appear in the list."
    }
  );

  $self->redirect_to( "/project/" . $self->param("project_dir") );
}

sub view {
  my $self = shift;
  $self->render;
}

sub reload {
  my $self = shift;

  $self->app->log->debug( "Got project name: " . $self->param("project_dir") );
  $self->app->log->debug( "Got rexfile name: " . $self->param("rexfile_name") );

  my $pr      = $self->project( $self->param("project_dir") );
  my $rexfile = $pr->get_rexfile( $self->param("rexfile_dir") );

  $rexfile->reload;

  $self->redirect_to( "/project/" . $pr->directory );
}

sub remove {
  my $self = shift;

  $self->app->log->debug( "Got project name: " . $self->param("project_dir") );
  $self->app->log->debug( "Got rexfile name: " . $self->param("rexfile_name") );

  my $pr      = $self->project( $self->param("project_dir") );
  my $rexfile = $pr->get_rexfile( $self->param("rexfile_dir") );

  $rexfile->remove;

  $self->flash(
    {
      title   => "Rexfile removed",
      message => "Rexfile <b>" . $rexfile->name . "</b> removed."
    }
  );

  $self->redirect_to( "/project/" . $pr->directory );
}

1;
