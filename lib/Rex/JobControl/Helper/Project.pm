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
use Rex::JobControl::Helper::Project::Job;
use Rex::JobControl::Helper::Project::Rexfile;

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  $self->load;

  return $self;
}

sub app { (shift)->{app}; }
sub name { (shift)->{project_configuration}->{name}; }
sub directory { (shift)->{directory}; }

sub dump {
  my ($self) = @_;

  $self->app->log->debug(Dumper($self));
}

sub load {
  my ($self) = @_;

  if(-f $self->_config_file()) {
    $self->{project_configuration} = YAML::LoadFile($self->_config_file);
  }

  $self->{directory} = $self->{name};
}

sub _config_file {
  my ($self) = @_;
  return $self->project_path() . "/project.conf.yml";
}

sub project_path {
  my ($self) = @_;

  my $path = File::Spec->rel2abs($self->app->config->{project_path});
  my $project_path = File::Spec->catdir($path, $self->{name});

  return $project_path;
}

sub create {
  my ($self) = @_;

  my $path = File::Spec->rel2abs($self->app->config->{project_path});
  my $project_path = File::Spec->catdir($path, $self->{name});

  $self->app->log->debug("Creating new project $self->{name} in $project_path.");

  File::Path::make_path($project_path);
  File::Path::make_path(File::Spec->catdir($project_path, "jobs"));
  File::Path::make_path(File::Spec->catdir($project_path, "rex"));

  my $project_configuration = {
    name => $self->{name},
  };

  YAML::DumpFile("$project_path/project.conf.yml", $project_configuration);
}

sub job_count {
  my ($self) = @_;
  my $jobs = $self->jobs;
  return scalar(@{ $jobs });
}

sub jobs {
  my ($self) = @_;

  my @jobs;

  opendir(my $dh, $self->project_path() . "/jobs") or die($!);
  while(my $entry = readdir($dh)) {
    next if(! -f $self->project_path() . "/jobs/$entry/job.conf.yml");
    push @jobs, Rex::JobControl::Helper::Project::Job->new(directory => $entry, project => $self);
  }
  closedir($dh);

  return \@jobs;
}

sub create_job {
  my ($self, %data) = @_;

  my $job = Rex::JobControl::Helper::Project::Job->new(project => $self, %data);
  $job->create(%data);
}

sub rexfile_count {
  my ($self) = @_;
  my $rexfiles = $self->rexfiles;
  return scalar(@{ $rexfiles });
}

sub rexfiles {
  my ($self) = @_;

  my @rexfiles;

  opendir(my $dh, $self->project_path() . "/rex") or die($!);
  while(my $entry = readdir($dh)) {
    next if(! -f $self->project_path() . "/rex/$entry/rex.conf.yml");
    push @rexfiles, Rex::JobControl::Helper::Project::Rexfile->new(directory => $entry, project => $self);
  }
  closedir($dh);

  return \@rexfiles;
}

sub create_rexfile {
  my ($self, %data) = @_;

  my $rexfile = Rex::JobControl::Helper::Project::Rexfile->new(project => $self, %data);
  $rexfile->create;
}

1;
