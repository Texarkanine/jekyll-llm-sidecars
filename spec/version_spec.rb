# frozen_string_literal: true

require "open3"
require "spec_helper"

# Bundler loads the gemspec, which defines Jekyll::LlmsTxt before any example
# runs. A fresh process is the only way to see what each require path loads.
RSpec.describe Jekyll::LlmsTxt do
  def defines_llms_txt?(require_path)
    lib = File.expand_path("../lib", __dir__)
    # bundle exec loads the gemspec before examples run, and it re-injects
    # itself into subprocesses. A clean Ruby process is what a site require sees.
    # An empty gem home matches CI, where Jekyll exists only inside the bundle.
    # Parent load path carries Jekyll and its dependencies. -I does not
    # evaluate the gemspec, so the constant is still undefined until require.
    load_args = [lib, *$LOAD_PATH].uniq.flat_map { |path| ["-I", path] }
    _stdout, _stderr, status = Bundler.with_unbundled_env do
      ENV["GEM_HOME"] = Dir.mktmpdir
      ENV["GEM_PATH"] = ""
      Open3.capture3(
        Gem.ruby,
        *load_args,
        "-e",
        "abort 'preloaded' if defined?(Jekyll::LlmsTxt); " \
        "require #{require_path.inspect}; exit(defined?(Jekyll::LlmsTxt) == 'constant')"
      )
    end
    status.success?
  end

  describe "require \"jekyll-llms-txt\"" do
    it "defines Jekyll::LlmsTxt" do
      expect(defines_llms_txt?("jekyll-llms-txt")).to be true
    end
  end

  describe "require \"jekyll/llms_txt\"" do
    it "defines Jekyll::LlmsTxt" do
      expect(defines_llms_txt?("jekyll/llms_txt")).to be true
    end
  end
end
