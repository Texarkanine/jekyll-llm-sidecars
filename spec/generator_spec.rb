# frozen_string_literal: true

require "spec_helper"

Jekyll::Hooks.register(:site, :post_read) do |site|
  next unless site.config["page_subclass"]

  subclass = Class.new(Jekyll::Page)
  site.pages.map! do |page|
    next page unless page.name == "about.md"

    source_dir = File.dirname(page.relative_path)
    source_dir = "" if source_dir == "."
    subclass.new(site, site.source, source_dir, page.name)
  end
end

Jekyll::Hooks.register(:site, :post_read) do |site|
  site.config.delete("baseurl") if site.config["delete_baseurl"]
end

RSpec.describe Jekyll::LlmsTxt::Generator do
  let(:layout) { "<!DOCTYPE html><html><head><title>x</title></head><body>{{ content }}</body></html>\n" }
  let(:config) do
    {
      "title" => "The Blog",
      "description" => "A description",
      "url" => "https://example.com",
      "baseurl" => "/blog",
      "permalink" => "/:year/:month/:day/:title:output_ext",
      "collections" => { "garden" => { "output" => true } },
      "llms_txt" => {
        "create_llms_full" => true,
        "include_categories" => true,
        "include_collections" => true,
        "include_paths" => %w[pages posts garden]
      }
    }
  end
  let(:files) do
    {
      "_layouts/default.html" => layout,
      "_posts/2020-01-04-later.md" => <<~MARKDOWN,
        ---
        layout: default
        description: "Line one\\nLine two"
        ---
        Later body.
      MARKDOWN
      "_posts/2020-01-03-alpha.md" => <<~MARKDOWN,
        ---
        layout: default
        categories: [record]
        ---
        Alpha excerpt.
      MARKDOWN
      "_posts/2020-01-03-beta.md" => <<~MARKDOWN,
        ---
        layout: default
        ---
        Beta excerpt.

        More.
      MARKDOWN
      "my-page.md" => <<~MARKDOWN,
        ---
        layout: default
        ---
        Page body.
      MARKDOWN
      "page.html" => <<~HTML,
        ---
        layout: default
        title: Hi
        ---
        <p>Hi</p>
      HTML
      "_garden/note.md" => <<~MARKDOWN,
        ---
        layout: default
        title: Note
        ---
        Garden body.
      MARKDOWN
      "liquid.md" => <<~MARKDOWN,
        ---
        layout: default
        title: Liquid
        ---
        Hello {{ page.title }}
      MARKDOWN
      "frozen.md" => <<~MARKDOWN
        ---
        layout: default
        title: Frozen
        render_with_liquid: false
        ---
        Hello {{ page.title }}
      MARKDOWN
    }
  end

  def root_index
    alpha = "- [Alpha](https://example.com/blog/2020/01/03/alpha.md): Alpha excerpt. "
    <<~TEXT
      # The Blog

      > A description

      ## Posts

      - [Later](https://example.com/blog/2020/01/04/later.md): Line one Line two
      #{alpha}
      - [Beta](https://example.com/blog/2020/01/03/beta.md): Beta excerpt.

      ## Pages

      - [Frozen](https://example.com/blog/frozen.md)
      - [Liquid](https://example.com/blog/liquid.md)
      - [my-page.md](https://example.com/blog/my-page.md)
      - [Hi](https://example.com/blog/page.html)

      ## Garden

      - [Note](https://example.com/blog/garden/note.md): Garden body.#{" "}
    TEXT
  end

  def category_index
    <<~TEXT
      # record

      > Category: record

      ## Posts

      - [Alpha](https://example.com/blog/2020/01/03/alpha.md): Alpha excerpt.#{" "}
    TEXT
  end

  def garden_index
    <<~TEXT
      # garden

      > Collection: garden

      ## Garden

      - [Note](https://example.com/blog/garden/note.md): Garden body.#{" "}
    TEXT
  end

  describe "#generate" do
    it "writes the root, category, and collection indexes" do
      site = process_site(files, config)

      expect(read_dest(site, "/llms.txt")).to eq(root_index)
      expect(read_dest(site, "/category/record/llms.txt")).to eq(category_index)
      expect(read_dest(site, "/garden/llms.txt")).to eq(garden_index)
    end

    it "writes sidecars and joins corpus bodies with two newlines" do
      site = process_site(files, config)

      expect(read_dest(site, "/llms-full.txt")).to eq(
        [
          "Later body.\n",
          "Alpha excerpt.\n",
          "Beta excerpt.\n\nMore.\n",
          "Hello {{ page.title }}\n",
          "Hello Liquid\n",
          "Page body.\n",
          "Garden body.\n"
        ].map { |body| body.sub(/\n+\z/, "") }.join("\n\n")
      )
      expect(read_dest(site, "/liquid.md")).to eq("Hello Liquid\n")
      expect(read_dest(site, "/frozen.md")).to eq("Hello {{ page.title }}\n")
      expect(read_dest(site, "/my-page.md")).to eq("Page body.\n")
      head = read_dest(site, "/my-page.html")[%r{<head>.*?</head>}m]
      expect(head).to include(
        '<link rel="alternate" type="text/markdown" href="https://example.com/blog/my-page.md">'
      )
    end

    it "leaves a blank line between sidecar bodies that already end in a newline" do
      site = process_site(
        {
          "a.md" => "---\ntitle: A\n---\nA\n",
          "b.md" => "---\ntitle: B\n---\nB\n"
        },
        "url" => "https://example.com",
        "llms_txt" => { "create_llms_full" => true }
      )

      expect(read_dest(site, "/llms-full.txt")).to eq("A\n\nB")
    end

    it "joins sidecar bodies that do not end in a newline with two newlines" do
      site = process_site(
        {
          "a.md" => "---\ntitle: A\n---\nA",
          "b.md" => "---\ntitle: B\n---\nB"
        },
        "url" => "https://example.com",
        "llms_txt" => { "create_llms_full" => true }
      )

      expect(read_dest(site, "/llms-full.txt")).to eq("A\n\nB")
    end

    it "starts each document in a category corpus with that document's title" do
      site = process_site(
        {
          "_posts/2020-01-03-alpha.md" => "---\ntitle: Alpha\ncategories: [essay]\n---\nA\n",
          "_posts/2020-01-04-beta.md" => "---\ntitle: Beta\ncategories: [essay]\n---\nB\n\n"
        },
        "url" => "https://example.com",
        "llms_txt" => { "create_llms_full" => true, "include_categories" => true }
      )

      expect(read_dest(site, "/category/essay/llms-full.txt")).to eq("# Beta\n\nB\n\n# Alpha\n\nA")
    end

    it "runs the body computer once per Markdown document" do
      allow(Jekyll::LlmsTxt::Body).to receive(:call).and_call_original

      process_site(files, config)

      markdown_docs = files.keys.count { |path| path.end_with?(".md") && !path.start_with?("_layouts") }

      expect(Jekyll::LlmsTxt::Body).to have_received(:call).exactly(markdown_docs).times
    end

    it "keeps an HTML page on its own URL when that page sorts first" do
      site = process_site(
        {
          "a.html" => "---\ntitle: A\n---\n<p>A</p>\n",
          "z.md" => "---\ntitle: Z\n---\nZ\n"
        },
        "url" => "https://example.com"
      )
      text = read_dest(site, "/llms.txt")

      expect(text).to include("](https://example.com/a.html)")
      expect(text).to include("](https://example.com/z.md)")
      expect(File.exist?(File.join(site.dest, "a.md"))).to be false
      expect(read_dest(site, "/z.md")).to eq("Z\n")
    end

    it "joins a missing baseurl as an empty string" do
      site = process_site(
        { "a.md" => "---\ntitle: A\n---\nA\n" },
        "url" => "https://example.com"
      )

      expect(read_dest(site, "/llms.txt")).to include("](https://example.com/a.md)")
    end

    it "joins a missing url and baseurl as the path" do
      site = process_site("a.md" => "---\ntitle: A\n---\nA\n")

      expect(read_dest(site, "/llms.txt")).to include("](/a.md)")
    end

    it "joins a deleted baseurl key as an empty string" do
      site = process_site(
        { "a.md" => "---\ntitle: A\n---\nA\n" },
        "url" => "https://example.com",
        "delete_baseurl" => true
      )

      expect(read_dest(site, "/llms.txt")).to include("](https://example.com/a.md)")
    end

    it "renders include_relative from the page directory" do
      site = process_site(
        {
          "docs/marked.md" => "---\ntitle: Marked\n---\n{% include_relative neighbor.md %}\n",
          "docs/neighbor.md" => "Beside the page.\n"
        },
        "url" => "https://example.com"
      )

      expect(read_dest(site, "/docs/marked.md")).to include("Beside the page.")
    end

    it "writes llms.txt into the destination" do
      site = process_site(
        { "a.md" => "---\ntitle: A\n---\nA\n" },
        "url" => "https://example.com"
      )

      expect(read_dest(site, "/llms.txt")).to include("#")

      # Cleanup without a later write keeps the recorded destination.
      site.generate
      site.cleanup

      expect(File.exist?(File.join(site.dest, "llms.txt"))).to be true
    end

    it "leaves only Jekyll static files on the site" do
      site = process_site(
        {
          "a.md" => "---\ntitle: A\n---\nA\n",
          "pic.txt" => "pic"
        },
        "url" => "https://example.com"
      )

      expect(site.static_files).to all(be_a(Jekyll::StaticFile))
      expect(site.static_files.map(&:relative_path)).to include("/pic.txt")
    end

    it "orders other collections by label" do
      site = process_site(
        {
          "_zeta/a.md" => "---\ntitle: A\n---\nA\n",
          "_alpha/b.md" => "---\ntitle: B\n---\nB\n"
        },
        "collections" => {
          "zeta" => { "output" => true },
          "alpha" => { "output" => true }
        },
        "llms_txt" => { "include_collections" => true, "include_paths" => %w[alpha zeta] },
        "title" => "T"
      )
      text = read_dest(site, "/llms.txt")

      expect(text.index("## Alpha")).to be < text.index("## Zeta")
    end

    it "lists a page subclass under Pages" do
      site = process_site(
        { "about.md" => page_body(title: "About") },
        "url" => "https://example.com",
        "page_subclass" => true
      )
      text = read_dest(site, "/llms.txt")

      expect(text).to include("## Pages")
      expect(text).to include("](https://example.com/about.md)")
      expect(site.pages.find { |page| page.name == "about.md" }).to be_a(Jekyll::Page)
      expect(site.pages.find { |page| page.name == "about.md" }.class).not_to eq(Jekyll::Page)
    end

    it "renders a highlight tag into the sidecar" do
      site = process_site(
        {
          "marked.md" => <<~MARKDOWN
            ---
            title: Marked
            ---
            {% highlight ruby %}
            puts :hi
            {% endhighlight %}
          MARKDOWN
        },
        "url" => "https://example.com"
      )

      sidecar = read_dest(site, "/marked.md")

      expect(sidecar).not_to include("{% highlight")
      expect(sidecar).to include('class="highlight"', 'class="language-ruby"')
      expect(sidecar.gsub(/<[^>]+>/, "")).to include("puts :hi")
    end

    it "renders an include tag into the sidecar" do
      site = process_site(
        {
          "_includes/snippet.md" => "From the include.",
          "marked.md" => <<~MARKDOWN
            ---
            title: Marked
            ---
            {% include snippet.md %}
          MARKDOWN
        },
        "url" => "https://example.com"
      )

      expect(read_dest(site, "/marked.md")).to include("From the include.")
    end

    it "renders relative_url with the site baseurl" do
      site = process_site(
        {
          "marked.md" => <<~MARKDOWN
            ---
            title: Marked
            ---
            {{ "/x" | relative_url }}
          MARKDOWN
        },
        "url" => "https://example.com",
        "baseurl" => "/blog"
      )

      expect(read_dest(site, "/marked.md")).to include("/blog/x")
    end

    it "leaves Liquid source in the sidecar when render_with_liquid is false" do
      site = process_site(
        {
          "marked.md" => <<~MARKDOWN
            ---
            title: Marked
            render_with_liquid: false
            ---
            {% highlight ruby %}
            puts :hi
            {% endhighlight %}
          MARKDOWN
        },
        "url" => "https://example.com"
      )

      expect(read_dest(site, "/marked.md")).to include("{% highlight ruby %}")
    end

    it "writes an empty H1 and no blockquote when the site title and description are missing" do
      site = process_site(
        { "my-page.md" => "---\n---\nPage body.\n" },
        "url" => "https://example.com"
      )
      text = read_dest(site, "/llms.txt")

      expect(text.lines.first).to eq("#\n")
      expect(text).not_to include(">")
      expect(text).to include("](https://example.com/my-page.md)")
    end
  end
end
