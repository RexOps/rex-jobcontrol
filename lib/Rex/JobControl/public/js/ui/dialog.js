/**
 * dialog implementations for ui class.
 */
class_ui.implement({
  /**
   * Create confirmation dialog
   *
   * ref.id    uniq ID
   * ref.title  title
   * ref.text  text to display
   * ref.button text of "ok" button
   * ref.height hight of the dialog
   * ref.ok    callback function if "ok" button pressed
   * ref.cancel callback function if "cancel" button pressed
   */
  dialog_confirm: function(ref) {
    var dlg_html = new Array('<div id="diag_' + ref.id + '" title="' + ref.title + '">');
    dlg_html.push('<p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>' + ref.text + '</p>');
    dlg_html.push('</div>');

    var the_buttons = {};
    the_buttons[ref.button] = function() {
      $( this ).dialog( "close" );
      ref.ok();

      $( this ).dialog( "destroy" );
      $( "#diag_" + ref.id ).remove();
    };

    the_buttons["Cancel"] = function() {
      $( this ).dialog( "close" );
      $( this ).dialog( "destroy" );

      $( "#diag_" + ref.id ).remove();
      ref.cancel();
    };

    $("body").append(dlg_html.join("\n"));
    $("#diag_" + ref.id).dialog({
        resizable: false,
        height: (ref.height || 200),
        width: (ref.width || 350),
        modal: true,
        autoOpen: true,
        buttons: the_buttons
    });
  },

  /**
   * Create message dialog
   *
   * ref.id    uniq ID
   * ref.title  title
   * ref.text  text to display
   * ref.height hight of the dialog
   * ref.ok    callback function if "ok" button pressed
   */
  dialog_msgbox: function(ref) {
    var dlg_html = new Array('<div id="msgbox_' + ref.id + '" title="' + ref.title + '">');
    dlg_html.push('<p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>' + ref.text + '</p>');
    dlg_html.push('</div>');

    if(typeof ref["ok"] == "undefined") {
      ref["ok"] = function() {};
    }

    var the_buttons = {};
    the_buttons["Ok"] = function() {
      $( this ).dialog( "close" );
      ref.ok();

      $( this ).dialog( "destroy" );
      $( "#msgbox_" + ref.id ).remove();
    };

    $("body").append(dlg_html.join("\n"));
    $("#msgbox_" + ref.id).dialog({
        resizable: false,
        height: (ref.height || 180),
        modal: true,
        autoOpen: true,
        buttons: the_buttons
    });
  }

});
