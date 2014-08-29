package Rex::JobControl::Dashboard;
use Mojo::Base 'Mojolicious::Controller';

sub prepare_stash {
  my $self = shift;

  my @projects;

  opendir(my $dh, $self->config->{project_path}) or die($!);
  while(my $entry = readdir($dh)) {
    next if (! -f $self->config->{project_path} . "/$entry/project.conf.yml" );
    push @projects, $self->project($entry);
  }
  closedir($dh);

  $self->stash(project_count => scalar(@projects));
  $self->stash(projects => \@projects);
}

sub index {
  my $self = shift;
  $self->render;
}

1;
