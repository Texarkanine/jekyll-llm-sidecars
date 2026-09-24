# frozen_string_literal: true

module JekyllLlmSidecars
  # One row per output path. A second insert for a path fails.
  class Manifest
    class Collision < StandardError; end

    Row = Data.define(:path, :kind, :entries, :scope)

    # @param configuration [Configuration]
    # @param scopes [Array<Scope>]
    # @param entries [Array<Entry>]
    # @return [Array<Row>]
    def self.build(configuration, scopes, entries)
      manifest = new
      manifest.add_indexes(configuration, scopes)
      manifest.add_corpora(configuration, scopes)
      manifest.add_sidecars(configuration, entries)
      manifest.rows
    end

    def initialize
      @rows = {}
    end

    # @param path [String]
    # @param kind [Symbol]
    # @param entries [Array<Entry>]
    # @param scope [Scope, nil]
    # @return [Row]
    def add(path, kind, entries, scope = nil)
      raise Collision, "duplicate output path #{path}" if @rows.key?(path)

      @rows[path] = Row.new(path: path, kind: kind, entries: entries, scope: scope)
    end

    # @return [Array<Row>]
    def rows
      @rows.values
    end

    def add_indexes(configuration, scopes)
      return unless configuration.llms_txt

      scopes.each do |scope|
        add(output_path(scope.path_prefix, "llms.txt"), :index, scope.entries, scope)
      end
    end

    def add_corpora(configuration, scopes)
      return unless configuration.llms_full

      scopes.each do |scope|
        markdown_entries = scope.entries.select { |entry| markdown?(entry.item) }
        add(output_path(scope.path_prefix, "llms-full.txt"), :corpus, markdown_entries, scope)
      end
    end

    def add_sidecars(configuration, entries)
      return unless configuration.markdown

      entries.each do |entry|
        next unless markdown?(entry.item)

        add(sidecar_path(entry.item.url), :sidecar, [entry])
      end
    end

    private

    def output_path(prefix, filename)
      "#{prefix}#{filename}"
    end

    def sidecar_path(url)
      return "#{url}index.md" if url.end_with?("/")

      leaf = url.rpartition("/").last
      return "#{url}.md" unless leaf.include?(".")

      url.sub(/\.[^.]+\z/, ".md")
    end

    def markdown?(item)
      extension = item.extname.delete_prefix(".")
      markdown_extensions(item).include?(extension)
    end

    def markdown_extensions(item)
      item.site.config.fetch("markdown_ext").split(",").map(&:strip)
    end
  end
end
