#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;
use warnings;

package Rex::JobControl::Mojolicious::Plugin::SSH;

use 5.010;

use Mojolicious::Plugin;
use Rex::JobControl::Helper::Project;

use base 'Mojolicious::Plugin';
use Rex::JobControl::ConnectionPool::SSH;


sub register {
  my ( $plugin, $app ) = @_;

  $app->helper(
    ssh_pool => sub {
      my ( $self ) = @_;
      state $ssh_pool = Rex::JobControl::ConnectionPool::SSH->new;
      return $ssh_pool;
    }
  );
}

1;
