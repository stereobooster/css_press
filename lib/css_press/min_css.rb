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
          if rs.media != current_media_type
            media = " " + rs.media.map do |medium|
              escape_css_identifier medium.name.value
            end.join(', ')
            tokens << "@media#{media}{"
          end

          tokens << rs.accept(self)

          if rs.media != current_media_type
            current_media_type = rs.media
            tokens << "}"
          end
        }
        tokens.join("\n")
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
        target.selectors.map { |sel| sel.accept self }.join(",") + "{" +
        target.declarations.map { |decl| decl.accept self }.join(";") +
        "}"
      end

      visitor_for CSS::Declaration do |target|
        important = target.important? ? ' !important' : ''

        "#{escape_css_identifier target.property}:" + target.expressions.map { |exp|

          is_color = ['color', 'background', 'border'].include? target.property

          if is_color then
            color = Color::min_color exp.to_s
            is_color = !color.nil?
          end

          if !is_color then
          
            op = '/' == exp.operator ? ' /' : exp.operator

            [
              op,
              exp.accept(self),
            ].join ''
          else
            color
          end
        }.join.strip + "#{important}"

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
        [
          target.unary_operator == :minus ? '-' : nil,
          target.value,
          target.type
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