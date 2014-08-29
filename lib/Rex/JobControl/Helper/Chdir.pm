#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Rex::JobControl::Helper::Chdir;

use Cwd;
require Exporter;
our @EXPORT;
@EXPORT = qw(chwd);
use base qw(Exporter);

sub chwd {
  my ($path, $code) = @_;

  my $cwd = getcwd;

  chdir $path;

  $code->();

  chdir $cwd;
}

1;
