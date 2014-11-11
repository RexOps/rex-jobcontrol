var ui_plugin = new Class({
  initialize: function(ui) {
    this.ui = ui;
  },

  onload: function() {
    console.log("ui_plugin.onload: needs to be implemented by subclass.");
  }
});
