# Active Context

## Current Task: match sibling gem layout
**Phase:** PLAN - COMPLETE

## What Was Done
- Planned the move to `lib/jekyll-llms-txt/` and the module `JekyllLlmsTxt`.
- Specs change first, including the gemspec version constant and every qualified `Jekyll::LlmsTxt` in lib. `require "jekyll/llms_txt"` expects `LoadError`. README and CONTRIBUTING follow the new constant.

## Next Step
- Preflight
