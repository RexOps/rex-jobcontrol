#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
use strict;
use warnings;

package Rex::JobControl::Helper::Project::Node;

use Data::Dumper;
use File::Spec;
use File::Path;
use Mojo::JSON;
use IO::All;
use Digest::MD5 'md5_hex';

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  if ( $self->{node_id} ) {
    my @parts = split( /_/, $self->{node_id} );
    $self->{directory} = File::Spec->catdir(@parts);
    delete $self->{node_id};
  }

  if ( $self->{project_id} ) {
    $self->{project} = Rex::JobControl::Helper::Project->new(
      app        => $self->{app},
      project_id => $self->{project_id}
    );
    delete $self->{project_id};
  }

  $self->load;

  return $self;
}

sub data {
  my ($self) = @_;
  $self->load;

  my @dir_struct = File::Spec->splitdir( $self->{directory} );

  my $id = $self->id;

  return {
    id        => $self->id,
    parent_id => join( "_", @dir_struct[ 0 .. $#dir_struct - 1 ] ),
    text      => $self->name,
    %{ $self->{node_configuration} },
  };
}

sub id {
  my ($self) = @_;
  my $id     = $self->{directory};
  my @dirs   = File::Spec->splitdir( $self->{directory} );
  return join( "_", @dirs );
}

sub project     { (shift)->{project} }
sub name        { (shift)->{node_configuration}->{name} }
sub directory   { (shift)->{directory} }

sub load {
  my ($self) = @_;

  if ( -f $self->_config_file() ) {
    $self->{node_configuration} = YAML::LoadFile( $self->_config_file );
  }
}

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile(
    $self->project->project_path(), "nodes",
    split( "/", $self->{directory} ), "node.conf.yml"
  );
}

sub create {
  my ( $self, %data ) = @_;

  my ($node_path);

  if ( !exists $data{directory} ) {
    my @parent = split( /_/, $data{parent} );

    $node_path =
      $self->project->project_path( "nodes", @parent, md5_hex( $data{name} ) );
    $self->{directory} =
      File::Spec->abs2rel( $node_path, $self->project->project_path("nodes") );
  }
  else {
    $node_path = File::Spec->catdir( $self->project->project_path,
      "nodes", $self->{directory} );
  }

  $self->project->app->log->debug(
    "Creating new node $self->{directory} in $node_path.");

  File::Path::make_path($node_path);

  delete $data{directory};
  delete $data{parent};

  my $node_configuration = {%data};

  YAML::DumpFile( File::Spec->catfile( $node_path, "node.conf.yml" ),
    $node_configuration );
}

sub remove {
  my ($self) = @_;

  my $node_dir = File::Spec->catdir( $self->project->project_path(),
    "nodes", split( "/", $self->{directory} ) );

  File::Path::remove_tree($node_dir);  
}

1;
