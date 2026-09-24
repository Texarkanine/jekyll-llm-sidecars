# Tech Context

Jekyll 4 plugin. The `jekyll` dependency is `>= 4.0`, `< 5.0` in `jekyll-llms-txt.gemspec`. Ruby is pinned in `.ruby-version`.

## Environment Setup

Install gems with Bundler, then run Ruby tools through `bundle exec`.

## Build Tools

Bundler, configured by `Gemfile` and `jekyll-llms-txt.gemspec`.

## Testing Process

- RSpec: `bundle exec rspec`
- RuboCop: `bundle exec rubocop`, configured in `.rubocop.yml`
- Mutant 0.17: `bundle exec mutant run`, configured in `config/mutant.yml`
