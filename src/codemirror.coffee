((mod) ->
  if typeof exports is "object" and typeof module is "object" # CommonJS
    module.exports = mod()
  else if typeof define is "function" and define.amd # AMD
    define([], mod)
  else # Plain browser env
    mod()
)( ->
  cm = require "codemirror"
  require "codemirror/mode/javascript/javascript.js"
  require "codemirror/mode/coffeescript/coffeescript.js"
  require "codemirror/addon/edit/closebrackets.js"
  require "codemirror/addon/selection/mark-selection.js"
  require "codemirror/addon/search/searchcursor.js"
  require "codemirror/addon/search/match-highlighter.js"
  require "codemirror/keymap/sublime.js"
  cm
)