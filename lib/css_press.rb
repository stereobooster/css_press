require "css_press/version"
require "css_press/css"
require "css_press/min_css"
require "css_press/node"
require "css_press/color"

module CssPress
  def self.press(text, options = {})
    CssPress::Css.new(options).press text
  end
end
