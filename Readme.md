# css_press

csspool-st: [![Build Status](https://secure.travis-ci.org/stereobooster/css_press.png?branch=master)](http://travis-ci.org/stereobooster/css_press)
csspool: [![Build Status](https://secure.travis-ci.org/stereobooster/css_press.png?branch=csspool)](http://travis-ci.org/stereobooster/css_press)

## Main goals & principles

 - Compress css, but without support of any kind comment hacks. There are better ways to do crossbrowser styling. For example, [IE conditional comments](http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/).
 - Compression done with the help of real css parser ([csspool](https://github.com/tenderlove/csspool)). Not Regexps.
 - Pure ruby.

## Alternatives

 - [yuicssmin](https://github.com/matthiassiegel/yuicssmin). Ruby. The YUICSSMIN gem provides CSS compression using YUI compressor from Yahoo. It uses the Javascript port via ExecJS.
 - [cssminify](https://github.com/matthiassiegel/cssminify) Ruby. CSS minification with YUI compressor, but as native Ruby port.
 - [css-compressor](https://github.com/codenothing/css-compressor). The best of the best. P☣P :(
 - [yuicompressor](https://github.com/yui/yuicompressor). Java. Ruby wrapper: [ruby-yui-compressor](https://github.com/sstephenson/ruby-yui-compressor)
 - [rainpress](https://github.com/sprsquish/rainpress). Ruby. Seems to be dead ☠.
 - http://friggeri.net/blog/a-genetic-approach-to-css-compression/
 