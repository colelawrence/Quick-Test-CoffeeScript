Quick-Test-CoffeeScript
=======================

Quickly test CoffeeScript and witness the javascript output


This is basically a more advanced version of the Try CoffeeScript editor on [coffeescript.org](http://coffeescript.org/#try)

This editor is more functional because it embeds compiled javascript directly into the page which allows window binding properties and DevTools console inspection.

The editor comes with a prebuilt `Say(object)` function that will print the `oject.toString()` to an output area on the webpage.

<p align="center">
  <a href="http://zombiehippie.github.io/Quick-Test-CoffeeScript/">Launch Quick-Test-CoffeeScript</a>
</p>

## Forking
1. Submodules
  `git submodule init`
  `git submodule update`
2. jQuery (with git and npm installed for Win)
  (from jquery/readme.md)
  `cd lib/jQuery`
  `npm run build`
3. Build Quick Test CoffeeScript (with coffeescript installed globally)
  `cd ../../` (Now in root dir of repo)
  `cake build`