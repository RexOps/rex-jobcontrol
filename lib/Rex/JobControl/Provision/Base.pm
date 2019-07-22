#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
use strict;
use warnings;

package Rex::JobControl::Provision::Base;

use Moo::Role;

sub create {}
sub remove {}

# return a list from all known nodes that are able to
# fullfill the required provisioning type
sub get_hosts {}

sub get_host {}

1;
