#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
use strict;
use warnings;

package Rex::JobControl::Provision;

use 5.010;
state %provisioners;

use Data::Dumper;

sub register_type {
  my ($class, $type) = @_;
  my ($package, $filename, $line) = caller;
  $provisioners{$type} = $package;
}

sub get {
  my ($class, $type, %data) = @_;

  eval {
    if(exists $provisioners{$type}) {
      my $x = $provisioners{$type}->new(%data);
      return $x;
    }

    0;
  } or do {
    die "No provisioner for $type found.";
  }
}

1;
