# frozen_string_literal: true

unless defined?(Mutant)
  require "simplecov"
  require "simplecov-cobertura"

  # Configure coverage formatter for CI environments (Codecov)
  SimpleCov.start do
    formatter SimpleCov::Formatter::CoberturaFormatter if ENV["CI"]

    skip "spec/"
    skip "vendor/"
  end
end

require "tmpdir"
require "jekyll"
require "jekyll-llm-sidecars"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    Dir.mktmpdir do |dir|
      @temp_dir = dir
      example.run
    end
  end
end
