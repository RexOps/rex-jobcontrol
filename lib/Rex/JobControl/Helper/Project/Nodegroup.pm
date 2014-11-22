#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;
use warnings;

package Rex::JobControl::Helper::Project::Nodegroup;

use Data::Dumper;
use File::Spec;
use File::Path;
use Mojo::JSON;
use IO::All;
use Digest::MD5 'md5_hex';

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  if ( $self->{nodegroup_id} ) {
    my @parts = split( /_/, $self->{nodegroup_id} );
    $self->{directory} = File::Spec->catdir(@parts);
    delete $self->{nodegroup_id};
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
    children  => $self->has_children,
    nodes     => $self->get_nodes,
    %{ $self->{nodegroup_configuration} },
  };
}

sub get_nodes {
  my ($self) = @_;

  my @ret;
  my $group_dir = $self->project->project_path( "nodes", $self->directory );

  opendir( my $dh, $group_dir ) or die($!);
  while ( my $entry = readdir($dh) ) {
    next if ( $entry =~ m/^\./ );
    if ( -f File::Spec->catfile( $group_dir, $entry, "node.conf.yml" ) ) {
      push @ret,
        YAML::LoadFile(
        File::Spec->catfile( $group_dir, $entry, "node.conf.yml" ) );
    }
  }
  close($dh);

  return \@ret;
}

sub id {
  my ($self) = @_;
  my $id     = $self->{directory};
  my @dirs   = File::Spec->splitdir( $self->{directory} );
  return join( "_", @dirs );
}

sub project     { (shift)->{project} }
sub name        { (shift)->{nodegroup_configuration}->{name} }
sub description { (shift)->{nodegroup_configuration}->{description} }
sub directory   { (shift)->{directory} }

sub has_children { return Mojo::JSON->true; }

sub load {
  my ($self) = @_;
  if ( -f $self->_config_file() ) {
    $self->{nodegroup_configuration} = YAML::LoadFile( $self->_config_file );
  }
}

sub _config_file {
  my ($self) = @_;
  return File::Spec->catfile(
    $self->project->project_path(), "nodes",
    split( "/", $self->{directory} ), "group.conf.yml"
  );
}

sub remove {
  my ($self) = @_;

  my $nodegroup_dir = File::Spec->catdir( $self->project->project_path(),
    "nodes", split( "/", $self->{directory} ) );

  File::Path::remove_tree($nodegroup_dir);  
}

sub create {
  my ( $self, %data ) = @_;

  my ($group_path);

  if ( !exists $data{directory} ) {
    my @parent = split( /_/, $data{parent} );

    $group_path =
      $self->project->project_path( "nodes", @parent, md5_hex( $data{name} ) );
    $self->{directory} =
      File::Spec->abs2rel( $group_path, $self->project->project_path("nodes") );
  }
  else {
    $group_path = File::Spec->catdir( $self->project->project_path,
      "nodes", $self->{directory} );
  }

  $self->project->app->log->debug(
    "Creating new nodegroup $self->{directory} in $group_path.");

  File::Path::make_path($group_path);

  delete $data{directory};
  delete $data{parent};

  my $nodegroup_configuration = {%data};

  YAML::DumpFile( File::Spec->catfile( $group_path, "group.conf.yml" ),
    $nodegroup_configuration );
}

1;
