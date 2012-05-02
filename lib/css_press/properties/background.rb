module CSSPool
  module Properties
    class Background

      class << self
        attr_accessor :names
      end

      @@values = {
        'background-attachment' => %w{fixed scroll},
        'background-color' => [Terms::Hash, Terms::String, Terms::Rgb, 'transparent'],
        'background-image' => [Terms::URI, 'none'],
        'background-position' => %w{left center right top bottom}.push(Terms::Number),
        'background-repeat' => %w{no-repeat repeat repeat-x repeat-y}
      }

      self.names = @@values.keys.push 'background'

      def parse property, value

      end

    end
  end
end