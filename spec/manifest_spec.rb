# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::LlmsTxt::Manifest do
  def rows_for(files, config = {})
    site = build_site(files, config)
    configuration = Jekyll::LlmsTxt::Configuration.new(site)
    entries = Jekyll::LlmsTxt::Census.call(site, configuration)
    scopes = Jekyll::LlmsTxt::ScopeBuilder.call(site, configuration, entries)
    [described_class.build(configuration, scopes, entries), entries]
  end

  describe ".build" do
    let(:files) do
      {
        "about.md" => page_body(title: "About"),
        "page.html" => "---\ntitle: Hi\n---\n<p>Hi</p>\n",
        "baz.md" => page_body(title: "Baz", extra: "permalink: /foo/bar/baz.html"),
        "slash.md" => page_body(title: "Slash", extra: "permalink: /foo/bar/"),
        "_posts/2020-01-02-hello.md" => page_body(title: "Hello", extra: "categories: [record]")
      }
    end

    it "raises when markdown_ext is missing" do
      site = build_site("about.md" => page_body(title: "About"))
      configuration = Jekyll::LlmsTxt::Configuration.new(site)
      entries = Jekyll::LlmsTxt::Census.call(site, configuration)
      scopes = Jekyll::LlmsTxt::ScopeBuilder.call(site, configuration, entries)
      site.config.delete("markdown_ext")

      expect { described_class.build(configuration, scopes, entries) }.to raise_error(KeyError)
    end

    it "treats a spaced markdown extension as markdown" do
      rows, = rows_for(
        { "note.markdown" => page_body(title: "Note") },
        "markdown_ext" => "md, markdown "
      )

      expect(rows.map(&:path)).to include("/note.md")
    end

    it "writes an index row per scope and no corpus row by default" do
      rows, = rows_for(files, "llms_txt" => { "include_categories" => true })
      paths = rows.select { |row| row.kind == :index }.map(&:path)

      expect(paths).to include("/llms.txt", "/category/record/llms.txt")
      expect(rows.none? { |row| row.kind == :corpus }).to be true
      expect(rows.find { |row| row.path == "/llms.txt" }.scope.path_prefix).to eq("/")
    end

    it "omits index rows when llms_txt is false" do
      rows, = rows_for(
        files,
        "llms_txt" => {
          "create_llms_txt" => false,
          "create_llms_full" => true,
          "include_categories" => true
        }
      )

      expect(rows.none? { |row| row.kind == :index }).to be true
      expect(rows.select { |row| row.kind == :corpus }.map(&:path)).to include(
        "/llms-full.txt",
        "/category/record/llms-full.txt"
      )
      expect(rows.find { |row| row.path == "/llms-full.txt" }.scope.path_prefix).to eq("/")
    end

    it "puts the same Entry on each index and corpus that lists it" do
      rows, entries = rows_for(
        files,
        "llms_txt" => { "create_llms_full" => true, "include_categories" => true }
      )
      hello = entries.find { |entry| entry.item.data["title"] == "Hello" }
      listed = rows.select { |row| %i[index corpus].include?(row.kind) && row.entries.include?(hello) }

      expect(listed.map(&:path)).to include(
        "/llms.txt",
        "/llms-full.txt",
        "/category/record/llms.txt",
        "/category/record/llms-full.txt"
      )
      expect(listed.flat_map(&:entries).grep(hello).size).to eq(listed.size)
    end

    it "keeps HTML entries on indexes and off corpus and sidecar rows" do
      rows, entries = rows_for(files, "llms_txt" => { "create_llms_full" => true })
      html = entries.find { |entry| entry.item.relative_path == "page.html" }
      index = rows.find { |row| row.path == "/llms.txt" }
      corpus = rows.find { |row| row.path == "/llms-full.txt" }

      expect(index.entries).to include(html)
      expect(corpus.entries).not_to include(html)
      expect(rows.select { |row| row.kind == :sidecar }.flat_map(&:entries)).not_to include(html)
    end

    it "adds one sidecar per Markdown entry, swapping the extension or using index.md" do
      rows, entries = rows_for(files)
      baz = entries.find { |entry| entry.item.data["title"] == "Baz" }
      slash = entries.find { |entry| entry.item.data["title"] == "Slash" }
      sidecars = rows.select { |row| row.kind == :sidecar }

      expect(sidecars.find { |row| row.entries == [baz] }.path).to eq("/foo/bar/baz.md")
      expect(sidecars.find { |row| row.entries == [slash] }.path).to eq("/foo/bar/index.md")
    end

    it "adds no sidecar rows when markdown is false" do
      rows, = rows_for(files, "llms_txt" => { "create_markdown" => false, "create_llms_full" => true })

      expect(rows.none? { |row| row.kind == :sidecar }).to be true
      corpus = rows.find { |row| row.path == "/llms-full.txt" }

      expect(corpus.entries.map { |entry| entry.item.relative_path }).to include("about.md")
    end

    it "fails when two scopes claim one path" do
      site = build_site("about.md" => page_body(title: "About"))
      configuration = Jekyll::LlmsTxt::Configuration.new(site)
      scope = Jekyll::LlmsTxt::Scope.new(path_prefix: "/", title: "", description: nil, entries: [])

      expect { described_class.build(configuration, [scope, scope], []) }
        .to raise_error(described_class::Collision, "duplicate output path /llms.txt")
    end
  end

  describe "#add" do
    it "fails when the path is already present" do
      manifest = described_class.new
      scope = Object.new
      row = manifest.add("/llms.txt", :index, [:entry], scope)

      expect(row.path).to eq("/llms.txt")
      expect(row.kind).to eq(:index)
      expect(row.entries).to eq([:entry])
      expect(row.scope).to equal(scope)
      expect { manifest.add("/llms.txt", :corpus, []) }
        .to raise_error(described_class::Collision, "duplicate output path /llms.txt")
    end
  end
end
