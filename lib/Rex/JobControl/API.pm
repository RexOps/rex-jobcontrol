#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
use strict;
use warnings;

package Rex::JobControl::API;

use Mojo::Base 'Mojolicious::Controller';
use Rex::JobControl::Helper::Base;

use Data::Dumper;

sub list_object {
  my ($self) = @_;

  my @object_path = split( /::/, ref($self) );
  shift @object_path;
  shift @object_path;
  shift @object_path;

  my $last_object = lc( pop(@object_path) );
  my $plural      = $last_object;

  my %stash;
  for my $o_stash (@object_path) {
    $stash{ lc("${o_stash}_id") } = $self->stash( lc("${o_stash}_id") );
  }

  if ( $plural !~ m/s$/ ) {
    $plural .= "s";
  }

  my $func = "list_$plural";
  unshift @object_path, "Helper";

  if ( scalar @object_path == 1 ) {
    push @object_path, "Base";
  }

  my $class = "Rex::JobControl::" . join( "::", @object_path );

  $self->app->log->debug("calling class: $class");
  $self->app->log->debug("calling func: $func");

  my $stash = $self->stash;

  my $o = $class->new( app => $self->app, %stash );

  my $ret = $o->$func();

  $self->render( json => $ret );
}

sub create_object {
  my ($self)   = @_;
  my $o = $self->_prepare_object;

  $self->app->log->debug("Got JSON: " . Dumper($self->req->json));

  my $data = $o->create(%{ $self->req->json });
  $self->render( json => $data, status => 201 );
}

sub read_object {
  my ($self) = @_;
  my $o = $self->_prepare_object;

  $self->render( json => $o->data );
}

sub update_object {
  my ($self) = @_;
  my $o = $self->_prepare_object;

  $o->update( %{ $self->req->json } );

  $self->render( json => {}, status => 200 );
}

sub delete_object {
  my ($self)   = @_;
  my $o = $self->_prepare_object;

  $o->remove();

  $self->render( json => {}, status => 200 );
}

sub _prepare_object {
  my ($self) = @_;

  my @object_path = split( /::/, ref($self) );
  shift @object_path;
  shift @object_path;
  shift @object_path;

  my %stash;
  for my $o_stash (@object_path) {
    $stash{ lc("${o_stash}_id") } = $self->stash( lc("${o_stash}_id") );
  }

  unshift @object_path, "Helper";

  my $class = "Rex::JobControl::" . join( "::", @object_path );

  $self->app->log->debug("calling class: $class");

  my $o = $class->new( app => $self->app, %stash );
  return $o;
}

1;
