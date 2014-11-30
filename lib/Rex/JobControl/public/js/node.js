var node = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  delete_node_dialog: function() {

    var selected_node = table_selected[0];
    var project_id = ui.get_project_id();

    ui.dialog_confirm({
      "id": "delete_node_dialog",
      "title": "Really delete node?",
      "text": "Do you really want to delete '" + table_selected[1] + "'?", 
      "button": "Delete",
      "height": 180,
      "ok": function() {

        rexio.call("DELETE",
               "1.0",
               [
                 "project", project_id,
                 "node", selected_node
               ],
               function(data) {
                 $.pnotify({
                   "title" : "Node removed",
                   "text"  : "Node "
                               + "<b>" + table_selected[1] + "</b>"
                               + " removed. ",
                   "type"  : "info"
                 });

                 console.log("need to reload...");
               },
               function(data) {
                 $.pnotify({
                   "title" : "Error removing node",
                   "text"  : "Can't remove node "
                               + "<b>" + table_selected[1] + "</b>"
                               + "<br /><br /><b>Error</b>: " + (data['error'] ? data['error'] : "Unknown error"),
                   "type"  : "error"
                 });
               });

      },
      "cancel": function() {}
    });
  },

});

ui.register_plugin(
  {
    "object" : "node"
  }
);


// --- end
