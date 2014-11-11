var node_group = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  load: function(obj) {
    var self = this;
    console.log("Loading node_group plugin");
    self.bootstrap();
  },

  bootstrap: function() {
    var self = this;
    console.log("bootstrapping node_group plugin");
  },

  add_group_dialog: function() {
    $("#add_group").dialog("open");
  },

  click_create_group: function() {
    console.log("creating new group");
  /*
    rexio.call("POST",
               "1.0",
               "group",
               [
                 "group", null,
                 "ref", {
                   "name"     : $("#name").val(),
                 }
               ],
               function(data) {
                 if(data.ok != true || data.ok == 0) {
                   $.pnotify({
                     "title" : "Error creating group",
                     "text"  : "Can't create new group "
                                 + "<b>" + $("#name").val() + "</b>"
                                 + "<br /><br /><b>Error</b>: " + data['error'],
                     "type"  : "error"
                   });
                 }
                 else {
                   $.pnotify({
                     "title" : "New group created",
                     "text"  : "New group "
                                 + "<b>" + $("#name").val() + "</b>"
                                 + " created. ",
                     "type"  : "info"
                   });

                   self.ui.redirect_to("group/group");
                 }

                 $("#add_group").dialog("close");
               });
     */
  },

  click_create_group_cancel: function() {
    $("#add_group").dialog("close");
  },

});

ui.register_plugin(
  {
    "object" : "node/group"
  }
);


