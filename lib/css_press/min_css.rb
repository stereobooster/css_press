module CSSPool
  module Visitors
    class MinCSS < Visitor

      CSS_IDENTIFIER_ILLEGAL_CHARACTERS =
        (0..255).to_a.pack('U*').gsub(/[a-zA-Z0-9_-]/, '')
      CSS_STRING_ESCAPE_MAP = {
        "\\" => "\\\\",
        "\"" => "\\\"",
        "\n" => "\\a ", # CSS2 4.1.3 p3.2
        "\r" => "\\\r",
        "\f" => "\\\f"
      }

      def initialize
      end

      visitor_for CSS::Document do |target|
        # Default media list is []
        current_media_type = []

        tokens = []

        target.charsets.each do |char_set|
          tokens << char_set.accept(self)
        end

        target.import_rules.each do |ir|
          tokens << ir.accept(self)
        end

        target.rule_sets.each { |rs|
          rule_sets = rs.accept(self)
          if rule_sets != "" then
            if rs.media != current_media_type
              media = " " + rs.media.map do |medium|
                escape_css_identifier medium.name.value
              end.join(',')
              tokens << "@media#{media}{"
            end

            tokens << rule_sets

            if rs.media != current_media_type
              current_media_type = rs.media
              tokens << "}"
            end
          end
        }
        tokens.join
      end

      visitor_for CSS::Charset do |target|
        "@charset \"#{escape_css_string target.name}\";"
      end

      visitor_for CSS::ImportRule do |target|
        media = ''
        media = " " + target.media.map do |medium|
          escape_css_identifier medium.name.value
        end.join(', ') if target.media.length > 0

        "@import #{target.uri.accept(self)}#{media};"
      end

      visitor_for CSS::RuleSet do |target|

        is_q = false
        selectors = target.selectors.map do |sel| 
          selector = sel.accept self
          if selector =~ /^q:(after|before)/ then
            is_q = true
          end
          selector
        end.join(",") 

        temp = {}
        i = 0
        target.declarations.each do |decl|
          if temp.has_key?(decl.property) && !(decl.property == 'content' && is_q) then
            target.declarations[temp[decl.property]] = nil
          end
          temp[decl.property] = i
          i+=1
        end
        temp = nil
        target.declarations.compact!
        
        declarations = target.declarations.map { |decl| decl.nil? ? '' : decl.accept(self) }.join(";")
        if declarations == "" then
          ""
        else
          selectors + "{" + declarations + "}"
        end
      end

      visitor_for CSS::Declaration do |target|
        important = target.important? ? ' !important' : ''

        "#{escape_css_identifier target.property}:" + target.expressions.map { |exp|

          special_value = nil
          property = target.property.downcase

          if /(color|background|background-color)/ =~  property then
            special_value = Color::min_color exp.to_s
          end

          if /border(\-(top|bottom|left|right))?/ =~ property then
            if exp.to_s == 'none' then
              special_value = '0'
            else
              special_value = Color::min_color exp.to_s
            end
          end

          if special_value.nil? then
            [exp.operator, exp.accept(self)].join
          else
            special_value
          end
        }.join(' ').strip + "#{important}"

      end

      visitor_for Terms::Ident do |target|
        escape_css_identifier target.value
      end

      visitor_for Terms::Hash do |target|
        value = Color::min_hex target.value
        if value.nil? then
          value = "##{target.value}"
        end
        value
      end

      visitor_for Selectors::Simple, Selectors::Universal do |target|
        ([target.name] + target.additional_selectors.map { |x|
          x.accept self
        }).join
      end

      visitor_for Terms::URI do |target|
        "url(\"#{escape_css_string target.value}\")"
      end

      visitor_for Terms::Function do |target|
        "#{escape_css_identifier target.name}(" +
          target.params.map { |x|
            [
              x.operator,
              x.accept(self)
            ].compact.join(' ')
          }.join + ')'
      end

      visitor_for Terms::Rgb do |target|
        begin
          value = Color::min_rgb target
        rescue ArgumentError
          params = [
            target.red,
            target.green,
            target.blue
          ].map { |c|
            c.accept(self)
          }.join ','

          value = "rgb(#{params})"
        end
        value
      end

      visitor_for Terms::String do |target|
        "\"#{escape_css_string target.value}\""
      end

      visitor_for Selector do |target|
        target.simple_selectors.map { |ss| ss.accept self }.join
      end

      visitor_for Selectors::Type do |target|
        combo = {
          :s => ' ',
          :+ => '+',
          :> => '>'
        }[target.combinator]

        name = target.name == '*' ? '*' : escape_css_identifier(target.name)
        [combo, name].compact.join +
          target.additional_selectors.map { |as| as.accept self }.join
      end

      visitor_for Terms::Number do |target|
        value = target.value
        if value == 0 then
          value = '0'
        else
          trunc = value.truncate.round
          fract = value - trunc
          value = [
            trunc == 0 ? '' : trunc.to_s,
            fract == 0 ? '' : fract.to_s.sub(/^0/, '')
          ].join
        end

        [
          target.unary_operator == :minus && target.value != 0 ? '-' : nil,
          value,
          target.value == 0 ? '' : target.type
        ].compact.join
      end

      visitor_for Selectors::Id do |target|
        "##{escape_css_identifier target.name}"
      end

      visitor_for Selectors::Class do |target|
        ".#{escape_css_identifier target.name}"
      end

      visitor_for Selectors::PseudoClass do |target|
        if target.extra.nil?
          ":#{escape_css_identifier target.name}"
        else
          ":#{escape_css_identifier target.name}(#{escape_css_identifier target.extra})"
        end
      end

      visitor_for Selectors::Attribute do |target|
        case target.match_way
        when Selectors::Attribute::SET
          "[#{escape_css_identifier target.name}]"
        when Selectors::Attribute::EQUALS
          "[#{escape_css_identifier target.name}=#{escape_attribute target.value}]"
        when Selectors::Attribute::INCLUDES
          "[#{escape_css_identifier target.name}~=#{escape_attribute target.value}]"
        when Selectors::Attribute::DASHMATCH
          "[#{escape_css_identifier target.name}|=#{escape_attribute target.value}]"
        else
          raise "no matching matchway"
        end
      end

      private

      def escape_css_identifier text
        # CSS2 4.1.3 p2
        unsafe_chars = /[#{Regexp.escape CSS_IDENTIFIER_ILLEGAL_CHARACTERS}]/
        text.gsub(/^\d|^\-(?=\-|\d)|#{unsafe_chars}/um) do |char|
          if ':()-\\ ='.include? char
            "\\#{char}"
          else # I don't trust others to handle space termination well.
            "\\#{char.unpack('U').first.to_s(16).rjust(6, '0')}"
          end
        end
      end

      def escape_css_string text
        text.gsub(/[\\"\n\r\f]/) {CSS_STRING_ESCAPE_MAP[$&]}
      end

      def escape_attribute text
        if text.size == 0 || text =~ /[ \t\r\n\f"'`=<>]/ then
          '"' + escape_css_string(text) + '"'
        else
          escape_css_string text
        end
      end
    end
  end
end
