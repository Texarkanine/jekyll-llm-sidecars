# frozen_string_literal: true

require_relative "lib/jekyll-llms-txt/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-llms-txt"
  spec.version = JekyllLlmsTxt::VERSION
  spec.authors = ["Texarkanine"]
  spec.email = ["texarkanine@protonmail.com"]

  spec.summary = "Jekyll plugin that publishes llms.txt indexes and Markdown sidecars"
  spec.description = "Jekyll plugin that produces llms.txt indexes, optional llms-full.txt " \
                     "corpora, and Markdown source sidecars for included pages."
  spec.homepage = "https://github.com/Texarkanine/jekyll-llms-txt"
  spec.license = "AGPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Texarkanine/jekyll-llms-txt"
  spec.metadata["changelog_uri"] = "https://github.com/Texarkanine/jekyll-llms-txt/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "*.gemspec",
    "lib/**/*.rb",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 4.0", "< 5.0"

  spec.add_development_dependency "mutant", "~> 0.16"
  spec.add_development_dependency "mutant-rspec", "~> 0.16"
  spec.add_development_dependency "rake", "~> 13.3"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.81"
  spec.add_development_dependency "rubocop-rake", "~> 0.7"
  spec.add_development_dependency "rubocop-rspec", "~> 3.8"
  spec.add_development_dependency "simplecov", "~> 1.0"
  spec.add_development_dependency "simplecov-cobertura", "~> 4.0"
end
