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
use YAML;
use IPC::Open2;

use Rex::JobControl::Helper::Chdir;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  $self->load;

  return $self;
}

sub load {
  my ($self) = @_;

  if ( -f $self->_config_file() ) {
    $self->{rex_configuration} = YAML::LoadFile( $self->_config_file );
  }
}

sub project     { (shift)->{project} }
sub name        { (shift)->{rex_configuration}->{name} }
sub url         { (shift)->{rex_configuration}->{url} }
sub description { (shift)->{rex_configuration}->{description} }
sub groups      { (shift)->{rex_configuration}->{rex}->{groups} }
sub directory   { (shift)->{directory} }
sub rexfile     { (shift)->{rex_configuration}->{rexfile} }

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile( $self->project->project_path(),
    "rex", $self->{directory}, "rex.conf.yml" );
}

sub create {
  my ( $self, %data ) = @_;

  my $rex_path = File::Spec->catdir( $self->project->project_path,
    "rex", $self->{directory} );

  $self->project->app->log->debug(
    "Creating new Rexfile $self->{directory} in $rex_path.");

  File::Path::make_path($rex_path);

  my $rexfile = basename( $self->{url} );
  $rexfile =~ s/(\.git|\.tar\.gz)$//;

  my $url = $self->{url};
  chwd "$rex_path", sub {
    my $rexify_cmd = $self->project->app->config->{rexify};
    my @out        = `$rexify_cmd --init=$url 2>&1`;
    chomp @out;

    $self->project->app->log->debug("Output of rexify --init=$url");
    for my $l (@out) {
      $self->project->app->log->debug("rexfile: $l");
    }
  };

  my @tasks;
  my $rex_info;

  chwd "$rex_path/$rexfile", sub {
    my $rex_cmd = $self->project->app->config->{rex};
    my $out     = `$rex_cmd -Ty 2>&1`;
    $rex_info = YAML::Load($out);
  };

  $data{name} = $data{directory};
  delete $data{directory};

  my $rex_configuration = {
    %data,
    rexfile => $rexfile,
    rex     => $rex_info,
  };

  YAML::DumpFile( "$rex_path/rex.conf.yml", $rex_configuration );
}

sub tasks {
  my ($self) = @_;
  return $self->{rex_configuration}->{rex}->{tasks};
}

sub environments {
  my ($self) = @_;
  return $self->{rex_configuration}->{rex}->{envs};
}

sub all_server {
  my ($self) = @_;

  my @all_server;

  for my $group ( keys %{ $self->groups } ) {
    push @all_server,
      ( map { $_ = { name => $_->{name}, group => $group } }
        @{ $self->groups->{$group} } );
  }

  return \@all_server;
}

sub reload {
  my ($self) = @_;

  my $rex_path = File::Spec->catdir( $self->project->project_path,
    "rex", $self->{directory} );

  my $rexfile = $self->rexfile;
  my $url     = $self->url;

  chwd "$rex_path", sub {
    my $rexify_cmd = $self->project->app->config->{rexify};
    my @out        = `$rexify_cmd --init=$url 2>&1`;
    chomp @out;

    $self->project->app->log->debug("Output of rexify --init=$url");
    for my $l (@out) {
      $self->project->app->log->debug("rexfile: $l");
    }
  };

  my @tasks;
  my $rex_info;

  chwd "$rex_path/$rexfile", sub {
    my $rex_cmd = $self->project->app->config->{rex};
    my $out     = `$rex_cmd -Ty`;
    $rex_info = YAML::Load($out);
  };

  my $rex_configuration = {
    name    => $self->{directory},
    url     => $url,
    rexfile => $rexfile,
    rex     => $rex_info,
  };

  YAML::DumpFile( "$rex_path/rex.conf.yml", $rex_configuration );

}

sub remove {
  my ($self) = @_;
  my $rexfile_path = File::Spec->catdir( $self->project->project_path,
    "rex", $self->{directory} );

  File::Path::remove_tree($rexfile_path);
}

sub execute {
  my ( $self, %option ) = @_;

  my $task   = $option{task};
  my $job    = $option{job};
  my @server = @{ $option{server} };
  my $cmdb   = $option{cmdb};

  my $rex_path = File::Spec->catdir( $self->project->project_path,
    "rex", $self->{directory}, $self->rexfile );

  my @ret;

  for my $srv (@server) {

    my $child_exit_status;
    chwd $rex_path, sub {
      my ( $chld_out, $chld_in, $pid );
      $pid = open2(
        $chld_out, $chld_in, $self->project->app->config->{rex},
        '-H', $srv, '-t', 1, '-F', '-m',
        ( $cmdb ? ( '-O', "cmdb_path=$cmdb/default.yml" ) : () ), $task
      );

      while ( my $line = <$chld_out> ) {
        chomp $line;
        $self->project->app->log->debug("rex: $line");
      }

      waitpid( $pid, 0 );

      $child_exit_status = $? >> 8;
    };

    if ( $child_exit_status == 0 ) {
      push @ret,
        {
        server  => $srv,
        rexfile => $self->name,
        task    => $task,
        status  => "success",
        };
    }
    else {
      push @ret,
        {
        server  => $srv,
        rexfile => $self->name,
        task    => $task,
        status  => "failed",
        };
    }

    if ( $child_exit_status != 0 && $job->fail_strategy eq "terminate" ) {
      $ret[-1]->{terminate_message} =
        "Terminating execution due to terminate fail strategy.";
    }

  }

  return \@ret;
}

1;
