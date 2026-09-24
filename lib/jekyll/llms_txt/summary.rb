# frozen_string_literal: true

module Jekyll
  module LlmsTxt
    # Builds the index name and notes from fields Jekyll already stored.
    class Summary
      Line = Data.define(:name, :notes)

      # @param item [Jekyll::Page, Jekyll::Document]
      # @return [Line] link text and optional notes; notes are one line
      def self.line(item)
        Line.new(link_text(item), notes(item))
      end

      def self.link_text(item)
        title = present_string(item.data["title"])
        return title if title

        filename(item)
      end
      private_class_method :link_text

      def self.filename(item)
        if item.respond_to?(:name)
          named = present_string(item.name)
          return named if named
        end

        item.basename
      end
      private_class_method :filename

      def self.notes(item)
        text = present_string(item.data["description"]) || excerpt_text(item)
        return if text.nil?

        text.gsub(/\r\n|\n|\r/, " ")
      end
      private_class_method :notes

      def self.excerpt_text(item)
        excerpt = item.data["excerpt"]
        raw = if excerpt.is_a?(String)
                excerpt
              elsif excerpt.respond_to?(:content)
                excerpt.content
              end
        present_string(raw)
      end
      private_class_method :excerpt_text

      def self.present_string(value)
        return unless value.is_a?(String)
        return unless value.match?(/\S/)

        value
      end
      private_class_method :present_string
    end
  end
end
