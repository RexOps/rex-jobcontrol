#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
use strict;
use warnings;

package Rex::JobControl::Helper::Base;

use Data::Dumper;

sub new {
  my $that = shift;
  my $proto = ref($that) || $that;
  my $self = { @_ };

  bless($self, $proto);

  return $self;
}

sub list_projects {
  my ($self) = @_;

  my @projects;

  opendir( my $dh, $self->app->config->{project_path} ) or die($!);
  while ( my $entry = readdir($dh) ) {
    next if ( !-f $self->app->config->{project_path} . "/$entry/project.conf.yml" );
    push @projects, %{ $self->app->project($entry)->data }, id => $entry;
  }
  closedir($dh);

  return \@projects;
}

sub app { shift->{app} };

1;
