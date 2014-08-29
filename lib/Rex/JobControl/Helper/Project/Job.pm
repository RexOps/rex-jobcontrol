#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Rex::JobControl::Helper::Project::Job;

use strict;
use warnings;

use File::Spec;
use File::Path;
use YAML;

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  $self->load;

  return $self;
}

sub name { (shift)->{job_configuration}->{name} }
sub project { (shift)->{project} }
sub directory { (shift)->{directory} }

sub load {
  my ($self) = @_;

  if(-f $self->_config_file()) {
    $self->{job_configuration} = YAML::LoadFile($self->_config_file);
  }
}

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile($self->project->project_path(), "jobs", $self->{directory}, "job.conf.yml");
}

sub create {
  my ($self, %data) = @_;

  my $job_path = File::Spec->catdir($self->project->project_path, "jobs", $self->{directory});

  $self->project->app->log->debug("Creating new job $self->{directory} in $job_path.");

  File::Path::make_path($job_path);

  delete $data{directory};

  my $job_configuration = { %data };

  YAML::DumpFile("$job_path/job.conf.yml", $job_configuration);
}

1;
