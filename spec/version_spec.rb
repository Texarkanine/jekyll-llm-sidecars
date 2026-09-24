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
    _stdout, _stderr, status = Bundler.with_unbundled_env do
      Open3.capture3(
        Gem.ruby,
        "-I#{lib}",
        "-e",
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
