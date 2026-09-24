# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmSidecars::Configuration do
  subject(:configuration) { described_class.new(site) }

  let(:site_config) { {} }
  let(:site) { instance_double(Jekyll::Site, config: site_config) }

  describe "#markdown" do
    it "defaults to true when llm_sidecars is absent" do
      expect(configuration.markdown).to be true
    end

    it "stays true when only the old llms_txt key sets it false" do
      site_config["llms_txt"] = { "create_markdown" => false }

      expect(configuration.markdown).to be true
    end

    it "is false when the block sets it false" do
      site_config["llm_sidecars"] = { "create_markdown" => false }

      expect(configuration.markdown).to be false
    end

    it "reads flags from a hash subclass" do
      block = Class.new(Hash).new
      block["create_markdown"] = false
      site_config["llm_sidecars"] = block

      expect(configuration.markdown).to be false
    end

    it "stays true when llm_sidecars is not a hash" do
      site_config["llm_sidecars"] = "nope"

      expect(configuration.markdown).to be true
    end
  end

  describe "#llms_txt" do
    it "defaults to true when llm_sidecars is absent" do
      expect(configuration.llms_txt).to be true
    end

    it "is false when the block sets it false" do
      site_config["llm_sidecars"] = { "create_llms_txt" => false }

      expect(configuration.llms_txt).to be false
    end
  end

  describe "#llms_full" do
    it "defaults to false when llm_sidecars is absent" do
      expect(configuration.llms_full).to be false
    end

    it "is true when the block sets it true" do
      site_config["llm_sidecars"] = { "create_llms_full" => true }

      expect(configuration.llms_full).to be true
    end
  end

  describe "#categories" do
    it "defaults to false when llm_sidecars is absent" do
      expect(configuration.categories).to be false
    end

    it "is true when the block sets it true" do
      site_config["llm_sidecars"] = { "include_categories" => true }

      expect(configuration.categories).to be true
    end
  end

  describe "#collections" do
    it "defaults to false when llm_sidecars is absent" do
      expect(configuration.collections).to be false
    end

    it "is true when the block sets it true" do
      site_config["llm_sidecars"] = { "include_collections" => true }

      expect(configuration.collections).to be true
    end
  end

  describe "#include" do
    it "defaults to pages and posts when llm_sidecars is absent" do
      expect(configuration.include).to eq(%w[pages posts])
    end

    it "replaces the default when the block sets a list" do
      site_config["llm_sidecars"] = { "include_paths" => ["garden"] }

      expect(configuration.include).to eq(["garden"])
    end

    it "wraps one include name in an array" do
      site_config["llm_sidecars"] = { "include_paths" => "garden" }

      expect(configuration.include).to eq(["garden"])
    end
  end

  describe "#exclude" do
    let(:default_exclude) { ["/README.md", "/CHANGELOG.md", "/404.html", "/assets/**/*"] }

    it "defaults to the README sample when llm_sidecars is absent" do
      expect(configuration.exclude).to eq(default_exclude)
    end

    it "keeps that default when the block sets other keys only" do
      site_config["llm_sidecars"] = { "create_markdown" => false }

      expect(configuration.exclude).to eq(default_exclude)
    end

    it "replaces the default when the block sets a list" do
      site_config["llm_sidecars"] = { "exclude_paths" => ["/secret/**"] }

      expect(configuration.exclude).to eq(["/secret/**"])
    end

    it "replaces the default with an empty list when the block sets one" do
      site_config["llm_sidecars"] = { "exclude_paths" => [] }

      expect(configuration.exclude).to eq([])
    end
  end
end
