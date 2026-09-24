# Project Brief

## User Story

As a maintainer of this gem family, I want jekyll-llms-txt laid out like the other three gems so that the family shares one pattern.

## Use-Case(s)

### Use-Case 1

A reader of `lib/` sees one entry file and one directory, both named `jekyll-llms-txt`, and one module, `JekyllLlmsTxt`.

## Requirements

1. Match `jekyll-mermaid-prebuild`, `jekyll-auto-thumbnails`, and `jekyll-highlight-cards`: one directory `lib/jekyll-llms-txt/`, one entry `lib/jekyll-llms-txt.rb`, one flat module `JekyllLlmsTxt`.
2. Remove `lib/jekyll/llms_txt.rb` and the `require "jekyll/llms_txt"` example.
3. Keep the gem name `jekyll-llms-txt`.

## Constraints

1. The other three gems are the pattern. This gem is not an official Jekyll plugin, and it does not extend a gem named `jekyll-llms`.
2. Behavior of the plugin stays the same.

## Acceptance Criteria

1. No `lib/jekyll/` tree remains.
2. Ruby code refers to `JekyllLlmsTxt`, not `Jekyll::LlmsTxt`.
3. The suite passes.
