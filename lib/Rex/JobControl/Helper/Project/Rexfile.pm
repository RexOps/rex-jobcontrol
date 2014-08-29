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
use File::Basename;
use Rex::JobControl::Helper::Chdir;

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  $self->load;

  return $self;
}

sub load {
  my ($self) = @_;

  if(-f $self->_config_file()) {
    $self->{rex_configuration} = YAML::LoadFile($self->_config_file);
  }
}

sub project { (shift)->{project} }
sub name { (shift)->{rex_configuration}->{name} }
sub directory { (shift)->{directory} }

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile($self->project->project_path(), "rex", $self->{directory}, "rex.conf.yml");
}

sub create {
  my ($self) = @_;

  my $rex_path = File::Spec->catdir($self->project->project_path, "rex", $self->{directory});

  $self->project->app->log->debug("Creating new Rexfile $self->{directory} in $rex_path.");

  File::Path::make_path($rex_path);

  my $rexfile = basename($self->{url});
  $rexfile =~ s/\.git//;

  my $url = $self->{url};
  chwd "$rex_path", sub {
    my @out = `/home/jan/Projekte/rex/rex/bin/rexify --init=$url 2>&1`;
    chomp @out;

    $self->project->app->log->debug("Output of rexify --init=$url");
    for my $l (@out) {
      $self->project->app->log->debug("rexfile: $l");
    }
  };

  my @tasks;
  chwd "$rex_path/$rexfile", sub {
    my @out = `/home/jan/Projekte/rex/rex/bin/rex -Tm 2>&1`;
    chomp @out;

    for my $l (@out) {
      my ($task, $desc) = ($l =~ m/'([^']+)' = '(.*)'/);
      push @tasks, { name => $task, desc => $desc };
    }
  };

  my $rex_configuration = {
    name => $self->{directory},
    url  => $url,
    rexfile => $rexfile,
    tasks => \@tasks,
  };

  YAML::DumpFile("$rex_path/rex.conf.yml", $rex_configuration);
}

sub tasks {
  my ($self) = @_;
  return $self->{rex_configuration}->{tasks};
}

1;