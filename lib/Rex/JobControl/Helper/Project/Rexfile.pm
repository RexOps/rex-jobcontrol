#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Rex::JobControl::Helper::Project::Rexfile;

use strict;
use warnings;
use File::Spec;
use File::Path;
use Rex::JobControl::Helper::Chdir;

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  return $self;
}

sub app { (shift)->{app} }

sub create {
  my ($self, %data) = @_;

  my $rex_path = File::Spec->catdir($self->project->project_path, "rex", $self->{directory});

  $self->app->log->debug("Creating new Rexfile $self->{directory} in $rex_path.");

  File::Path::make_path($rex_path);

  my $rex_configuration = {
    name => $self->{name},
  };

  YAML::DumpFile("$rex_path/rex.conf.yml", $rex_configuration);

  chwd "$rex_path", sub {
    system "rexify --init=$data{url}";
  };
}

1;
