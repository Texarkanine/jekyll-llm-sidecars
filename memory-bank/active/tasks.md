# Task: match sibling gem layout

* Task ID: match-sibling-layout
* Complexity: Level 2
* Type: simple enhancement

Move the plugin onto the family layout. One directory, `lib/jekyll-llms-txt/`. One entry, `lib/jekyll-llms-txt.rb`. One module, `JekyllLlmsTxt`. The gem name stays `jekyll-llms-txt`. Generated files stay as they are.

## Test Plan (TDD)

### Behaviors to Verify

- `require "jekyll-llms-txt"` in a child process with an empty gem home and the parent load path → `JekyllLlmsTxt` is defined, and it was not defined before the require
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
3. Write tests and run red: replace `Jekyll::LlmsTxt` with `JekyllLlmsTxt` in `spec/version_spec.rb` and every other `spec/*_spec.rb`. The `"jekyll-llms-txt"` example also aborts if `defined?(Jekyll::LlmsTxt)`. The `"jekyll/llms_txt"` example expects `LoadError`. Run `bundle exec rspec`. The require example fails because the library still defines `Jekyll::LlmsTxt`.
4. Write code and run green: move `lib/jekyll/llms_txt/*.rb` to `lib/jekyll-llms-txt/`. Delete `lib/jekyll/llms_txt.rb` and the empty `lib/jekyll/` directory. Replace every `Jekyll::LlmsTxt` in `lib/` and in `jekyll-llms-txt.gemspec` with `JekyllLlmsTxt`, including `spec.version`, `hooks.rb` register call sites, and `generator.rb` `current_destinations`. A module-declaration-only edit leaves those qualified names behind and `bundle exec rspec` NameErrors while loading the gemspec. Point `lib/jekyll-llms-txt.rb` at `require_relative "jekyll-llms-txt/..."`. In `config/mutant.yml`, set the subject to `JekyllLlmsTxt*` and delete the four `module Jekyll` ignore patterns. Run `bundle exec rspec`.

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

- The move renames files and leaves `module Jekyll` in place, so the suite goes green on the old constant: step 1.3 changes the specs first, so green requires the new constant.
- README keeps teaching `Jekyll::LlmsTxt` after the code moves: step 2 updates that sample before the phase ends.
- Devblog breakage is treated as in-scope and the task stalls on another repo: Challenge 3 keeps that site out of this plan.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [ ] Preflight
- [ ] Build
- [ ] QA
