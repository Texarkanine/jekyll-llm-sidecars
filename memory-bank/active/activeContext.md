# Active Context

## Current Task: match sibling gem layout
**Phase:** PREFLIGHT - COMPLETE (PASS WITH ADVISORY)

## What Was Done
- Planned the move to `lib/jekyll-llms-txt/` and the module `JekyllLlmsTxt`.
- The green step rewrites `module Jekyll` / `module LlmsTxt`, every `Jekyll::LlmsTxt`, and `LlmsTxt.scope_builders` to `JekyllLlmsTxt`, including `version.rb` and the gemspec. `require "jekyll/llms_txt"` expects `LoadError`. An in-process example checks the nested constant is undefined after the normal load.
- Preflight passed with advisory: the three-form rewrite matches lib/ and the sibling trees.

## Next Step
- `/niko-build` (preflight is a valid build gate)
