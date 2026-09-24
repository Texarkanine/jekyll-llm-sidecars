# frozen_string_literal: true

require "spec_helper"

Jekyll::Hooks.register(:site, :post_read) do |site|
  next unless site.config["llms_bracket_false"]

  subclass = Class.new(Jekyll::Page) do
    def [](property)
      return false if property == "llms"

      super
    end
  end
  site.pages.map! do |page|
    next page unless page.name == "about.md"

    source_dir = File.dirname(page.relative_path)
    source_dir = "" if source_dir == "."
    subclass.new(site, site.source, source_dir, page.name)
  end
end

RSpec.describe Jekyll::LlmsTxt::Census do
  describe ".call" do
    def relative_paths(entries)
      entries.map { |entry| entry.item.relative_path }.sort
    end

    def census_for(site)
      described_class.call(site, Jekyll::LlmsTxt::Configuration.new(site))
    end

    def deprecation_lines
      Jekyll.logger.log_level = :warn
      Jekyll.logger.messages.clear
      yield
      Jekyll.logger.messages.grep(/to_ary/)
    ensure
      Jekyll.logger.log_level = :error
    end

    let(:base_files) do
      {
        "about.md" => page_body(title: "About"),
        "README.md" => page_body(title: "Read me"),
        "CHANGELOG.md" => page_body(title: "Changes"),
        "404.html" => "<h1>Missing</h1>",
        "assets/pic.md" => page_body(title: "Pic"),
        "assets/nested/note.md" => page_body(title: "Nested"),
        "_posts/2020-01-02-hello.md" => page_body(title: "Hello"),
        "_garden/note.md" => page_body(title: "Note")
      }
    end

    it "includes pages and posts and skips other collections by default" do
      site = build_site(base_files, "collections" => { "garden" => { "output" => true } })

      expect(relative_paths(census_for(site))).to eq(["_posts/2020-01-02-hello.md", "about.md"])
    end

    it "skips an include name that is not a collection" do
      site = build_site(
        base_files,
        "llms-txt" => { "include" => %w[pages posts missing] }
      )

      expect(relative_paths(census_for(site))).to eq(["_posts/2020-01-02-hello.md", "about.md"])
    end

    it "includes a collection only when that collection is listed" do
      site = build_site(
        base_files,
        "collections" => { "garden" => { "output" => true } },
        "llms-txt" => { "include" => %w[pages posts garden] }
      )

      expect(relative_paths(census_for(site))).to include("_garden/note.md")
    end

    it "reads an included collection from that collection's documents" do
      site = build_site(
        base_files,
        "collections" => { "garden" => { "output" => true } },
        "llms-txt" => { "include" => %w[garden] }
      )
      entries = nil
      lines = deprecation_lines { entries = census_for(site) }

      expect(relative_paths(entries)).to eq(site.collections["garden"].docs.map(&:relative_path))
      expect(lines).to eq([])
    end

    it "selects nothing and records no to_ary warning when an include name is missing" do
      site = build_site(base_files, "llms-txt" => { "include" => %w[missing] })
      entries = nil
      lines = deprecation_lines { entries = census_for(site) }

      expect(entries).to eq([])
      expect(lines).to eq([])
    end

    it "records no to_ary warning for a default site" do
      site = build_site(base_files)
      lines = deprecation_lines { census_for(site) }

      expect(lines).to eq([])
    end

    it "keeps a page when front matter omits llms and the page reader returns false" do
      site = build_site(
        { "about.md" => page_body(title: "About") },
        "llms_bracket_false" => true
      )

      expect(relative_paths(census_for(site))).to include("about.md")
    end

    it "drops a document whose front matter sets llms false" do
      files = base_files.merge(
        "_posts/2020-01-03-hidden.md" => page_body(title: "Hidden", extra: "llms: false")
      )
      site = build_site(files)

      expect(relative_paths(census_for(site))).not_to include("_posts/2020-01-03-hidden.md")
      expect(relative_paths(census_for(site))).to include("_posts/2020-01-02-hello.md")
    end

    it "drops a document when a glob matches its URL" do
      site = build_site("about.md" => page_body(title: "About"), "keep.md" => page_body(title: "Keep"))
      about = site.pages.find { |page| page.name == "about.md" }
      site.config["llms-txt"] = { "exclude" => [about.url] }

      paths = relative_paths(census_for(site))

      expect(paths).not_to include("about.md")
      expect(paths).to include("keep.md")
    end

    it "drops a document when a glob matches its markdown path" do
      site = build_site("about.md" => page_body(title: "About"), "keep.md" => page_body(title: "Keep"))
      site.config["llms-txt"] = { "exclude" => ["/about.md"] }

      expect(relative_paths(census_for(site))).to eq(["keep.md"])
    end

    it "drops a document when a glob matches its source path" do
      site = build_site("about.md" => page_body(title: "About"), "keep.md" => page_body(title: "Keep"))
      about = site.pages.find { |page| page.name == "about.md" }
      site.config["llms-txt"] = { "exclude" => [about.path] }

      expect(relative_paths(census_for(site))).to eq(["keep.md"])
    end

    it "builds one Entry per selected document and uses Summary.line" do
      site = build_site("about.md" => page_body(title: "About"))
      entries = census_for(site)

      expect(entries.size).to eq(1)
      expect(entries.first.summary).to eq(Jekyll::LlmsTxt::Summary.line(entries.first.item))
      expect(entries.first.body).to eq(entries.first.item.content)
    end

    it "discards an entry registered before the census runs" do
      site = build_site("about.md" => page_body(title: "About"))
      page = site.pages.find { |candidate| candidate.relative_path == "about.md" }
      stale = Jekyll::LlmsTxt::Entry.new(
        item: page,
        summary_computer: ->(_) { "stale" },
        body_computer: ->(_) { "stale" }
      )

      entry = census_for(site).find { |candidate| candidate.item.equal?(page) }

      expect(entry).not_to equal(stale)
      expect(entry.summary).not_to eq("stale")
    end
  end
end
