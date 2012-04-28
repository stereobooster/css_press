require 'json'

module CSSPool
  class Color
    class << self

      def load name
        data = File.read(File.expand_path("../../colors/#{name}.json", __FILE__))
        JSON.parse(data)
      end

      [:hex_to_short, :hex_to_safe, :long_to_hex].each do |name|
        define_method name do |val|
          @colors ||= {}
          @colors[name] ||= load name.to_s
          @colors[name][val]
        end
      end

      def color_val value, result, hash
        val = result.nil? ? value : result
        if hash && val.length == 6 && val[0] == val[1] && val[2] == val[3] && val[4] == val[5] then
          val = val.chars.to_a
          val = result = val[0] + val[2] + val[4]
        end
        if !result.nil? then
          result = hash ? "##{val}" : val
        end
        result
      end

      def min_hex value
        val = value.downcase
        result = hex_to_short val
        hash = result.nil?
        color_val val, result, hash
      end

      def min_color value
        val = value.downcase
        result = long_to_hex val
        hash = !result.nil?
        color_val val, result, hash
      end

      def min_rgb value
        rgb = [value.red, value.green, value.blue]
        rgb.map! do |color|
          color = color.to_s
          if color =~ /\%$/ then
            color = (color[0..-2].to_f / 100 * 256).round
          else
            color = color.to_i
          end
          if color > 255 then
            raise ArgumentError.new "Color value should be [0..255] or [0%..100%]"
          end
          color
        end
        rgb = '%02x%02x%02x' % rgb
        result = min_hex(rgb)
        if result.nil? then
          result = rgb
        end
        result
      end

    end
  end
end
