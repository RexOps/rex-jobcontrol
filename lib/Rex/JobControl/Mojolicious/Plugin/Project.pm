#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::JobControl::Mojolicious::Plugin::Project;

use strict;
use warnings;

use Mojolicious::Plugin;
use Rex::JobControl::Helper::Project;

use base 'Mojolicious::Plugin';

sub register {
   my ($plugin, $app) = @_;

   $app->helper(
      project => sub {
         my ($self, $name) = @_;
         my $u = Rex::JobControl::Helper::Project->new(name => $name, app => $app);
         return $u;
      }
   );
}

1;
