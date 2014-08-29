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

  return $self;
}

sub name { (shift)->{job_configuration}->{name} }
sub project { (shift)->{project} }

sub create {
  my ($self) = @_;

  my $job_path = File::Spec->catdir($self->project->project_path, "jobs", $self->{directory});

  $self->app->log->debug("Creating new job $self->{directory} in $job_path.");

  File::Path::make_path($job_path);

  my $job_configuration = {
    name => $self->{name},
  };

  YAML::DumpFile("$job_path/job.conf.yml", $job_configuration);
}

1;
