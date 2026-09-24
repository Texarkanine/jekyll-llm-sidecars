---
task_id: rename-jekyll-llm-sidecars
date: 2026-09-24
complexity_level: 2
---

# Reflection: Rename Gem to jekyll-llm-sidecars

## Summary

Renamed the gem, require path, lib tree, module, and config block from `jekyll-llms-txt` / `JekyllLlmsTxt` / `llms_txt:` to `jekyll-llm-sidecars` / `JekyllLlmSidecars` / `llm_sidecars:`. QA passed; specs, RuboCop, gem build, and Mutant are all green.

## Requirements vs Outcome

Every requirement in the brief was delivered. Output files and `llms: false` are unchanged, and devblog was left alone as asked. One addition: dropping a redundant `::` in `ScopeBuilder#category_prefix` to kill a Mutant survivor that predates this task.

## Plan Accuracy

The plan's file list and sequence held. Its two named challenges (not over-replacing `llms_txt`, regenerating `Gemfile.lock`) were real and handled as planned. The surprises came from outside the plan: a line-length offense caused by the longer module name, and the pre-existing Mutant survivor.

## Build & QA Observations

The rename went smoothly as scripted, reviewed replacements. The first reference sweep missed `.github/` because `rg` skips dotfiles; widening it with `--hidden` pulled in the multi-hundred-MB `.mutant/` cache. QA found nothing to change.

## Insights

### Technical

- A repo-wide `rg --hidden` here must exclude `.mutant/` (and `.git/`, `coverage/`); otherwise the Mutant cache floods the output.
- The `match-sibling-layout` flattening left `::Jekyll::Utils` as an equivalent spelling that Mutant keeps alive. After any namespace change, run the full Mutant suite, not just the subjects touched.

### Process

- Check the RubyGems name against `GemTypo` normalization (uppercase, strip `-`/`_`, protected if ≥10k downloads or a release within 5 years) before the first build of a new gem, not at publish setup.

### Million-Dollar Question

If `jekyll-llm-sidecars` had been the name from the start, the code would look the same. The one real improvement is upstream of the code: pick the gem name after checking RubyGems, and derive the module and config key from it, as the siblings do (`jekyll-auto-thumbnails` → `auto_thumbnails:`).
