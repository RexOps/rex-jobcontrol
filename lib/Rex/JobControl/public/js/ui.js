var class_ui = new Class({
  initialize: function() {
    this._objects      = new Object();
    this._ready_funcs  = new Array();
    this._resize_timer = new Object();
    this._classes      = new Object();
    this._data_tables  = new Object();
  },

  bootstrap: function() {
    console.log("bootstrapping ui...");

    for(var i = 0; i < this._ready_funcs.length; i++) {
      this._ready_funcs[i](this);
    }

    this.onload_page();
  },

  ready: function(func) {
    console.log("registering new ready function.");
    this._ready_funcs.push(func);
  },

  execute_plugin_hook: function(hook) {
    for(var obj in this._objects) {
      console.log("obj: " + obj);
      this._objects[obj]()[hook]();
    }
  },

  register_plugin: function(ref) {
    var self = this;
    var obj  = ref["object"];

    console.log("register plugin: " + obj);

    if(self._objects[obj]) {
      console.log("plugin (" + obj + ") already registered.");
      return;
    }

    var class_name = self.get_class_name(obj);
    self._objects[obj] = function() {
      console.log("trying to access: " + obj);

      if(! self._classes[class_name]) {
        self._classes[class_name] = new window[class_name](self);
      }

      return self._classes[class_name];
    };

    self.require_js(
      {
        "js" : "/js/" + obj + ".js",
        "cb" : function() {
          console.log("running onload_hooks (" + obj + ") ...");
          self._objects[obj]().onload();
        }
      }
    );
  },

  _init_objects: function() {
    var self = this;

    $(".rexio-ui-link").each(function(idx, elem) {
      if($(this).attr("rexio-initialized")) {
        console.log("object already initialized... skipping.");
        return;
      }

      $(this).attr("rexio-initialized", true);

      var obj          = $(elem).attr("rexio-ui-object");
      var click_action = $(elem).attr("rexio-ui-click");

      if(obj) {
        self.register_plugin(
          {
            "object" : obj
          }
        );

        $(elem).click(function(event) {
          self.load_plugin({
            "obj": obj,
            "event": event,
          });
        })
      }

      else if(click_action) {
        $(elem).click(function(event) {
          var tmp = click_action.split(/\./);
          console.log("Calling: " + tmp[0] + "." + tmp[1]);
          console.log(self);

          self._objects[tmp[0]]()[tmp[1]](
            {
              "event"  : event,
              "target" : event.currentTarget
            }
          );
        });
      }

    });

  },

  load_plugin: function(ref) {
    var self = this;

    var plg = ref['obj'];
    var event = ref['event'];
    var data = ref['data'];

    self.require_js(
      {
        "js": "/js/" + plg + ".js",
        "cb": function() {
          ui._objects[plg]().load(
            {
              "event"  : event ? event : null,
              "target" : event ? event.currentTarget : null,
              "data"   : data
            }
          );
        }
      }
    );
  },

  get_class_name: function(str) {
    return str.replace(/\//g, "_");
  },

  require_js: function(obj) {
    var js = obj["js"];
    var cb = ( obj["cb"] ? obj["cb"] : function() {} );

    console.log("require_js: " + js);
    $.getScript(js, function() {
      console.log("require_js: " + js + " loaded.");
      cb();
    })
  },

  onload_page: function() {
  console.log("onload_page");
    this._init_objects();
    this.prepare_ui_widgets();
  },

});
