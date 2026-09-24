# Project Brief: Rename Gem to jekyll-llm-sidecars

## User Story

As the gem author, I need to publish this plugin on RubyGems. RubyGems rejects `jekyll-llms-txt` because its typo check strips `-`/`_` and finds `jekyll-llmstxt`, a protected gem until 2029-12. So the gem must take a new name: `jekyll-llm-sidecars`.

## Requirements

- Rename the gem from `jekyll-llms-txt` to `jekyll-llm-sidecars` everywhere in this repository. Clean break: nothing is published, so there is no compatibility to keep.
- Gem name, gemspec file, `lib/jekyll-llms-txt.rb`, and `lib/jekyll-llms-txt/` move to `jekyll-llm-sidecars`.
- Ruby module `JekyllLlmsTxt` becomes `JekyllLlmSidecars`, including the public `register_scope_builder` hook.
- The `_config.yml` block key changes from `llms_txt:` to `llm_sidecars:`. Its inner keys stay the same.
- Workflow `GEM_NAME`, `release-please-config.json`, `config/mutant.yml`, specs, CONTRIBUTING, README, and the codecov badge use the new name. GitHub URLs point to `Texarkanine/jekyll-llm-sidecars` (the operator renames the GitHub repository).
- Persistent memory-bank files that name the gem are updated. Archive files stay as history.
- The pending README rewrite (sibling-aligned layout, codecov badge, no RubyGems badge yet) is part of this work.

## Unchanged

- Output files: `llms.txt`, `llms-full.txt`, and `*.md` sidecars.
- The `llms: false` front matter opt-out.

## Out of Scope

- `../devblog`. It is a different repository; the operator updates it during QA.
- Renaming the GitHub repository (operator does it).
