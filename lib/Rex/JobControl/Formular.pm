#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::JobControl::Formular;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use Data::Dumper;

sub prepare_stash {
  my $self = shift;

  my $project = $self->project( $self->param("project_dir") );
  $self->stash( project => $project );

  my $formular = $project->get_formular( $self->param("formular_dir") );
  $self->stash( formular => $formular );
}

sub delete_data_item {
  my $self = shift;

  my $project = $self->project( $self->param("project_dir") );
  my $formular = $project->get_formular( $self->param("formular_dir") );

  my $current_forms = $self->session("formulars") || {};
  my $to_delete_id = $self->param("data_item");
  my $form = $formular->formulars->[$self->param("form_step")];

  $self->app->log->debug("Should delete: $to_delete_id");
  splice(@{ $current_forms->{$formular->name}->{$form->{name}} }, $to_delete_id, 1);

  $self->session(formulars => $current_forms);

  $self->redirect_to("/project/" . $project->directory . "/formular/" . $formular->directory . "/execute?form_step=" . $self->param("form_step"));
}

sub view_formular {
  my $self = shift;

  my $project = $self->project( $self->param("project_dir") );
  my $formular = $project->get_formular( $self->param("formular_dir") );

  my $form_step = $self->param("form_step") || 0;

  my $repeat = 0;

  if($form_step =~ m/^repeat\-(\d+)/) {
    $repeat = 1;
    $form_step = $1;
  }

  $self->stash(repeat => $repeat);
  $self->stash(form_step => $form_step);

  my $current_forms = $self->session("formulars") || {};

  if($form_step eq "cancel") {
    $current_forms->{$formular->name} = {};
    $self->session(formulars => $current_forms);
    $self->redirect_to("/project/" . $project->directory . "/formular/" . $formular->directory . "/execute?form_step=0");
    return;
  }

  if($form_step < 0) {
    $self->redirect_to("/project/" . $project->directory . "/formular/" . $formular->directory . "/execute?form_step=0");
    return;
  }

  my $save_form = 0;
  my $old_step = $form_step - 1;

  if($repeat) {
    $old_step = $form_step;
  }

  my $current_step = $formular->formulars->[$form_step];
  my $previous_step = $formular->formulars->[$old_step];

  my @field_names = map { $_->{name} } @{ $previous_step->{fields} };
  my @cur_field_names = map { $_->{name} } @{ $current_step->{fields} };

  if($self->param("posted") && $self->param("posted") eq "1") {

    $save_form = 1;

    if($save_form) {

      $current_forms->{$formular->name} ||= {};

      my $current_form = $current_forms->{$formular->name};
      my $form = $formular->formulars->[$old_step];

      $current_form->{$form->{name}} ||= {};

      my $current_form_data = $current_form->{$form->{name}};

      if($self->param("form_changed") eq "1") {
        if($repeat == 0) {
          # new data
          my %data;
          @data{ @field_names } = $self->param([@field_names]);
          $current_forms->{$formular->name}->{$form->{name}} = \%data;
        }
        elsif($repeat == 1) {
          my %data;
          @data{ @field_names } = $self->param([@field_names]);
          if(ref $current_forms->{$formular->name}->{$form->{name}} ne "ARRAY" && scalar(keys %{$current_forms->{$formular->name}->{$current_step->{name}}}) > 0) {
            $current_forms->{$formular->name}->{$form->{name}} = [$current_forms->{$formular->name}->{$form->{name}}];
          }
          elsif(ref $current_forms->{$formular->name}->{$form->{name}} ne "ARRAY") {
            $current_forms->{$formular->name}->{$form->{name}} = [];
          }

          push @{ $current_forms->{$formular->name}->{$form->{name}} }, \%data;
        }

        $self->session(formulars => $current_forms);
      }

    }


    #$self->redirect_to("/project/" . $project->directory . "/formular/" . $formular->directory . "/execute?form_step=$form_step");
    #return;

  }

  $self->stash(step_fields => \@cur_field_names);
  $self->stash(formular_config => $current_step);

  if(ref $current_forms->{$formular->name}->{$current_step->{name}} eq "ARRAY") {
    $self->stash(step_data => $current_forms->{$formular->name}->{$current_step->{name}}->[-1]);
    $self->stash(all_step_data => $current_forms->{$formular->name}->{$current_step->{name}});
  }
  elsif($current_forms->{$formular->name}->{$current_step->{name}} && scalar(keys %{$current_forms->{$formular->name}->{$current_step->{name}}}) > 0) {
    $self->stash(step_data => $current_forms->{$formular->name}->{$current_step->{name}});
    $self->stash(all_step_data => [$current_forms->{$formular->name}->{$current_step->{name}}]);
  }
  else {
    $self->stash(step_data => {});
    $self->stash(all_step_data => []);
  }

  if($repeat) {
    $self->stash(step_data => {});
  }



  if($form_step >= scalar(@{ $formular->steps })) {
    # form finished
    # save result in yaml file
    # and call rexfile

    print STDERR Dumper $current_forms->{$formular->name};

    $current_forms->{$formular->name} = {};
    $self->session(formulars => $current_forms);

    $self->render("formular/formular_finished");
    return;
  }



  $self->render;
}

1;
