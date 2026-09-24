# frozen_string_literal: true

module Jekyll
  module LlmsTxt
    class << self
      attr_accessor :current_destinations
    end

    # Census, scopes, and rendered destination files for one site build.
    class BuildState
      def initialize(hrefs:, files:)
        @hrefs = hrefs
        @files = files
      end

      attr_reader :files

      def href_for(item)
        @hrefs[item]
      end
    end

    # Binds census entries to manifest rows and enqueues those files.
    class Generator < Jekyll::Generator
      # @param site [Jekyll::Site]
      # @return [void]
      def generate(site)
        configuration = Configuration.new(site)
        entries = Census.call(site, configuration)
        scopes = ScopeBuilder.call(site, configuration, entries)
        rows = Manifest.build(configuration, scopes, entries)
        sidecar_rows = rows.select { |row| row.kind == :sidecar }
        sidecar_paths = sidecar_rows.to_h { |row| [row.entries.first, row.path] }
        hrefs = sidecar_rows.to_h { |row| [row.entries.first.item, absolute(site, row.path)] }

        files = rows.map { |row| [row.path, render_row(row, site, sidecar_paths)] }
        Jekyll::LlmsTxt.current_destinations = files.map do |path, _content|
          Jekyll.sanitized_path(site.dest, path)
        end
        site.instance_variable_set(
          :@llms_txt,
          BuildState.new(hrefs: hrefs, files: files)
        )
      end

      private

      def render_row(row, site, sidecar_paths)
        case row.kind
        when :index
          index_text(row.scope, site, sidecar_paths)
        when :corpus
          corpus_text(row)
        when :sidecar
          row.entries.first.body
        end
      end

      def corpus_text(row)
        ordered_entries(row.entries).map { |entry| corpus_block(entry, row.scope) }.join("\n\n")
      end

      def corpus_block(entry, scope)
        body = entry.body.sub(/\n+\z/, "")
        return body if scope.path_prefix == "/"

        "# #{entry.summary.name}\n\n#{body}"
      end

      def index_text(scope, site, sidecar_paths)
        lines = []
        lines << (scope.title.empty? ? "#" : "# #{scope.title}")
        lines << ""
        if scope.description
          lines << "> #{scope.description}"
          lines << ""
        end
        index_sections(scope).each do |heading, section_entries|
          lines << "## #{heading}"
          lines << ""
          section_entries.each do |entry|
            path = sidecar_paths.fetch(entry, entry.item.url)
            lines << index_item(entry, path, site)
          end
          lines << ""
        end
        text = +""
        lines.each { |line| text << line << "\n" }
        "#{text.sub(/\n+\z/, "")}\n"
      end

      def index_item(entry, path, site)
        line = entry.summary
        text = "- [#{line.name}](#{absolute(site, path)})"
        line.notes.nil? ? text : "#{text}: #{line.notes}"
      end

      def index_sections(scope)
        ordered_groups(scope.entries).map { |label, grouped| [heading_for(label), grouped] }
      end

      def ordered_entries(entries)
        ordered_groups(entries).flat_map { |_label, grouped| grouped }
      end

      def ordered_groups(entries)
        groups = entries.group_by { |entry| section_label(entry.item) }
        head = %w[posts pages].filter_map do |label|
          grouped = groups.delete(label)
          [label, grouped] if grouped
        end
        head + groups.sort
      end

      def section_label(item)
        return "pages" if item.is_a?(Jekyll::Page)

        item.collection.label
      end

      def heading_for(label)
        label.sub(/\A./, &:upcase)
      end

      def absolute(site, path)
        "#{site.config["url"]}#{site.config["baseurl"]}#{path}"
      end
    end
  end
end
