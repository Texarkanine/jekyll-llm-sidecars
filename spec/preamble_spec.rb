# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmSidecars::Preamble do
  describe ".call" do
    def call_for(files, config = {}, title: nil, name: nil)
      site = build_site(files, config)
      docs = site.pages + site.documents
      item = docs.find do |doc|
        title ? doc.data["title"] == title : doc.relative_path.end_with?(name)
      end
      [described_class.call(item), item]
    end

    it "starts a titled page with an H1 and no date line" do
      text, = call_for({ "about.md" => "---\ntitle: About\n---\nBody\n" }, title: "About")

      expect(text).to eq("# About\n\n")
    end

    it "uses the page filename when the title is missing" do
      text, = call_for({ "my-page.md" => "---\n---\nPage body.\n" }, name: "my-page.md")

      expect(text).to eq("# my-page.md\n\n")
    end

    it "omits a date and an author on a page" do
      text, = call_for(
        { "dated.md" => "---\ntitle: Dated\ndate: 2020-05-06\nauthor: niko\n---\nBody\n" },
        title: "Dated"
      )

      expect(text).to eq("# Dated\n\n")
    end

    it "uses the filename date for a post with no author" do
      text, = call_for(
        { "_posts/2020-01-04-later.md" => "---\n---\nLater body.\n" },
        name: "2020-01-04-later.md"
      )

      expect(text).to eq("# Later\n\n2020-01-04\n\n")
    end

    it "joins a post date and a string author" do
      text, = call_for(
        { "_posts/2020-01-04-named.md" => "---\ntitle: Named\nauthor: niko\n---\nBody\n" },
        title: "Named"
      )

      expect(text).to eq("# Named\n\n2020-01-04 - niko\n\n")
    end

    it "matches Liquid's date for an offset evening in Chicago" do
      saved = ENV.fetch("TZ", :unset)
      text, item = call_for(
        {
          "_posts/2020-01-02-edge.md" => "---\ntitle: Edge\ndate: 2020-01-02 23:00:00 -0500\n---\nBody\n"
        },
        { "timezone" => "America/Chicago" },
        title: "Edge"
      )
      liquid = Liquid::Template.parse("{{ page.date | date: '%Y-%m-%d' }}").render!(
        "page" => item.to_liquid
      )

      expect(liquid).to eq("2020-01-02")
      expect(text).to eq("# Edge\n\n#{liquid}\n\n")
    ensure
      if saved == :unset
        ENV.delete("TZ")
      else
        ENV["TZ"] = saved
      end
    end

    it "omits a blank author" do
      text, = call_for(
        { "_posts/2020-01-04-blank.md" => "---\ntitle: Blank\nauthor: \" \"\n---\nBody\n" },
        title: "Blank"
      )

      expect(text).to eq("# Blank\n\n2020-01-04\n\n")
    end

    it "omits an author that is not a string" do
      text, = call_for(
        { "_posts/2020-01-04-list.md" => "---\ntitle: List\nauthor: [ada]\n---\nBody\n" },
        title: "List"
      )

      expect(text).to eq("# List\n\n2020-01-04\n\n")
    end

    it "omits subtitle, categories, tags, and description" do
      text, = call_for(
        {
          "_posts/2020-06-07-kept.md" => <<~MARKDOWN
            ---
            title: Kept
            subtitle: Hidden subtitle
            categories: [record]
            tags: [cad]
            description: Hidden description
            author: niko
            ---
            Body
          MARKDOWN
        },
        title: "Kept"
      )

      expect(text).to eq("# Kept\n\n2020-06-07 - niko\n\n")
      expect(text).not_to include("Hidden subtitle", "record", "cad", "Hidden description")
    end

    it "does not read the site author" do
      text, = call_for(
        { "_posts/2020-01-04-later.md" => "---\ntitle: Later\n---\nLater body.\n" },
        { "author" => "site-author" },
        title: "Later"
      )

      expect(text).to eq("# Later\n\n2020-01-04\n\n")
      expect(text).not_to include("site-author")
    end

    it "leaves the body H1 for the sidecar file to keep" do
      text, = call_for(
        { "_posts/2020-01-04-echo.md" => "---\ntitle: Echo\n---\n# Echo\n\nAfter.\n" },
        title: "Echo"
      )

      expect(text).to eq("# Echo\n\n2020-01-04\n\n")
      expect(text).not_to include("After.")
    end

    it "omits the meta line on a collection document" do
      text, = call_for(
        { "_garden/note.md" => "---\ntitle: Note\ndate: 2020-05-06\nauthor: niko\n---\nGarden body.\n" },
        { "collections" => { "garden" => { "output" => true } } },
        title: "Note"
      )

      expect(text).to eq("# Note\n\n")
    end
  end
end
