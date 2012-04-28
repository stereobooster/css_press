# css_press

csspool-st: [![Build Status](https://secure.travis-ci.org/stereobooster/css_press.png?branch=master)](http://travis-ci.org/stereobooster/css_press)
csspool: [![Build Status](https://secure.travis-ci.org/stereobooster/css_press.png?branch=csspool)](http://travis-ci.org/stereobooster/css_press)

## Main goals & principles

 - Compress css, but without support of any kind comment hacks. There are better ways to do crossbrowser styling. For example, [IE conditional comments](http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/).
 - Compression done with the help of real css parser ([csspool](https://github.com/tenderlove/csspool)). Not Regexps.
 - Pure ruby.

## Alternatives

 - [rainpres](https://github.com/sprsquish/rainpress). Seems to be dead ☠.
 - [css-compressor](https://github.com/codenothing/css-compressor). The best of the best. P☣P :(
 - [yuicompressor](https://github.com/yui/yuicompressor). Java
 - [ruby-yui-compressor](https://github.com/sstephenson/ruby-yui-compressor). Ruby wrapper for yuicompressor
