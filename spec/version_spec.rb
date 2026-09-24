# frozen_string_literal: true

require "open3"
require "spec_helper"

# Bundler loads the gemspec, which defines the module before any example
# runs. A fresh process is the only way to see what each require path loads.
RSpec.describe JekyllLlmsTxt do
  def child_require(script)
    lib = File.expand_path("../lib", __dir__)
    # An empty gem home matches CI, where Jekyll exists only inside the bundle.
    # Parent load path carries Jekyll and its dependencies. -I does not
    # evaluate the gemspec, so the constant is still undefined until require.
    load_args = [lib, *$LOAD_PATH].uniq.flat_map { |path| ["-I", path] }
    Bundler.with_unbundled_env do
      ENV["GEM_HOME"] = Dir.mktmpdir
      ENV["GEM_PATH"] = ""
      Open3.capture3(Gem.ruby, *load_args, "-e", script)
    end
  end

  it "is defined after the suite loads and the nested constant is not" do
    expect(defined?(Jekyll::LlmsTxt)).to be_nil
    expect(defined?(JekyllLlmsTxt::VERSION)).to eq("constant")
  end

  describe "require \"jekyll-llms-txt\"" do
    it "defines JekyllLlmsTxt" do
      _stdout, _stderr, status = child_require(
        "abort 'nested' if defined?(Jekyll::LlmsTxt); " \
        "abort 'preloaded' if defined?(JekyllLlmsTxt); " \
        "require 'jekyll-llms-txt'; exit(defined?(JekyllLlmsTxt) == 'constant')"
      )
      expect(status).to be_success
    end
  end

  describe "require \"jekyll/llms_txt\"" do
    it "raises LoadError" do
      _stdout, stderr, status = child_require("require 'jekyll/llms_txt'")
      expect(status).not_to be_success
      expect(stderr).to include("LoadError")
    end
  end
end
