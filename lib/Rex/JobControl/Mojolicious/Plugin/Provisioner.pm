#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;
use warnings;

package Rex::JobControl::Mojolicious::Plugin::Provisioner;

use Mojolicious::Plugin;
use Rex::JobControl::Helper::Project;

use base 'Mojolicious::Plugin';
use Rex::JobControl::ConnectionPool::SSH;

use Rex::JobControl::Provision;


sub register {
  my ( $plugin, $app ) = @_;

  $app->helper(
    provisioner => sub {
      my ( $self, $type, %data ) = @_;
      return Rex::JobControl::Provision->get($type, %data);
    }
  );
}

1;
