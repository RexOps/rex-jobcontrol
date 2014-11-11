/**
 * ui class extensions for automatic ui management
 */

class_ui.implement({

  prepare_ui_widgets: function() {
    this._prepare_ui_widgets_button();
    this._prepare_ui_widgets_sortable();
    this._prepare_ui_widgets_tabs();
    this._prepare_ui_widgets_dialog();
    this._prepare_ui_widgets_ul_selectable();
    this._prepare_ui_widgets_select_dropdown();
  },

  _prepare_ui_widgets_dialog: function() {
    var self = this;

    console.log("preparing dialog widgets... ");

    $(".rexio-ui-dialog").each(function(idx) {
      var elem = this;

      var ok_button_text = ( $(elem).attr("rexio-dialog-button-ok") ? $(elem).attr("rexio-dialog-button-ok") : "Ok" );
      var tmp            = $(elem).attr("rexio-dialog-button-ok-click").split(/\./);

      var cancel_button_text = ( $(elem).attr("rexio-dialog-button-cancel") ? $(elem).attr("rexio-dialog-button-cancel") : "Cancel" );
      var tmp2               = $(elem).attr("rexio-dialog-button-cancel-click").split(/\./);

      var tmp3;

      if($(elem).attr("rexio-dialog-close")) {
        tmp3 = $(elem).attr("rexio-dialog-close").split(/\./);
      }

      var t_buttons = new Object();

      t_buttons[ok_button_text] = function() {
        self._objects[tmp[0]]()[tmp[1]]();
        $(this).dialog("close");
      };

      t_buttons[cancel_button_text] = function() {
        self._objects[tmp2[0]]()[tmp2[1]]();
        $(this).dialog("close");
      };

      var dialog_options = {
        autoOpen: ( $(elem).attr("rexio-dialog-auto-open") == "true" ? true : false ),
        height: ( $(elem).attr("rexio-dialog-height") ? $(elem).attr("rexio-dialog-height") : 500 ),
        width: ( $(elem).attr("rexio-dialog-width") ? $(elem).attr("rexio-dialog-width") : 500 ),
        modal: ( $(elem).attr("rexio-dialog-modal") == "true" ? true : false ),
        buttons: t_buttons,
        close: function() {
          if(tmp3) {
            self._objects[tmp3[0]]()[tmp3[1]]();
          }
        }
      };

      $(elem).dialog(dialog_options);

    });

  },

  _prepare_ui_widgets_tabs: function() {
    var self = this;
    $(".rexio-ui-tabs").each(function(idx) {
      var elem = this;
      $(elem).tabs(
        {
          "activate": function(event, ui) {
            if($(elem).attr("rexio-ui-activate")) {
              var tmp   = $(elem).attr("rexio-ui-activate").split(/\./);
              var scope = tmp[0];
              var func  = tmp[1];

              self._objects[scope]()[func](event, ui);
            }
          }
        }
      );
    });
  },

  _prepare_ui_widgets_select_dropdown: function() {
    var self = this;

    $(".rexio-ui-select").each(function() {
      var elem = this;
      var tmp;
      if($(elem).attr("rexio-ui-on-change")) {
        tmp = $(elem).attr("rexio-ui-on-change").split(/\./);
      }

      $(elem).on("change", function(event) {
        if(tmp) {
          self._objects[tmp[0]]()[tmp[1]](event);
        }
      });

    });
  },

  _prepare_ui_widgets_ul_selectable: function() {
    var self = this;

    $("ul.rexio-ui-selectable").each(function(idx) {
      var elem = this;

      var tmp;
      var tmp_sel;
      if($(elem).attr("rexio-selectable-on-stop")) {
        tmp = $(elem).attr("rexio-selectable-on-stop").split(/\./);
      }
      if($(elem).attr("rexio-selectable-on-selected")) {
        tmp_sel = $(elem).attr("rexio-selectable-on-selected").split(/\./);
      }

      $(elem).selectable({
        stop: function() {
          if(tmp) {
            self._objects[tmp[0]]()[tmp[1]]();
          }
        },
        selected: function(event, ui) {
          console.log(event);
          if(tmp_sel) {
            self._objects[tmp_sel[0]]()[tmp_sel[1]](event, ui);
          }
        }
      });

    });
  },

  _prepare_ui_widgets_button: function() {
    var self = this;
    console.log("preparing button widgets...");

    $(".rexio-ui-button").each(function(btn) {
      console.log("found button: " + $(this).attr("id"));
      $(this).button().click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        var tmp   = $(this).attr("rexio-ui-click").split(/\./);
        var scope = tmp[0];
        var func  = tmp[1];
console.log(scope);
console.log(func);
console.log(self._objects);
        self._objects[scope]()[func](event);
      });
    });
  },

  /**
   * automatically register sortable widgets.
   *
   * example:
   *   <ul id="registered_services" class="rexio-ui-sortable" rexio-ui-connect-with="#available_services">
   */
  _prepare_ui_widgets_sortable: function() {
    var self = this;
    console.log("preparing sortable widgets...");

    $(".rexio-ui-sortable").each(function() {
      console.log("found sortable: " + $(this).attr("id"));
      var connect_with = $(this).attr("rexio-ui-connect-with");

      if(connect_with) {
        $(this).sortable({
          connectWith: connect_with
        });
      }
      else {
        $(this).sortable();
      }
    });
  },

});
