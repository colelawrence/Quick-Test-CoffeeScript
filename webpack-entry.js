var setup = require("./src/editor.coffee"),
  $ = require("jquery");

require("./src/editor.css")

window.Say = function(o){
  console.log.apply(console, arguments)
  $("#info").append(o.toString() + "\n")
}
window.Clear = function(){
  $("#info").html('')
}

window.editor = setup()