# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmSidecars::Hooks do
  let(:layout) { "<!DOCTYPE html><html><head><title>x</title></head><body>{{ content }}</body></html>\n" }

  def head(html)
    html[%r{<head>.*?</head>}m]
  end

  describe "site post_render" do
    it "points Markdown pages at their sidecar and skips HTML pages" do
      site = process_site(
        {
          "_layouts/default.html" => layout,
          "my-page.md" => "---\nlayout: default\n---\nPage body.\n",
          "a.html" => "---\nlayout: default\ntitle: Hi\n---\n<p>Hi</p>\n"
        },
        "url" => "https://example.com",
        "baseurl" => "/blog"
      )

      expect(head(read_dest(site, "/my-page.html"))).to include(
        '<link rel="alternate" type="text/markdown" href="https://example.com/blog/my-page.md">'
      )
      expect(read_dest(site, "/a.html")).not_to include("text/markdown")
    end

    it "links a later page when an earlier page output is nil" do
      site = process_site(
        {
          "_layouts/default.html" => layout,
          "a.md" => "---\nlayout: default\n---\nA\n",
          "z.md" => "---\nlayout: default\n---\nZ\n"
        },
        "url" => "https://example.com"
      )
      documents = site.pages + site.documents
      documents[0].output = nil
      documents[1].output = layout.dup

      described_class.inject(site)

      expect(documents[1].output).to include('rel="alternate"')
    end

    it "keeps llms.txt and deletes a file this plugin did not write" do
      # Cleanup runs without a later write.
      site = process_site(
        {
          "a.md" => "---\ntitle: A\n---\nA\n",
          "_posts/2020-01-02-hello.md" => "---\ntitle: Hello\ncategories: [record]\n---\nHi\n"
        },
        "url" => "https://example.com",
        "llm_sidecars" => { "include_categories" => true }
      )
      leftover = File.join(site.dest, "old.txt")
      File.write(leftover, "old")

      expect(read_dest(site, "/category/record/llms.txt")).to include("Hello")

      site.generate
      site.cleanup

      expect(File.exist?(File.join(site.dest, "llms.txt"))).to be true
      expect(File.exist?(leftover)).to be false
    end

    it "deletes an obsolete file when no destinations were recorded" do
      site = process_site(
        { "a.md" => "---\ntitle: A\n---\nA\n" },
        "url" => "https://example.com"
      )
      JekyllLlmSidecars.current_destinations = nil
      leftover = File.join(site.dest, "old.txt")
      File.write(leftover, "old")

      site.cleanup

      expect(File.exist?(leftover)).to be false
    end

    it "writes nothing when no build was stored" do
      site = build_site("about.md" => page_body(title: "About"))

      expect { described_class.write(site) }.not_to raise_error
      expect(File.exist?(File.join(site.dest, "llms.txt"))).to be false
    end

    it "leaves the site alone when no build was stored" do
      site = build_site("about.md" => page_body(title: "About"))
      page = site.pages.find { |candidate| candidate.name == "about.md" }
      html = "<html><head></head></html>"
      page.output = html

      described_class.inject(site)

      expect(page.output).to eq(html)
    end

    it "still links a later page when an earlier page has no head" do
      site = process_site(
        {
          "_layouts/default.html" => layout,
          "a.md" => "---\n---\nNo head.\n",
          "z.md" => "---\nlayout: default\n---\nHas head.\n"
        },
        "url" => "https://example.com"
      )

      expect(head(read_dest(site, "/z.html"))).to include("text/markdown")
    end

    it "links a post and a collection document once each" do
      site = process_site(
        {
          "_layouts/default.html" => layout,
          "_posts/2020-01-04-later.md" => "---\nlayout: default\n---\nLater.\n",
          "_garden/note.md" => "---\nlayout: default\n---\nNote.\n"
        },
        "url" => "https://example.com",
        "baseurl" => "/blog",
        "permalink" => "/:year/:month/:day/:title:output_ext",
        "collections" => { "garden" => { "output" => true } },
        "llm_sidecars" => { "include_paths" => %w[pages posts garden] }
      )

      expect(head(read_dest(site, "/2020/01/04/later.html")).scan("text/markdown").size).to eq(1)
      expect(head(read_dest(site, "/garden/note.html")).scan("text/markdown").size).to eq(1)
    end

    it "warns and leaves a page that already occupies the sidecar path" do
      allow(Jekyll.logger).to receive(:warn).and_call_original
      expect(Jekyll.logger).to receive(:warn).with(
        "Jekyll LLM Sidecars:",
        a_string_including("/about.md")
      ).and_call_original

      site = process_site(
        {
          "_layouts/default.html" => layout,
          "about.md" => "---\nlayout: default\npermalink: /about.md\n---\nSource body.\n"
        },
        "url" => "https://example.com"
      )

      written = read_dest(site, "/about.md")

      expect(written).to include("<html>")
      expect(written).to include("Source body.")
    end

    it "rewrites a sidecar on a later build when the page does not occupy that path" do
      site = process_site(
        { "about.md" => page_body(title: "About", body: "First body.") },
        "url" => "https://example.com"
      )

      File.write(File.join(site.source, "about.md"), page_body(title: "About", body: "Second body."))
      site.process

      written = read_dest(site, "/about.md")

      expect(written).to include("Second body.")
      expect(written).not_to include("First body.")
    end

    it "writes a sidecar in binary mode" do
      site = build_site(
        { "about.md" => page_body(title: "About") },
        "url" => "https://example.com"
      )
      dest = File.join(site.dest, "about.md")

      allow(File).to receive(:write).and_call_original
      expect(File).to receive(:write).with(dest, anything, mode: "wb").and_call_original

      site.process

      expect(File.exist?(dest)).to be true
    end
  end
end
