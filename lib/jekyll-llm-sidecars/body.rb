# frozen_string_literal: true

module JekyllLlmSidecars
  # Renders a document's source body once. Liquid runs. Converters and layouts do not.
  class Body
    # @param item [Jekyll::Page, Jekyll::Document]
    # @return [String] front matter is already absent from item.content
    def self.call(item)
      content = item.content
      return content unless item.render_with_liquid?

      render_liquid(item, content)
    end

    def self.render_liquid(item, content)
      payload = item.site.site_payload
      page = item.to_liquid
      payload["page"] = page
      liquid = item.site.config["liquid"]
      info = {
        registers: { site: item.site, page: page },
        strict_filters: liquid["strict_filters"],
        strict_variables: liquid["strict_variables"]
      }
      Liquid::Template.parse(content, line_numbers: true).render!(payload, info)
    end
    private_class_method :render_liquid
  end
end
