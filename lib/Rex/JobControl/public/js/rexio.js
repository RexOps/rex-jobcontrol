var class_rexio = new Class({
  initialize: function() {
  },
  call: function(
    method,
    version,
    options,
    done_cb,
    fail_cb
  ) {
    var ref, url;

    url = "/api/" + version;

    for(var i = 0; i < options.length; i+=2) {
      var key   = options[i];
      var value = options[i+1];
      if(key == "ref") {
        ref = value;
        continue;
      }

      if(value && value != null) {
        url += "/" + key + "/" + value;
      }
      else {
        url += "/" + key;
      }
    }

    console.log("url: " + url);

    $.ajax(
      {
        "type": method,
        "url" : url,
        "data": (ref ? JSON.stringify(ref) : null)
      }
    ).done(function(data) { done_cb(data); });
  }
});

// rexio.call("GET", "1.0", "service", [ "service", 4, "host", 1 ])
var rexio = new class_rexio();
