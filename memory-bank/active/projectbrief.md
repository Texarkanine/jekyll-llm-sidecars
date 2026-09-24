# Project Brief

## User Story

As a maintainer, I want the require-path examples to pass in CI so that the pull request can go green and be pushed.

## Use-Case(s)

### Use-Case 1

`bundle exec rspec` runs `spec/version_spec.rb` on a GitHub Actions runner where Jekyll exists only inside the bundle. Both `require "jekyll-llms-txt"` and `require "jekyll/llms_txt"` define `Jekyll::LlmsTxt`.

## Requirements

1. The unbundled Ruby process can `require "jekyll"`.
2. Bundler setup does not define `Jekyll::LlmsTxt` before the require under test.
3. Push the change.

## Constraints

1. Keep the two require-path examples.
2. Pass the parent process's load path into the child.

## Acceptance Criteria

1. `spec/version_spec.rb` passes when Jekyll is not installed as a default gem.
2. The child process still proves that each require path defines `Jekyll::LlmsTxt`.
3. The change is pushed.
