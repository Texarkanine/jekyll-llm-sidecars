# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmSidecars::Body do
  describe ".call" do
    it "raises when strict_variables is on and a variable is missing" do
      site = build_site(
        { "marked.md" => "---\ntitle: T\n---\n{{ nosuch }}\n" },
        "liquid" => { "strict_variables" => true }
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect { described_class.call(page) }.to raise_error(Liquid::UndefinedVariable)
    end

    it "raises when strict_filters is on and a filter is missing" do
      site = build_site(
        { "marked.md" => "---\ntitle: T\n---\n{{ 'x' | not_a_filter }}\n" },
        "liquid" => { "strict_filters" => true }
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect { described_class.call(page) }.to raise_error(Liquid::UndefinedFilter)
    end

    it "renders an unknown filter when strict_filters is off" do
      site = build_site("marked.md" => "---\ntitle: T\n---\n{{ 'x' | not_a_filter }}\n")
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("x\n")
    end

    it "renders an unknown filter when the strict_filters key is absent" do
      site = build_site("marked.md" => "---\ntitle: T\n---\n{{ 'x' | not_a_filter }}\n")
      site.config["liquid"].delete("strict_filters")
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("x\n")
    end

    it "renders an unknown variable when strict_variables is false" do
      site = build_site(
        { "marked.md" => "---\ntitle: T\n---\n{{ nosuch }}\n" },
        "liquid" => { "strict_variables" => false }
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("\n")
    end

    it "raises when the liquid config is absent" do
      site = build_site("marked.md" => "---\ntitle: T\n---\n{{ page.title }}\n")
      site.config.delete("liquid")
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect { described_class.call(page) }.to raise_error(NoMethodError)
    end

    it "raises the liquid error when the page path is false" do
      site = build_site(
        { "marked.md" => "---\ntitle: T\n---\n{{ nosuch }}\n" },
        "liquid" => { "strict_variables" => true }
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }
      page.data["path"] = false

      expect { described_class.call(page) }.to raise_error(Liquid::UndefinedVariable)
    end

    it "renders an unknown variable when the strict_variables key is absent" do
      site = build_site("marked.md" => "---\ntitle: T\n---\n{{ nosuch }}\n")
      site.config["liquid"].delete("strict_variables")
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("\n")
    end

    it "does not store the document template in the site liquid cache" do
      site = build_site("docs/marked.md" => "---\ntitle: T\n---\n{{ page.title }}\n")
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("T\n")
      expect(site.liquid_renderer.cache).to be_empty
    end

    it "lets a pre_render rewrite reach HTML while the sidecar keeps the fence" do
      hook = lambda do |site, _payload|
        (site.pages + site.documents).each do |item|
          next unless item.content&.include?("FENCE")

          item.content = item.content.gsub("FENCE", "REWRITTEN")
        end
      end
      Jekyll::Hooks.register(:site, :pre_render, &hook)
      site = process_site(
        {
          "_layouts/default.html" => "<html><body>{{ content }}</body></html>\n",
          "marked.md" => "---\nlayout: default\ntitle: T\n---\n{{ page.title }}\n\nFENCE\n"
        }
      )

      expect(read_dest(site, "/marked.html")).to include("REWRITTEN")
      expect(read_dest(site, "/marked.md")).to eq("T\n\nFENCE\n")
    ensure
      Jekyll::Hooks.instance_variable_get(:@registry)[:site][:pre_render].delete(hook)
    end

    it "returns the source when render_with_liquid is false" do
      site = build_site(
        "marked.md" => "---\ntitle: T\nrender_with_liquid: false\n---\n{{ page.title }}\n"
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to eq("{{ page.title }}\n")
    end

    it "renders include_relative from the page directory" do
      site = build_site(
        "docs/marked.md" => "---\ntitle: Marked\n---\n{% include_relative neighbor.md %}\n",
        "docs/neighbor.md" => "Beside the page.\n"
      )
      page = site.pages.find { |candidate| candidate.name == "marked.md" }

      expect(described_class.call(page)).to include("Beside the page.")
    end
  end
end
