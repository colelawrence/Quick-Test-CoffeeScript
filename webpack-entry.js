
setup = require("./src/editor.coffee")
require("./src/editor.css")
$ = require("jquery")

window.Say = function(o){
  console.log.apply(console, arguments)
  $("#info").append(o.toString() + "\n")
}
window.Clear = function(){
  $("#info").html('')
}

window.editor = setup()