#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Helper::Project::Formular;

use strict;
use warnings;

use File::Spec;
use File::Path;
use YAML;
use Rex::JobControl::Helper::Chdir;
use Data::Dumper;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  $self->load;

  return $self;
}

sub name        { (shift)->{formular_configuration}->{name} }
sub description { (shift)->{formular_configuration}->{description} }
sub project     { (shift)->{project} }
sub directory   { (shift)->{directory} }

sub load {
  my ($self) = @_;

  if ( -f $self->_config_file() ) {
    $self->{formular_configuration} = YAML::LoadFile( $self->_config_file );
  }

  my $steps_file = File::Spec->catfile( $self->project->project_path(),
    "formulars", $self->{directory}, "steps.yml" );

  $self->{steps} = YAML::LoadFile($steps_file);
}

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile( $self->project->project_path(),
    "formulars", $self->{directory}, "formular.conf.yml" );
}

sub steps {
  my ($self) = @_;
  return $self->{steps}->{formulars};
}

sub formulars {
  my ($self) = @_;
  return $self->{steps}->{formulars};
}

1;
