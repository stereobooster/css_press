require 'csspool'

module CssPress
  class Css

    DEFAULTS = { 
    }

    def initialize (options = {})
      @options = DEFAULTS.merge(options)
    end

    def press (css)
      css_in = css.respond_to?(:read) ? css.read : css.dup
      doc = CSSPool.CSS css_in
      doc.min_css
    end

  end
end
