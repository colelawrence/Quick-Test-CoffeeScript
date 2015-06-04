Quick-Test-CoffeeScript
=======================

![screenshot](https://cloud.githubusercontent.com/assets/2925395/7991892/29e1eaac-0ac1-11e5-84f5-cc3ffe22929b.png)

Quickly test CoffeeScript and witness the javascript output

This is basically a more advanced version of the Try CoffeeScript editor on [coffeescript.org](http://coffeescript.org/#try)

This editor is more functional because it embeds compiled javascript directly into the page which allows window binding properties and DevTools console inspection.

The editor comes with a prebuilt `Say(object)` function that will print the `object.toString()` to an output area on the webpage, and a complimentary `Clear()` function for clearing the output window.

<p align="center">
  <a href="http://zombiehippie.github.io/Quick-Test-CoffeeScript/">Launch Quick-Test-CoffeeScript</a>
</p>

## Building
Quick-Test-CoffeeScript uses [webpack](http://github.com/webpack/webpack) to build.

 1. Setup with `npm install`
 2. Build with `node ./node_modules/webpack/bin/webpack.js`
