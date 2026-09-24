# Task: Rename Gem to jekyll-llm-sidecars

* Task ID: rename-jekyll-llm-sidecars
* Complexity: Level 2
* Type: simple enhancement (rename, clean break)

Rename the gem `jekyll-llms-txt` to `jekyll-llm-sidecars`: gem name, gemspec, require path `jekyll-llm-sidecars`, `lib/jekyll-llm-sidecars/`, module `JekyllLlmSidecars`, and the `_config.yml` block key `llm_sidecars:`. Inner config keys (`create_llms_txt`, etc.), output files, and `llms: false` do not change. `Configuration#llms_txt` (the `create_llms_txt` flag reader) keeps its name because it names the llms.txt artifact, not the gem.

## Test Plan (TDD)

### Behaviors to Verify

- Require path: fresh process runs `require "jekyll-llm-sidecars"` → `JekyllLlmSidecars` is defined; no nested `Jekyll::LlmSidecars` exists before or after.
- Nested path: fresh process runs `require "jekyll/llm_sidecars"` → LoadError (keeps the existing no-nested-namespace contract under the new name).
- Config key: `llm_sidecars:` block with `create_markdown: false` → `Configuration#markdown` is false (and likewise for every other key already covered).
- Old key ignored (edge, clean break): only an `llms_txt:` block with `create_markdown: false` → `Configuration#markdown` stays true (defaults apply).
- Non-hash block (edge): `llm_sidecars: "nope"` → defaults apply.
- No regression: every existing generator, census, scope, manifest, and hooks example passes when its site config uses `llm_sidecars`.

### Test Infrastructure

- Framework: RSpec (`.rspec` requires `spec_helper`), Mutant with `mutant-rspec` (`config/mutant.yml`)
- Test location: `spec/`
- Conventions: one `<unit>_spec.rb` per lib file; `RSpec.describe JekyllLlmSidecars::<Class>`; examples nested under `#method`/`.method`; `version_spec.rb` uses a child process for require-path checks.
- New test files: none

## Implementation Plan

### 1. Rename gem, module, and config key — executable

- Files: `spec/*.rb`, `spec/support/mutant_setup.rb`, `spec/spec_helper.rb`, `lib/jekyll-llms-txt.rb` → `lib/jekyll-llm-sidecars.rb`, `lib/jekyll-llms-txt/` → `lib/jekyll-llm-sidecars/`, `jekyll-llms-txt.gemspec` → `jekyll-llm-sidecars.gemspec`, `Gemfile.lock`, `config/mutant.yml`, `.rubocop.yml`, `.github/workflows/release-please.yaml`, `.github/workflows/update-gemfile-lock.yaml`, `release-please-config.json`

1. Stub tests: no new files or cases; the existing cases are retargeted in step 3.
2. Stub interface: none new; the interface is renamed, not added.
3. Write tests and run red:
    - All specs: `JekyllLlmsTxt` → `JekyllLlmSidecars`; quoted config key `"llms_txt"` → `"llm_sidecars"`; example descriptions "when llms_txt is absent" / "is not a hash" → `llm_sidecars`. Leave `configuration.llms_txt`, `describe "#llms_txt"`, `create_llms_txt`, and "omits index rows when llms_txt is false" alone.
    - `configuration_spec.rb` "stays true when a different config key sets it false": use the old `llms_txt` key.
    - `version_spec.rb`: describe `JekyllLlmSidecars`; nested constant `Jekyll::LlmSidecars`; `require 'jekyll-llm-sidecars'`; `require 'jekyll/llm_sidecars'` raises LoadError.
    - `spec_helper.rb`, `spec/support/mutant_setup.rb`: `require "jekyll-llm-sidecars"`.
    - Run `bundle exec rspec`; expect load failure / red.
4. Write code and run green:
    - `git mv` the lib entry file, lib directory, and gemspec to the new names; update `require_relative` paths.
    - `module JekyllLlmsTxt` → `module JekyllLlmSidecars` in every lib file.
    - `Configuration#initialize` reads `site.config["llm_sidecars"]`; update its doc comment.
    - Site ivar `@llms_txt` → `@llm_sidecars` in `generator.rb` and `hooks.rb`.
    - gemspec: `spec.name`, version constant, homepage/source/changelog URLs → `Texarkanine/jekyll-llm-sidecars`.
    - `config/mutant.yml` subject `JekyllLlmSidecars*`; `.rubocop.yml` header and `lib/jekyll-llm-sidecars.rb` path; workflows `GEM_NAME` and version-file path; `release-please-config.json` version-file.
    - `bundle install` to regenerate `Gemfile.lock`.
    - Run `bundle exec rspec`, `bundle exec rubocop`, `gem build jekyll-llm-sidecars.gemspec` (then delete the built `.gem`), and `bundle exec mutant run`.

### 2. Documentation and memory bank — prose/policy

- Files: `README.md`, `CONTRIBUTING.md`, `memory-bank/systemPatterns.md`, `memory-bank/techContext.md`
- No tests: prose/policy artifact

1. README: title, codecov badge URLs, Gemfile snippet, plugins-list sentence, `llm_sidecars:` config block, and `JekyllLlmSidecars` in the custom-scope example and prose. Keep the RubyGems badge out until the first release.
2. CONTRIBUTING: title and clone URL/directory.
3. `systemPatterns.md` and `techContext.md`: module and gemspec names. Archive files stay as history.
4. Final `rg` for `jekyll-llms-txt|JekyllLlmsTxt|"llms_txt"|llms_txt:` outside `memory-bank/archive/`, `.summem/`, `coverage/`, `.mutant/` → no hits except intentional ones (old-key spec).

## Technology Validation

No new technology - validation not required.

## Dependencies

- Local Bundler can regenerate `Gemfile.lock` (gems already installed).
- GitHub repository rename is done by the operator; URLs are written for the new name ahead of it.

## Challenges & Mitigations

- Blind replace of `llms_txt` would also rename `create_llms_txt` and `Configuration#llms_txt`: replace only the quoted key `"llms_txt"` and the named example descriptions, then review the diff.
- `Gemfile.lock` still names `jekyll-llms-txt` after the gemspec moves: run `bundle install` so the path gem entry updates; CI's frozen lockfile would fail otherwise.
- Stale `coverage/` and `.mutant/` caches reference old paths: both are ignored build output; Mutant rebuilds its cache.
- Mutant run takes minutes: run it once at the end, in the background.

## Pre-Mortem

- Build passes locally but a workflow still points at the old file path (e.g. `update-gemfile-lock.yaml` path filter), so the lockfile bot or release job silently misbehaves: covered by the explicit workflow edits and the final `rg` sweep including `.github`.
- The sweep misses hidden files because `rg` skips dotfiles by default: run the final sweep with `--hidden` and explicit globs that exclude `.mutant/` and `.git/`.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [x] Preflight
- [x] Build
    - [x] Step 1: rename gem, module, and config key (specs red, then green)
    - [x] Step 2: documentation and memory bank
- [x] QA

## QA Results

PASS. The implementation matches the plan. No KISS, DRY, YAGNI, completeness, regression, integrity, or documentation violations.

Verification: 133 examples pass, 100% line coverage, RuboCop clean, `gem build` succeeds with only `lib/jekyll-llm-sidecars*` paths in the file list. A hidden-file sweep for every old-name form (`jekyll-llms-txt`, `JekyllLlmsTxt`, `Jekyll::LlmsTxt`, `jekyll/llms_txt`, `@llms_txt`, `"llms_txt"`, `llms_txt:`, `llms-txt`) outside archives and caches finds only the intended `create_llms_txt` key and the old-key spec.

Advisories (non-blocking):

- `scope_builder.rb` `::Jekyll::Utils` → `Jekyll::Utils` is outside the plan. It is behavior-neutral (no `JekyllLlmSidecars::Jekyll` exists), it kills a pre-existing equivalent Mutant survivor, and it is recorded as a deviation. `::Jekyll` no longer appears anywhere in lib, so lib is consistent.
- A site that still has an `llms_txt:` block gets defaults silently. This is the chosen clean break; the preflight's optional warning was declined and recorded. devblog is the one known consumer: its Gemfile entry, `_config.yml` block key, and `_plugins` scope-builder module reference need the rename (operator, out of scope).
- `gem build` warns that `homepage_uri` and `source_code_uri` share a URL. That predates this task and does not block.
