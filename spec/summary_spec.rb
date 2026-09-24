# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmsTxt::Summary do
  describe ".line" do
    def line_for(item)
      described_class.line(item)
    end

    def page_double(data:, name: "my-page.md")
      instance_double(Jekyll::Page, data: data, name: name)
    end

    def document_double(data:, basename:)
      instance_double(Jekyll::Document, data: data, basename: basename)
    end

    it "uses a non-blank stored title as the link text" do
      item = page_double(data: { "title" => "Stored" })

      expect(line_for(item).name).to eq("Stored")
    end

    it "keeps a ] in the title" do
      item = page_double(data: { "title" => "see ] this" })

      expect(line_for(item).name).to eq("see ] this")
    end

    it "uses the page filename, extension included, when the title is missing" do
      item = page_double(data: {})

      expect(line_for(item).name).to eq("my-page.md")
    end

    it "uses the page filename when the title is not a string" do
      item = page_double(data: { "title" => 1 })

      expect(line_for(item).name).to eq("my-page.md")
    end

    it "uses the basename when the page name is blank" do
      item = instance_double(Jekyll::Page, data: {}, name: "   ", basename: "file.md")

      expect(line_for(item).name).to eq("file.md")
    end

    it "uses a string-subclass excerpt as notes" do
      excerpt = Class.new(String).new("subclass excerpt")
      item = page_double(data: { "excerpt" => excerpt })

      expect(line_for(item).notes).to eq("subclass excerpt")
    end

    it "uses the page filename when the title is blank" do
      item = page_double(data: { "title" => "  " })

      expect(line_for(item).name).to eq("my-page.md")
    end

    it "uses the document basename when a document title is blank" do
      item = document_double(data: { "title" => "" }, basename: "hello-world.md")

      expect(line_for(item).name).to eq("hello-world.md")
    end

    it "uses a non-blank description as the notes" do
      item = page_double(data: { "title" => "T", "description" => "A description" })

      expect(line_for(item).notes).to eq("A description")
    end

    it "prefers description over an excerpt" do
      excerpt = instance_double(Jekyll::Excerpt, content: "From the body")
      item = page_double(data: { "description" => "From the front matter", "excerpt" => excerpt })

      expect(line_for(item).notes).to eq("From the front matter")
    end

    it "uses an unrendered excerpt string when description is absent" do
      item = page_double(data: { "excerpt" => "First paragraph" })

      expect(line_for(item).notes).to eq("First paragraph")
    end

    it "omits notes when the excerpt is not text" do
      item = page_double(data: { "excerpt" => 1 })

      expect(line_for(item).notes).to be_nil
    end

    it "uses Excerpt#content when description is absent" do
      excerpt = instance_double(Jekyll::Excerpt, content: "First paragraph")
      item = page_double(data: { "excerpt" => excerpt })

      expect(line_for(item).notes).to eq("First paragraph")
    end

    it "omits notes when description and excerpt are absent" do
      item = page_double(data: {})

      expect(line_for(item).notes).to be_nil
    end

    it "omits notes when description and excerpt are blank" do
      excerpt = instance_double(Jekyll::Excerpt, content: " \n ")
      item = page_double(data: { "description" => "", "excerpt" => excerpt })

      expect(line_for(item).notes).to be_nil
    end

    it "turns newlines in notes into spaces" do
      item = page_double(data: { "description" => "one\rtwo\r\nthree\n\nfour" })

      expect(line_for(item).notes).to eq("one two three  four")
    end

    it "falls through a blank description to the excerpt and still collapses newlines" do
      item = page_double(data: { "description" => "  ", "excerpt" => "line\nbreak" })

      expect(line_for(item).notes).to eq("line break")
    end
  end
end
