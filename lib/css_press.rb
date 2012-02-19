require "css_press/version"
require "css_press/css"

module CssPress
  def self.press(text, options = {})
    CssPress::Css.new(options).press text
  end
end
