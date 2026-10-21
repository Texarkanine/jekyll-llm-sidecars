# frozen_string_literal: true

module JekyllLlmSidecars
  # Heading block for a Markdown sidecar. The H1 is the index title.
  # A post also gets a date line, and the author when that value is a
  # non-blank string. The string ends with a blank line so it can be
  # concatenated with the rendered source body.
  class Preamble
    # @param item [Jekyll::Page, Jekyll::Document]
    # @return [String]
    def self.call(item)
      lines = ["# #{Summary.line(item).name}", ""]
      meta = meta_line(item)
      lines << meta << "" if meta
      "#{lines.join("\n")}\n"
    end

    def self.meta_line(item)
      return unless post?(item)

      date = item.data["date"].strftime("%Y-%m-%d")
      author = author_text(item.data["author"])
      author ? "#{date} - #{author}" : date
    end
    private_class_method :meta_line

    def self.post?(item)
      item.respond_to?(:collection) && item.collection&.label == "posts"
    end
    private_class_method :post?

    def self.author_text(value)
      return unless value.is_a?(String)
      return unless value.match?(/\S/)

      value
    end
    private_class_method :author_text
  end
end
