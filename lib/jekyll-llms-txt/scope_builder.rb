# frozen_string_literal: true

module JekyllLlmsTxt
  def self.register_scope_builder(&block)
    scope_builders << block
  end

  def self.scope_builders
    @scope_builders ||= []
  end

  # Builds root, category, collection, and registered scopes from census entries.
  class ScopeBuilder
    # @param site [Jekyll::Site]
    # @param configuration [Configuration]
    # @param entries [Array<Entry>] census entries, not copies
    # @return [Array<Scope>]
    def self.call(site, configuration, entries)
      new(site, configuration, entries).scopes
    end

    def initialize(site, configuration, entries)
      @site = site
      @configuration = configuration
      @entries = entries
    end

    def scopes
      [root_scope] + category_scopes + collection_scopes + custom_scopes
    end

    private

    def root_scope
      Scope.new(
        path_prefix: "/",
        title: @site.config["title"],
        description: @site.config["description"],
        entries: @entries
      )
    end

    def category_scopes
      return [] unless @configuration.categories

      category_names_in_census.map do |name|
        scoped = @entries.select { |entry| category_names(entry.item).include?(name) }
        Scope.new(
          path_prefix: category_prefix(name),
          title: name,
          description: "Category: #{name}",
          entries: scoped
        )
      end
    end

    def category_names_in_census
      @entries.flat_map { |entry| category_names(entry.item) }.uniq.sort
    end

    def category_names(item)
      item.data.fetch("categories") { [] }
    end

    def category_prefix(name)
      archives = @site.config["jekyll-archives"] || {}
      template = archives.dig("permalinks", "category") || "/category/:name/"
      slug = ::Jekyll::Utils.slugify(name, mode: archives["slug_mode"])
      template.sub(":name", slug)
    end

    def collection_scopes
      return [] unless @configuration.collections

      @configuration.include.filter_map do |name|
        next if name == "posts"

        collection = @site.collections[name]
        next unless collection&.write?

        scoped = @entries.select do |entry|
          entry.item.respond_to?(:collection) && entry.item.collection == collection
        end
        next if scoped.empty?

        label = collection.label
        Scope.new(
          path_prefix: "/#{label}/",
          title: label,
          description: "Collection: #{label}",
          entries: scoped
        )
      end
    end

    def custom_scopes
      JekyllLlmsTxt.scope_builders.flat_map do |builder|
        result = builder.call(@site, @configuration, @entries)
        Array(result).select { |scope| scope && !scope.entries.empty? }
      end
    end
  end
end
