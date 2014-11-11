var node = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  }

});

ui.register_plugin(
  {
    "object" : "node"
  }
);


// --- end
