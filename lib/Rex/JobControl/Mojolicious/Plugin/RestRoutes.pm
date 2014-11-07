#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
use strict;
use warnings;

package Rex::JobControl::Mojolicious::Plugin::RestRoutes;

use Mojo::Base 'Mojolicious::Plugin';
use Data::Dumper;

sub register {
  my ( $self, $app, $options ) = @_;

  my $r = $app->routes;

  my $prefix      = $options->{prefix}      || "/api/v1";
  my $base_module = $options->{base_module} || "api";

  if ( exists $options->{bridge} && $options->{bridge} ) {
    $r = $r->bridge($prefix)->to( $options->{bridge} );
    $prefix = '';
  }

  my ( %object_path, %object_route, $func_prefix );

  $func_prefix = "object";

  for my $object ( reverse @{ $options->{objects} } ) {

    #$func_prefix = "\L$object";

    if ( $object =~ m/::/ ) {
      my @parts = split( /::/, $object );

      #$func_prefix = "\L$parts[-1]";

      my @o_path;
      for my $p (@parts) {
        if ( $object_path{$p} ) {
          push @o_path, "\L$object_path{$p}";
        }
        else {
          push @o_path, "\L${p}", ":\L${p}_id";
        }
      }

      my @list_path = @o_path[ 0 .. -1 ];

      $object_path{$object} = join( "/", @o_path );
      $object_route{$object} = lc( join( "-", @parts ) );

      # list available
      $r->get( "/" . join( "/", @o_path[ 0 .. $#o_path - 1 ] ) )
        ->to("$base_module-$object_route{$object}#list_\L$func_prefix");
    }
    else {
      $object_path{$object}  = "\L$object/:\L${object}_id";
      $object_route{$object} = "\L$object";

      # list available
      $r->get("$prefix/\L$object")->to("$base_module-$object#list_\L$func_prefix");
    }

    $app->log->debug("Register RESTful routes for $object.");
    $app->log->debug("$object_path{$object} -> $object_route{$object}");

    # crud operations
    $r->post("$prefix/$object_path{$object}")
      ->to("$base_module-$object_route{$object}#create_\L$func_prefix");
    $r->get("$prefix/$object_path{$object}")
      ->to("$base_module-$object_route{$object}#read_\L$func_prefix");
    $r->put("$prefix/$object_path{$object}")
      ->to("$base_module-$object_route{$object}#update_\L$func_prefix");
    $r->delete("$prefix/$object_path{$object}")
      ->to("$base_module-$object_route{$object}#delete_\L$func_prefix");
  }
}

1;
