# Task: match sibling gem layout

* Task ID: match-sibling-layout
* Complexity: Level 2
* Type: simple enhancement

Move the plugin onto the family layout. One directory, `lib/jekyll-llms-txt/`. One entry, `lib/jekyll-llms-txt.rb`. One module, `JekyllLlmsTxt`. The gem name stays `jekyll-llms-txt`. Generated files stay as they are.

## Test Plan (TDD)

### Behaviors to Verify

- After the suite loads the gemspec and `require "jekyll-llms-txt"` → `defined?(Jekyll::LlmsTxt)` is nil and `JekyllLlmsTxt::VERSION` is defined
- `require "jekyll-llms-txt"` in a child process with an empty gem home and the parent load path → `JekyllLlmsTxt` is defined, `Jekyll::LlmsTxt` is not, and it was not defined before the require
- `require "jekyll/llms_txt"` in that same child → `LoadError`
- Existing generator, census, manifest, scope, body, hooks, entry, summary, and configuration examples, rewritten to `JekyllLlmsTxt` → the same outcomes as now

### Test Infrastructure

- Framework: RSpec, `bundle exec rspec`
- Test location: `spec/`
- Conventions: one spec file per unit, `RSpec.describe` on the class, examples state the observable result
- New test files: none

## Implementation Plan

### 1. Constant and require path — executable

- Files: `spec/version_spec.rb`, `spec/*_spec.rb`, `lib/jekyll-llms-txt.rb`, `lib/jekyll-llms-txt/**/*.rb`, `lib/jekyll/llms_txt.rb`, `lib/jekyll/llms_txt/**/*.rb`, `jekyll-llms-txt.gemspec`, `config/mutant.yml`

1. Stub tests: in `spec/version_spec.rb`, leave `defines_llms_txt?` in place and empty the `"jekyll/llms_txt"` example body. Point the remaining example's description at `JekyllLlmsTxt`.
2. Stub interface: none. The classes already exist.
3. Write tests and run red: replace `Jekyll::LlmsTxt` with `JekyllLlmsTxt` in every `spec/*_spec.rb`. In `spec/version_spec.rb`, add an in-process example that, after the suite's normal load, expects `defined?(Jekyll::LlmsTxt)` to be nil and `JekyllLlmsTxt::VERSION` to be defined. The child `"jekyll-llms-txt"` example aborts if `defined?(Jekyll::LlmsTxt)`. The `"jekyll/llms_txt"` example runs the require in the child and expects that process to raise `LoadError` (assert the exception class, not a false return from `defines_llms_txt?`). Run `bundle exec rspec`. Red is a NameError or a failed nil check, because the library still defines the nested constant.
4. Write code and run green: move `lib/jekyll/llms_txt/*.rb` to `lib/jekyll-llms-txt/`. Delete `lib/jekyll/llms_txt.rb` and the empty `lib/jekyll/` directory. Rewrite the constant, not the string `Jekyll::LlmsTxt` alone. Every lib file, including `lib/jekyll-llms-txt/version.rb`, opens `module Jekyll` / `module LlmsTxt`. Replace that pair with `module JekyllLlmsTxt`. Also replace every qualified `Jekyll::LlmsTxt` and the inner `LlmsTxt.scope_builders` in `scope_builder.rb` `custom_scopes` with `JekyllLlmsTxt`. Set `jekyll-llms-txt.gemspec` `spec.version` to `JekyllLlmsTxt::VERSION`. Point `lib/jekyll-llms-txt.rb` at `require_relative "jekyll-llms-txt/..."`. In `config/mutant.yml`, set the subject to `JekyllLlmsTxt*` and delete the four `module Jekyll` ignore patterns. Run `bundle exec rspec`.

### 2. Documented constant — prose/policy

- Files: `README.md`, `CONTRIBUTING.md`
- No tests: prose/policy artifact

1. In `README.md`, change the scope-builder sample from `Jekyll::LlmsTxt` to `JekyllLlmsTxt`.
2. In `CONTRIBUTING.md`, drop the sentence that lists `Utils`, `Page`, `Renderer`, and `LlmsTxt` as ignores inside `module Jekyll`.

## Technology Validation

No new technology - validation not required

## Dependencies

- None

## Challenges & Mitigations

- A leftover `Jekyll::LlmsTxt` in spec or lib fails the suite or leaves two modules: grep the repo for that string after the move, excluding `memory-bank/archive/`.
- Mutant ignores exist only because the code sits inside `module Jekyll`. Leaving them in makes `CONTRIBUTING.md` false. Removing them is step 1.4. If a mutation of `Jekyll::Page` survives after the move, the ignore goes back with a new structure-check note, not the old one.
- `../devblog` calls `Jekyll::LlmsTxt`. This task does not edit that repo. The site plugin will need a follow-up there.

## Pre-Mortem

- Step 1.4 replaces the string `Jekyll::LlmsTxt` and leaves `module Jekyll` / `module LlmsTxt` in place, so the gemspec NameErrors: step 1.4 names that nested pair, `version.rb`, and `LlmsTxt.scope_builders` as the same rewrite.
- README keeps teaching `Jekyll::LlmsTxt` after the code moves: step 2 updates that sample before the phase ends.
- Devblog breakage is treated as in-scope and the task stalls on another repo: Challenge 3 keeps that site out of this plan.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [x] Preflight
- [x] Build
- [ ] QA
