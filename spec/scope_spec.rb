# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::LlmsTxt::ScopeBuilder do
  around do |example|
    saved = Jekyll::LlmsTxt.scope_builders.dup
    Jekyll::LlmsTxt.scope_builders.clear
    example.run
  ensure
    Jekyll::LlmsTxt.scope_builders.replace(saved)
  end

  def entries_for(site)
    Jekyll::LlmsTxt::Census.call(site, Jekyll::LlmsTxt::Configuration.new(site))
  end

  def scopes_for(site)
    described_class.call(site, Jekyll::LlmsTxt::Configuration.new(site), entries_for(site))
  end

  def scope_at(scopes, prefix)
    scopes.find { |scope| scope.path_prefix == prefix }
  end

  describe ".call" do
    it "uses the site title and description on the root scope" do
      site = build_site(
        { "about.md" => page_body(title: "About") },
        "title" => "The Blog",
        "description" => "Notes"
      )
      root = scope_at(scopes_for(site), "/")

      expect(root.title).to eq("The Blog")
      expect(root.description).to eq("Notes")
    end

    it "omits a whitespace-only description" do
      site = build_site({ "about.md" => page_body(title: "About") }, "title" => "The Blog", "description" => "   ")

      expect(scope_at(scopes_for(site), "/").description).to be_nil
    end

    it "leaves the root title empty and omits the description when they are missing" do
      site = build_site("about.md" => page_body(title: "About"))
      root = scope_at(scopes_for(site), "/")

      expect(root.title).to eq("")
      expect(root.description).to be_nil
    end

    def scoped_paths(items)
      entries = items.map do |item|
        Jekyll::LlmsTxt::Entry.new(item: item, summary_computer: ->(_) {}, body_computer: ->(_) {})
      end
      Jekyll::LlmsTxt::Scope.new(path_prefix: "/", title: "", description: nil, entries: entries).entries.map do |entry|
        entry.item.relative_path
      end
    end

    it "sorts an undated page with an epoch-dated document by path" do
      undated = instance_double(Jekyll::Page, relative_path: "a.md")
      dated = instance_double(Jekyll::Document, relative_path: "b.md", date: Time.at(0))

      expect(scoped_paths([undated, dated])).to eq(%w[a.md b.md])
    end

    it "sorts an epoch-dated document ahead of a newer missing-date sentinel" do
      dated = instance_double(Jekyll::Document, relative_path: "a.md", date: Time.at(0))
      undated = instance_double(Jekyll::Page, relative_path: "b.md")

      expect(scoped_paths([undated, dated])).to eq(%w[a.md b.md])
    end

    it "orders entries newest date first, then by relative path" do
      site = build_site(
        "_posts/2020-01-03-beta.md" => page_body(title: "Beta"),
        "_posts/2020-01-03-alpha.md" => page_body(title: "Alpha"),
        "_posts/2020-01-04-later.md" => page_body(title: "Later")
      )
      root = scope_at(scopes_for(site), "/")

      expect(root.entries.map { |entry| entry.item.relative_path }).to eq(
        [
          "_posts/2020-01-04-later.md",
          "_posts/2020-01-03-alpha.md",
          "_posts/2020-01-03-beta.md"
        ]
      )
    end

    it "adds no category scope when categories are off" do
      site = build_site(
        "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: "categories: [record]")
      )

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "adds one category scope per non-empty category" do
      site = build_site(
        {
          "about.md" => page_body(title: "About"),
          "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: "categories: [record]"),
          "_posts/2020-01-03-other.md" => page_body(title: "Other", extra: "categories: [record, news]")
        },
        "llms-txt" => { "categories" => true }
      )
      scopes = scopes_for(site)
      record = scope_at(scopes, "/category/record/")

      expect(record.title).to eq("record")
      expect(record.description).to eq("Category: record")
      expect(record.entries.map { |entry| entry.item.data["title"] }.sort).to eq(%w[Hello Other])
      expect(scope_at(scopes, "/category/news/").entries.map { |entry| entry.item.data["title"] }).to eq(["Other"])
      expect(scopes.map(&:path_prefix)).to eq(["/", "/category/news/", "/category/record/"])
    end

    it "uses the jekyll-archives category permalink and slug mode" do
      site = build_site(
        { "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: 'categories: ["Hello World_X"]') },
        "llms-txt" => { "categories" => true },
        "jekyll-archives" => {
          "permalinks" => { "category" => "/archive/:name/" },
          "slug_mode" => "raw"
        }
      )

      expect(scope_at(scopes_for(site), "/archive/hello-world_x/")).not_to be_nil
    end

    it "uses /category/:name/ when archives does not set a permalink" do
      site = build_site(
        { "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: 'categories: ["Hello World"]') },
        "llms-txt" => { "categories" => true }
      )

      expect(scope_at(scopes_for(site), "/category/hello-world/").title).to eq("Hello World")
    end

    it "skips a category whose documents were all filtered out" do
      site = build_site(
        { "_posts/2020-01-02-hidden.md" => page_body(title: "Hidden", extra: "llms: false\ncategories: [secret]") },
        "llms-txt" => { "categories" => true }
      )

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "adds no collection scope when collections are off" do
      site = build_site(
        { "_garden/note.md" => page_body(title: "Note") },
        "collections" => { "garden" => { "output" => true } },
        "llms-txt" => { "include" => %w[pages posts garden] }
      )

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "adds a scope for each included writeable collection" do
      site = build_site(
        {
          "_garden/note.md" => page_body(title: "Note"),
          "about.md" => page_body(title: "About"),
          "_posts/2020-01-02-hello.md" => page_body(title: "Hello")
        },
        "collections" => { "garden" => { "output" => true } },
        "llms-txt" => { "collections" => true, "include" => %w[pages posts garden] }
      )
      garden = scope_at(scopes_for(site), "/garden/")

      expect(garden.title).to eq("garden")
      expect(garden.description).to eq("Collection: garden")
      expect(garden.entries.map { |entry| entry.item.relative_path }).to eq(["_garden/note.md"])
      expect(scopes_for(site).map(&:path_prefix)).to eq(["/", "/garden/"])
    end

    it "skips a collection that is not writeable" do
      site = build_site(
        { "_garden/note.md" => page_body(title: "Note") },
        "collections" => { "garden" => { "output" => false } },
        "llms-txt" => { "collections" => true, "include" => %w[pages posts garden] }
      )

      expect(scopes_for(site).map(&:path_prefix)).not_to include("/garden/")
    end

    it "keeps a later collection when an earlier name is missing or empty" do
      site = build_site(
        { "_garden/note.md" => page_body(title: "Note") },
        "collections" => {
          "drafts" => { "output" => false },
          "garden" => { "output" => true }
        },
        "llms-txt" => { "collections" => true, "include" => %w[pages posts missing drafts garden] }
      )

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/", "/garden/"])
    end

    it "skips an empty collection" do
      site = build_site(
        { "about.md" => page_body(title: "About") },
        "collections" => { "garden" => { "output" => true } },
        "llms-txt" => { "collections" => true, "include" => %w[pages posts garden] }
      )

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "holds the census Entry in category, collection, and registered scopes" do
      site = build_site(
        { "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: "categories: [record]") },
        "collections" => { "posts" => { "output" => true } },
        "llms-txt" => { "categories" => true, "collections" => true }
      )
      census = entries_for(site)
      Jekyll::LlmsTxt.register_scope_builder do |_site, _configuration, entries|
        [
          Jekyll::LlmsTxt::Scope.new(
            path_prefix: "/tags/record/",
            title: "record",
            description: "Tag: record",
            entries: entries.select { |entry| entry.item.data["title"] == "Hello" }
          )
        ]
      end
      scopes = described_class.call(site, Jekyll::LlmsTxt::Configuration.new(site), census)
      hello = census.find { |entry| entry.item.data["title"] == "Hello" }

      expect(scope_at(scopes, "/category/record/").entries).to include(hello)
      expect(scope_at(scopes, "/tags/record/").entries).to include(hello)
    end

    it "passes the site, configuration, and census array to a registered builder" do
      site = build_site("about.md" => page_body(title: "About"))
      census = entries_for(site)
      configuration = Jekyll::LlmsTxt::Configuration.new(site)
      seen = nil
      Jekyll::LlmsTxt.register_scope_builder do |received_site, received_configuration, received_entries|
        seen = [received_site, received_configuration, received_entries]
        []
      end

      described_class.call(site, configuration, census)

      expect(seen[0]).to equal(site)
      expect(seen[1]).to equal(configuration)
      expect(seen[2]).to equal(census)
    end

    it "reuses the census entry when a builder constructs one for the same document" do
      site = build_site("about.md" => page_body(title: "About"))
      census = entries_for(site)
      constructed = nil
      Jekyll::LlmsTxt.register_scope_builder do |_site, _configuration, entries|
        constructed = Jekyll::LlmsTxt::Entry.new(
          item: entries.first.item,
          summary_computer: ->(_) { "other" },
          body_computer: ->(_) { "other" }
        )
        []
      end

      described_class.call(site, Jekyll::LlmsTxt::Configuration.new(site), census)

      expect(constructed).to equal(census.first)
      expect(constructed.summary).to eq(census.first.summary)
    end

    it "adds no scope when a registered builder returns an empty scope" do
      site = build_site("about.md" => page_body(title: "About"))
      Jekyll::LlmsTxt.register_scope_builder do |_site, _configuration, _entries|
        Jekyll::LlmsTxt::Scope.new(path_prefix: "/empty/", title: "Empty", description: nil, entries: [])
      end

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "adds no scope when a registered builder returns nil" do
      site = build_site("about.md" => page_body(title: "About"))
      Jekyll::LlmsTxt.register_scope_builder { [nil] }

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end

    it "adds no scope when a registered builder returns nothing" do
      site = build_site("about.md" => page_body(title: "About"))
      Jekyll::LlmsTxt.register_scope_builder { |_site, _configuration, _entries| [] }

      expect(scopes_for(site).map(&:path_prefix)).to eq(["/"])
    end
  end
end
