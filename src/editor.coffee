
$ = require "jquery"

require "touch-splitter-jquery/src/touchsplitter.css"
require "touch-splitter-jquery/src/jquery.touchsplitter.coffee"
CodeMirror = require "./codemirror.coffee"
CoffeeScript = require "../vendor/coffee-script.js"

require "codemirror/lib/codemirror.css"
require "codemirror/theme/elegant.css"

module.exports = ->
  editor = {}

  editor.outputSplitter = $("#output-splitter").touchSplit({orientation:"vertical"})
  editor.codeSplitter = $("#code-splitter").touchSplit()

  editor.codeSplitter.on 'resize', (e) ->
    editor.coffeescript.refresh()
    editor.javascript.refresh()
  checkToUseSpacesInsteadofTabs = (cm) ->
    if(cm.getOption("indentWithTabs"))
      return CodeMirror.Pass
    indentUnit = cm.getOption("indentUnit")
    getYoSpaceCount = (head) ->
      # Use preceding to determine what room is taken by tabs
      preceding = cm.getRange {line:head.line, ch:0}, head
      tabCount = 0
      tabreg = /\t/g
      while(tabreg.exec preceding)
        tabCount++
      return indentUnit - (head.ch + tabCount*(indentUnit - 1)) % indentUnit
    makeYoSpaces = (spaceCount) ->
      spaces = ""
      for [1..spaceCount]
        spaces += " "
      return spaces
    putYoSpacesHere = (range) ->
      {anchor, head} = range
      if anchor.line isnt head.line and anchor.ch isnt head.ch
        for line in [anchor.line...head.line]
          curLine = cm.getLine(line)
          curPos = {line, ch:0}
          cm.replaceRange makeYoSpaces(indentUnit), curPos, curPos
        #anchor.ch += indentUnit
        #head.ch += indentUnit
      else
        cm.replaceRange makeYoSpaces(getYoSpaceCount(head)), anchor, head
    cm.doc.sel.ranges.forEach putYoSpacesHere
  editor.coffeescript = CodeMirror.fromTextArea document.getElementById("cm-coffeescript"), {
    mode: "coffeescript"
    tabMode: "indent"
    useTabs: true
    indentWithTabs: false
    indentUnit: 2
    theme: "elegant"
    styleSelectedText: true
    lineNumbers: true
    autoCloseBrackets: true
    showCursorWhenSelecting: true
    autofocus: true
    keyMap: "sublime"
    extraKeys:
      "Tab" : checkToUseSpacesInsteadofTabs
      "Ctrl-Enter": ->
        editor.run()
      "Ctrl-S": ->
        Clear()
        editor.run()
  }
  editor.javascript = CodeMirror.fromTextArea document.getElementById("cm-javascript"), {
    mode: "javascript"
    styleSelectedText: true
    showCursorWhenSelecting: true
    cursorBlinkRate: 0
    keyMap: "sublime"
    readOnly: true
  }
  editor.compile = ->
    source = editor.coffeescript.doc.getValue()
    editor.compiledJS = ""
    try
      editor.compiledJS = CoffeeScript.compile source, bare: on
      editor.javascript.doc.setValue(editor.compiledJS)
      $('#error').hide()
      editor.errorHandler null
    catch {location, message}
      if location?
        message = "Error on line #{location.first_line + 1}: #{message}"
      $('#error').text(message).show()
      editor.errorHandler {location, message}
  editor.currentError = null
  editor.errorHandler = (err) ->
    editor.currentError?.clear?()
    editor.currentError = null
    if err
      err = err.location
      if (not err.last_column and not err.last_line) or
         (err.last_column is err.first_column and err.last_line is err.first_line)
        editor.currentError = editor.coffeescript.setBookmark(
          {line:err.first_line, ch:err.first_column},
          {widget:editor.makeWidget()}
        )
      else  
        editor.currentError = editor.coffeescript.markText(
          {line:err.first_line, ch:err.first_column},
          {line:err.last_line,  ch:err.last_column},
          {className:"cm-error"}
        )
  editor.makeWidget= ->
    widget = document.createElement("span")
    widget.style.borderLeft = "1px solid rgba(255,50,50,.6)"
    widget.style.borderRight = "1px solid rgba(255,120,120,.6)"
    widget.style.marginLeft = "-1px"
    widget.style.marginRight = "-1px"
    widget
  editor.run = ->
    script = document.createElement("script")
    script.innerHTML = editor.compiledJS
    script.id = "compilation"
    $("#compilation").remove()
    document.body.appendChild script
  editor.store = ->
    if Storage?
      sessionStorage.code = editor.coffeescript.getValue()
    else
      return false
  editor.storeLibraries = ->
    if Storage?
      localStorage.libraries = editor.getDistinctArray(editor.libraries).join ','
    else
      return false
  editor.refresh = ->
    location.href = location.href.replace /#.+$/, ''
  editor.coffeescript.on "change", ->
    editor.compile()
    editor.store()
  editor.libraries = []
  editor.scriptsLoading = 0
  editor.que = ->
    editor.scriptsLoading++
    return (success, url)->
      editor.scriptsLoading--
      if success
        Say "<span style='color:green'><a href='#{url}'>#{url}</a> loaded.</span>"
      else
        Say "<span style='color:red'><a href='#{url}'>#{url}</a> failed to load.</span>"
      if editor.scriptsLoading is 0
        Say "All scripts are loaded"

  editor.addLibrary = (siblingelement)->
    urlInput = $(siblingelement.parentNode).find("input")
    url = urlInput.val()
    urlInput.val("")
    editor.addLibraryFromUrl url

  editor.addLibraryFromUrl = (url)->
    editor.loadLibrary(url)
    editor.libraries.push url
    editor.libraries = editor.getDistinctArray editor.libraries
    localStorage.libraries = editor.libraries.join(',')
    libraryli = document.createElement 'li'
    hex = Math.random() * 0xFFFFFF
    libraryli.innerHTML = """
      <a id='lib#{hex.toString()}' href='#{url}'>
        #{(url.match /([^\/]+\.js$)/)[1]}
      </a>
      <span>-</span>
    """
    $('.dropdown.libraries ul').append(libraryli).find('span').click editor.remLibrary

  editor.remLibrary = (event)->
    liUrl = $(event.target).parent()
    url = liUrl.find('a').attr('href')
    liUrl.remove()
    newLibs = []
    for lib in editor.libraries
      if lib isnt url
        newLibs.push lib
    editor.libraries = newLibs
    editor.storeLibraries()
    editor.refresh()

  editor.loadLibrary = (libURL) ->
    que = editor.que()
    $.getScript(libURL).done(()->
      que(true,libURL)
    ).fail () ->
      console.log arguments
      que(false,libURL)

  editor.share = ->
    window.prompt "Link to share: (Ctrl-C, Enter)", location.href.replace(/#.+$/, '') + '#' + encodeURIComponent editor.coffeescript.getValue()
  editor.getDistinctArray = (arr) ->
    dups = {}
    arr.filter (el)->
      hash = el.valueOf()
      isDup = dups[hash]
      dups[hash] = true
      return !isDup

  editor.setPremade = (premadeName) ->
    @coffeescript.setValue(premade[premadeName])
  premade = {
    "Fruit Class":"""
      class Fruit
        constructor: (@name) ->

        eat: ->
          Say \"I\'m eating \#{@name}\"

      apple = new Fruit(\"Apple\")

      apple.eat()
      """
    "Extending Fruit Class": """
      class Fruit
        constructor: (@name) ->

        eat: ->
          Say \"I\'m eating \#{@name}\"

      class ColoredFruit extends Fruit
        constructor: (name, @color) ->
          super(name)

        observe: ->
          Say \"I\'m a \#{@color} \#{@name}\"

        eatIfColor: (colorYouLike) ->
          if @color is colorYouLike
            @eat()
          else
            Say (\"I don\'t like \#{@name}, because they are \#{@color}\")

      apple = new ColoredFruit(\"Apple\", \"red\")

      apple.observe()

      apple.eatIfColor(\"red\")
      """
    "Array Iteration": """
      nums = [0..5] # [0,1,2,3,4,5]

      for num in nums when num%2 is 0
        Say \"Even: \" + num

      for num in nums[1..3]
        Say \"Sliced: \" + num
      """
  }

  if Storage? and sessionStorage.code
    editor.coffeescript.setValue sessionStorage.code

  if Storage? and localStorage.libraries
    editor.libraries = editor.getDistinctArray localStorage.libraries.split ','
    for libURL in editor.libraries
      editor.addLibraryFromUrl(libURL)

  if location.hash
    editor.coffeescript.setValue decodeURIComponent location.hash[1..]
    editor.refresh() if editor.store()
  
  editor.compile()

  return editor