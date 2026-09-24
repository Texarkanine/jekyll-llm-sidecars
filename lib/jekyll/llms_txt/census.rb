# frozen_string_literal: true

module Jekyll
  module LlmsTxt
    # Selects documents and registers one Entry for each of them.
    class Census
      # @param site [Jekyll::Site]
      # @param configuration [Configuration]
      # @return [Array<Entry>]
      def self.call(site, configuration)
        Entry.reset!
        new(site, configuration).entries
      end

      def initialize(site, configuration)
        @site = site
        @configuration = configuration
      end

      def entries
        documents.filter_map do |item|
          next if opted_out?(item)
          next if excluded?(item)

          Entry.new(
            item: item,
            summary_computer: ->(document) { Summary.line(document) },
            body_computer: ->(document) { Body.call(document) }
          )
        end
      end

      private

      def documents
        @configuration.include.flat_map { |name| documents_named(name) }
      end

      def documents_named(name)
        return @site.pages if name == "pages"

        @site.collections[name]&.docs || []
      end

      def opted_out?(item)
        item.data["llms"] == false
      end

      def excluded?(item)
        @configuration.exclude.any? do |glob|
          candidate_paths(item).any? do |path|
            File.fnmatch?(glob, path, File::FNM_PATHNAME)
          end
        end
      end

      def candidate_paths(item)
        [item.url, "/#{item.relative_path}", item.path]
      end
    end
  end
end
