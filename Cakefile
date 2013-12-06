{spawn, exec} = require 'child_process'
fs = require 'fs'

task 'build', 'Build Quick-Test-CoffeeScript into a single html file',(options)->
  fs.readFile('./QuickTestCoffeeScript.html', 'utf8', (err, data)->
    if err
      return console.log err
    cssFileRegex = /<link.*href="(lib[^"]+\.css)">/g
    scriptFileRegex = /<script.*src="(lib[^"]+.js)"><\/script>/g
    cssFiles = []
    scriptFiles = []

    console.log typeof data

    while match = cssFileRegex.exec data
      cssFiles.push match[1]
    data = data.replace cssFileRegex, ""

    while match = scriptFileRegex.exec data
      scriptFiles.push match[1]
    data = data.replace scriptFileRegex, ""

    processCss = (cssFiles, callback, index = 0) ->
      if not cssfilename = cssFiles[index]
        return callback cssFiles
      fs.readFile(cssfilename, 'utf8', (err, cssdata)->
        cssdata = cssdata.replace /\t+|\s+/g, " "
        cssdata = cssdata.replace /([\{\}\:])\s+/g, "$1"
        cssdata = cssdata.replace ///
          /\* [\W\w]+? \*/
        ///g, ""
        console.log "loaded css: #{cssfilename}, #{cssdata}"
        cssFiles[index++] = cssdata
        processCss cssFiles, callback, index
      )
    writeIndexHtml = (file) ->
      fs.writeFile('./index.html',data)
    processCss cssFiles, (cssdata)->
      data = data.replace /(<\/title>)/, """$1\n<style>#{cssdata.join " "}</style>"""
      exec """java -jar "lib/compiler.jar" --js #{scriptFiles.join " "} --js_output_file ./temp.min.js""", (err, stdout, stderr) ->
        throw stderr if stderr
        console.log "Hello"
      fs.readFile('./temp.min.js', 'utf8', (err, minijs)->
        if err
          return console.log err
        data = data.replace /(<\/footer>)/, """<script>#{minijs}</script>$1"""
        writeIndexHtml(data)
      )
  )