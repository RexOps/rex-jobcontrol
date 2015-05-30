#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Helper::AuditLog;

use base 'Mojo::Log';
use Mojo::JSON qw(decode_json encode_json);
use DateTime;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = $proto->SUPER::new(@_);

  bless( $self, $proto );

  # $self->{json} = Mojo::JSON->new;

  return $self;
}

sub audit {
  my ( $self, $data ) = @_;
  my ( $package, $filename, $line ) = caller;

  my $dt = DateTime->now;
  $data->{package} = $package;

  $self->info( encode_json($data) );
}

sub json { (shift)->{json} }

1;
