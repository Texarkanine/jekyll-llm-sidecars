---
task_id: match-sibling-layout
complexity_level: 2
date: 2026-09-24
status: completed
---

# TASK ARCHIVE: match sibling gem layout

## SUMMARY

The plugin now uses the same layout as `jekyll-mermaid-prebuild`, `jekyll-auto-thumbnails`, and `jekyll-highlight-cards`: `lib/jekyll-llms-txt.rb`, files under `lib/jekyll-llms-txt/`, and the flat module `JekyllLlmsTxt`. The gem name is still `jekyll-llms-txt`. The suite passed (133 examples) and QA passed.

## REQUIREMENTS

- One directory, one entry file, one module, matching the three sibling gems.
- The gem name stays `jekyll-llms-txt`.
- Generated output stays the same.
- `../devblog` was out of scope. It still calls `Jekyll::LlmsTxt`.

Preflight kept `require "jekyll/llms_txt"` as an example that expects `LoadError`, instead of deleting that example.

## IMPLEMENTATION

`lib/jekyll/` was removed. Each implementation file reopens `module JekyllLlmsTxt` and closes with one `end`. The gemspec reads `JekyllLlmsTxt::VERSION`. Mutant subjects are `JekyllLlmsTxt*`, and the ignores that existed only inside `module Jekyll` are gone. README's scope-builder sample uses `JekyllLlmsTxt`.

The first two plans could not go green. Lib files opened `module Jekyll` / `module LlmsTxt`, not the string `Jekyll::LlmsTxt`, and `bundle exec rspec` loads the gemspec before any example. The third plan named those forms.

## TESTING

RSpec: 133 examples, 0 failures. RuboCop: 27 files, no offenses. QA passed. An in-process example expects `defined?(Jekyll::LlmsTxt)` to be nil after the normal load. A child process that requires `jekyll/llms_txt` expects `LoadError` in its stderr.

## LESSONS LEARNED

A string replace of `Jekyll::LlmsTxt` does not rewrite a nested `module Jekyll` / `module LlmsTxt` pair. Preflight caught that, and the gemspec version constant, before any file moved.

## PROCESS IMPROVEMENTS

Nothing further. Preflight on the green step was the check that made the third plan match the tree.

## TECHNICAL IMPROVEMENTS

None. The sibling shape is the one that shipped.

## NEXT STEPS

`../devblog` still calls `Jekyll::LlmsTxt`. Updating that site is a separate task.
