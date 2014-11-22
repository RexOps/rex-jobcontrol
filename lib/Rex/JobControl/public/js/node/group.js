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

  delete_group_dialog: function() {

    var selected_node = $("#server_tree").jstree().get_selected(true);
    var project_id = ui.get_project_id();

    ui.dialog_confirm({
      "id": "delete_group_dialog",
      "title": "Really delete group?",
      "text": "Do you really want to delete '" + selected_node[0].text + "'?", 
      "button": "Delete",
      "height": 180,
      "ok": function() {


        rexio.call("DELETE",
               "1.0",
               [
                 "project", project_id,
                 "nodegroup", selected_node[0].id
               ],
               function(data) {
                 $.pnotify({
                   "title" : "Group removed",
                   "text"  : "Group "
                               + "<b>" + selected_node[0].text + "</b>"
                               + " removed. ",
                   "type"  : "info"
                 });

                 console.log("need to reload...");
               },
               function(data) {
                 $.pnotify({
                   "title" : "Error removing group",
                   "text"  : "Can't remove group "
                               + "<b>" + selected_node[0].text + "</b>"
                               + "<br /><br /><b>Error</b>: " + (data['error'] ? data['error'] : "Unknown error"),
                   "type"  : "error"
                 });
               });

      },
      "cancel": function() {}
    });
  },

  click_create_group: function() {
    console.log("creating new group");

    var parent_nodegroup_id = $("#server_tree").jstree().get_selected(true);

    var project_id = ui.get_project_id();

    console.log("parent: " + parent_nodegroup_id[0].id);
    console.log("project_id: " + project_id);

    rexio.call("POST",
               "1.0",
               [
                 "project", project_id,
                 "nodegroup", null,
                 "ref", {
                   "parent": parent_nodegroup_id[0].id,
                   "name": $("#name").val()
                 }
               ],
               function(data) {
                 $.pnotify({
                   "title" : "New group created",
                   "text"  : "New group "
                               + "<b>" + $("#name").val() + "</b>"
                               + " created. ",
                   "type"  : "info"
                 });

                 console.log("need to reload...");

                 $("#add_group").dialog("close");
               },
               function(data) {
                 $.pnotify({
                   "title" : "Error creating group",
                   "text"  : "Can't create new group "
                               + "<b>" + $("#name").val() + "</b>"
                               + "<br /><br /><b>Error</b>: " + data['error'],
                   "type"  : "error"
                 });
               });
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


