#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Helper::Project;

use strict;
use warnings;
use Data::Dumper;
use File::Spec;
use File::Path;
use YAML;
use Digest::MD5 'md5_hex';
use IO::All;

use Rex::JobControl::Helper::Project::Job;
use Rex::JobControl::Helper::Project::Rexfile;
use Rex::JobControl::Helper::Project::Formular;
use Rex::JobControl::Helper::Project::Nodegroup;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  if ( $self->{project_id} ) {
    $self->{directory} = $self->{project_id};
    delete $self->{project_id};
  }

  $self->load;

  return $self;
}

sub app       { (shift)->{app}; }
sub name      { (shift)->{project_configuration}->{name}; }
sub directory { (shift)->{directory}; }

sub data {
  my ($self) = @_;
  $self->load;
  return {
    id => $self->{directory},
    %{ $self->{project_configuration} },
  };
}

sub dump {
  my ($self) = @_;

  $self->app->log->debug( Dumper($self) );
}

sub load {
  my ($self) = @_;

  if ( -f $self->_config_file() ) {
    $self->{project_configuration} = YAML::LoadFile( $self->_config_file );
    $self->{name}                  = $self->{project_configuration}->{name};
  }

  #$self->{directory} = $self->{name};
}

sub _config_file {
  my ($self) = @_;
  return $self->project_path() . "/project.conf.yml";
}

sub project_path {
  my ( $self, @dirs ) = @_;

  my $path = File::Spec->rel2abs( $self->app->config->{project_path} );
  my $project_path = File::Spec->catdir( $path, $self->{directory}, @dirs );

  return $project_path;
}

sub get_last_job_execution {
  my ($self) = @_;

  my $last_run_status_file =
    File::Spec->catfile( $self->project_path, "last.run.status.yml" );
  if ( -f $last_run_status_file ) {
    return YAML::LoadFile($last_run_status_file);
  }

  return;
}

sub create {
  my ( $self, %data ) = @_;

  my $path = File::Spec->rel2abs( $self->app->config->{project_path} );
  my $project_path = File::Spec->catdir( $path, md5_hex( $self->{name} ) );

  $self->app->log->debug(
    "Creating new project $self->{name} in $project_path.");

  File::Path::make_path($project_path);
  File::Path::make_path( File::Spec->catdir( $project_path, "jobs" ) );
  File::Path::make_path( File::Spec->catdir( $project_path, "rex" ) );
  File::Path::make_path( File::Spec->catdir( $project_path, "formulars" ) );

  my $project_configuration = { name => $self->{name}, };

  YAML::DumpFile( "$project_path/project.conf.yml", $project_configuration );
}

sub update {
  my ($self) = @_;

  my $project_path = $self->project_path;
  YAML::DumpFile( "$project_path/project.conf.yml",
    $self->{project_configuration} );
}

sub add_node {
  my ( $self, $host ) = @_;

  if ( !exists $self->{project_configuration}->{nodes} ) {
    $self->{project_configuration}->{nodes} = [];
  }

  push @{ $self->{project_configuration}->{nodes} }, $host;
  $self->update;
}

sub job_count {
  my ($self) = @_;
  my $jobs = $self->jobs;
  return scalar( @{$jobs} );
}

sub list_jobs {
  my ($self) = @_;
  my @jobs = map { $_->data } @{ $self->jobs };
  return \@jobs;
}

sub jobs {
  my ($self) = @_;

  my @jobs;

  opendir( my $dh, $self->project_path() . "/jobs" )
    or die( "Error: $! (" . $self->project_path() . ")" );
  while ( my $entry = readdir($dh) ) {
    next if ( !-f $self->project_path() . "/jobs/$entry/job.conf.yml" );
    push @jobs,
      Rex::JobControl::Helper::Project::Job->new(
      directory => $entry,
      project   => $self
      );
  }
  closedir($dh);

  return \@jobs;
}

sub get_job {
  my ( $self, $dir ) = @_;
  return Rex::JobControl::Helper::Project::Job->new(
    directory => $dir,
    project   => $self
  );
}

sub create_job {
  my ( $self, %data ) = @_;

  $data{directory} = md5_hex( $data{directory} );

  my $job =
    Rex::JobControl::Helper::Project::Job->new( project => $self, %data );
  $job->create(%data);
}

sub rexfile_count {
  my ($self) = @_;
  my $rexfiles = $self->rexfiles;
  return scalar( @{$rexfiles} );
}

sub list_rexfiles {
  my ($self) = @_;
  my @rexfiles = map { $_->data } @{ $self->rexfiles };
  return \@rexfiles;
}

sub rexfiles {
  my ($self) = @_;

  my @rexfiles;

  opendir( my $dh, $self->project_path() . "/rex" ) or die($!);
  while ( my $entry = readdir($dh) ) {
    next if ( !-f $self->project_path() . "/rex/$entry/rex.conf.yml" );
    push @rexfiles,
      Rex::JobControl::Helper::Project::Rexfile->new(
      directory => $entry,
      project   => $self
      );
  }
  closedir($dh);

  return \@rexfiles;
}

sub create_rexfile {
  my ( $self, %data ) = @_;

  $data{directory} = md5_hex( $data{directory} );

  my $rexfile =
    Rex::JobControl::Helper::Project::Rexfile->new( project => $self, %data );
  $rexfile->create(%data);
}

sub get_rexfile {
  my ( $self, $dir ) = @_;
  return Rex::JobControl::Helper::Project::Rexfile->new(
    directory => $dir,
    project   => $self
  );
}

sub all_server {
  my ($self) = @_;

  my @all_server;

  for my $rex ( @{ $self->rexfiles } ) {
    push @all_server, @{ $rex->all_server };
  }

  $self->load;
  for my $srv ( @{ $self->{project_configuration}->{nodes} } ) {
    push @all_server, $srv;
  }

  return \@all_server;
}

sub remove {
  my ($self) = @_;
  File::Path::remove_tree( $self->project_path() );
}

sub list_nodegroups {
  my ($self) = @_;

  my @ret = map { $_->data } @{ $self->nodegroups };

  my %lookup_map;

  for my $l (@ret) {
    $lookup_map{ $l->{id} } = $l;
  }

  for my $c (@ret) {
    if ( $c->{parent_id} && $lookup_map{ $c->{parent_id} } ) {
      if (!exists $lookup_map{ $c->{parent_id} }->{children}
        || ref( $lookup_map{ $c->{parent_id} }->{children} ) ne "ARRAY" )
      {
        $lookup_map{ $c->{parent_id} }->{children} = [];
      }

      push @{ $lookup_map{ $c->{parent_id} }->{children} }, $c;
    }
  }

  return [ @ret[0] ];
}

sub nodegroups {
  my ($self) = @_;

  if ( !-d $self->project_path("nodes") ) {
    return [];
  }

  my @groups = map {
    my $dir      = $_->name;
    my $pro_path = $self->project_path("nodes");
    $dir =~ s/^\Q$pro_path\E.//;

    $_ = Rex::JobControl::Helper::Project::Nodegroup->new(
      directory => $dir,
      project   => $self
    );
    } grep { -d $_->name && -f File::Spec->catfile( $_->name, "group.conf.yml" ) }
    io( $self->project_path("nodes") )->All;

  return \@groups;
}

sub formular_count {
  my ($self) = @_;
  my $forms = $self->formulars;
  return scalar( @{$forms} );
}

sub list_formulars {
  my ($self) = @_;
  my @formulars = map { $_->data } @{ $self->formulars };
  return \@formulars;
}

sub formulars {
  my ($self) = @_;

  my @formulars;

  if ( !-d $self->project_path() . "/formulars" ) {
    return [];
  }

  opendir( my $dh, $self->project_path() . "/formulars" )
    or die( "Error: $! (" . $self->project_path() . ")" );
  while ( my $entry = readdir($dh) ) {
    next
      if ( !-f $self->project_path() . "/formulars/$entry/formular.conf.yml" );
    push @formulars,
      Rex::JobControl::Helper::Project::Formular->new(
      directory => $entry,
      project   => $self
      );
  }
  closedir($dh);

  return \@formulars;
}

sub get_formular {
  my ( $self, $dir ) = @_;
  return Rex::JobControl::Helper::Project::Formular->new(
    directory => $dir,
    project   => $self
  );
}

sub create_formular {
  my ( $self, %data ) = @_;

  $data{directory} = md5_hex( $data{directory} );

  my $form =
    Rex::JobControl::Helper::Project::Formular->new( project => $self, %data );

  $form->create(%data);
}

1;
