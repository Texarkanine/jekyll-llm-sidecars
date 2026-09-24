# Task: Fix SLOBAC test smells

* Task ID: slobac-test-smells
* Complexity: Level 2
* Type: simple enhancement

Rewrite the examples named in `.slobac/2026-09-23T19-16-57/audit.md` so each remaining example asserts the behavior its title names. Product code under `lib/` stays unchanged. Unflagged examples stay unchanged, including `generator_spec.rb` "raises when the liquid config is absent".

## Test Plan (TDD)

### Behaviors to Verify

- A full build writes sidecars and joins corpus bodies without reading `LiquidRenderer` `@stats`.
- After `Body.call`, `site.liquid_renderer.stats_table` includes that page's `path`. That is the public stand-in for the removed `@stats` assertion. `profile: true` is not required.
- `Body.call` count equals the Markdown documents in the `files` fixture, derived in the example.
- Unknown filter, lax or with `strict_filters` absent: `Body.call` returns `"x\n"`.
- Unknown variable, `strict_variables: false` or key absent: `Body.call` returns `"\n"`.
- A highlight tag is rendered: the raw `{% highlight` tag is gone, the sidecar includes `class="highlight"` and `language-ruby`, and the sidecar with tags stripped contains `puts :hi`. No `>puts</span>` pin.
- With no stored build, `Hooks.inject` leaves a document's existing HTML output unchanged.
- A nil document output reached through `process_site` does not stop `Hooks.inject` from linking a later page.
- `scope_builders` is restored after every example, including on failure.
- Alternate-link head placement, cleanup keep-and-delete, and byte-exact category indexes remain covered by the stronger example only.

### Test Infrastructure

- Framework: RSpec, `bundle exec rspec`
- Test location: `spec/`
- Conventions: one file per subject (`generator_spec.rb`, `hooks_spec.rb`, `scope_spec.rb`); sites from `spec/support/site_fixtures.rb` (`build_site`, `process_site`, `read_dest`, `page_body`); `frozen_string_literal`
- New test files: `spec/body_spec.rb`

## Implementation Plan

### 1. Restore scope builders — executable

- Files: `spec/scope_spec.rb`

1. Stub tests: replace the file `before` clear with an `around` hook that saves `Jekyll::LlmsTxt.scope_builders`, clears, runs, and `replace`s the saved list in `ensure`. Use `around do ... ensure ... end`. The brace form `around { ... ensure ... }` is a SyntaxError on this Ruby.
2. Stub interface: none. `Jekyll::LlmsTxt.scope_builders` already exists.
3. Write tests and run red: the around hook is the fix; there is no separate assertion. Run `bundle exec rspec spec/scope_spec.rb`.
4. Write code and run green: no `lib/` change. Run `bundle exec rspec --order random --seed 1`, seed 2, and seed 3.

### 2. Move Body Liquid examples and strengthen the lax renders — executable

- Files: `spec/body_spec.rb` (new), `spec/generator_spec.rb`

1. Stub tests: create `spec/body_spec.rb` with `RSpec.describe Jekyll::LlmsTxt::Body` and empty `it` shells for the eight examples now under `Generator #generate` from "raises when strict_variables is on" through "renders an unknown variable when the strict_variables key is absent".
2. Stub interface: none. `Jekyll::LlmsTxt::Body.call` already exists.
3. Write tests and run red: copy each example's fixture and call. For the four "renders" examples, assert `eq("x\n")` or `eq("\n")` as the audit states, instead of `not_to raise_error`. Leave the four raise examples' assertions as they are. Run `bundle exec rspec spec/body_spec.rb` and expect green, because the product already renders those strings. If one is red, stop: the oracle is wrong.
4. Write code and run green: delete those eight examples from `spec/generator_spec.rb`. No `lib/` change. Run `bundle exec rspec spec/body_spec.rb spec/generator_spec.rb`.

### 3. Attribute Liquid renders through stats_table — executable

- Files: `spec/body_spec.rb`, `spec/generator_spec.rb`

1. Stub tests: add an empty example in `spec/body_spec.rb`, "records the document path on the liquid renderer".
2. Stub interface: none. `Jekyll::LiquidRenderer#stats_table` is already public.
3. Write tests and run red: `build_site` a Markdown page, call `Jekyll::LlmsTxt::Body.call(page)`, and expect `site.liquid_renderer.stats_table` to include `page.path`. Do not set `profile: true`. Do not read `@stats`. Remove `instance_variable_get(:@stats)` from "writes sidecars and joins corpus bodies with one newline". Run `bundle exec rspec spec/body_spec.rb`.
4. Write code and run green: no `lib/` change. `Body.render_liquid` already passes `item.path`, and `file(path)` records that name.

### 4. Derive the body-computer count — executable

- Files: `spec/generator_spec.rb`

1. Stub tests: none new. Edit "runs the body computer once per Markdown document".
2. Stub interface: none.
3. Write tests and run red: set the expected count to `files.keys.count { |path| path.end_with?(".md") && !path.start_with?("_layouts") }` and assert `exactly(that).times`.
4. Write code and run green: no `lib/` change. Run that example.

### 5. Drop the weaker duplicate examples — executable

- Files: `spec/generator_spec.rb`, `spec/hooks_spec.rb`

1. Stub tests: none. The kept examples already exist: `hooks_spec.rb` "points Markdown pages at their sidecar and skips HTML pages", `hooks_spec.rb` "keeps llms.txt and deletes a file this plugin did not write", `generator_spec.rb` "writes the root, category, and collection indexes".
2. Stub interface: none.
3. Write tests and run red: run those three examples and confirm they pass before deleting anything.
4. Write code and run green: delete "puts the sidecar alternate link in the rendered head", "keeps llms.txt when cleanup runs without a later write", and "writes a nested category index into the destination". On the kept cleanup example, add a one-line comment that cleanup runs without a later write. Run `bundle exec rspec spec/generator_spec.rb spec/hooks_spec.rb`.

### 6. Assert highlight rendering without Rouge span pins — executable

- Files: `spec/generator_spec.rb`

1. Stub tests: none new. Edit "renders a highlight tag into the sidecar".
2. Stub interface: none. Do not add Nokogiri; it is not a project dependency, and the audit names it only as one parser.
3. Write tests and run red: assert the sidecar does not include `{% highlight`, and that it includes `class="highlight"` and `language-ruby`. Strip tags from the sidecar and assert that text includes `puts :hi`. Drop `>puts</span>` and `>:hi</span>`. The contiguous substring `puts :hi` is absent because Rouge splits those tokens.
4. Write code and run green: no `lib/` change. Run that example.

### 7. Reach a nil output through the public build — executable

- Files: `spec/hooks_spec.rb`

1. Stub tests: none new. "links a later page when an earlier page output is nil" already calls `process_site`, nils an earlier output, and calls `described_class.inject`.
2. Stub interface: none.
3. Write tests and run red: run that example and confirm it passes.
4. Write code and run green: delete "does not raise when a document output is nil" (the `instance_variable_set(:@llms_txt)` example). Run `bundle exec rspec spec/hooks_spec.rb`.

### 8. Assert inject leaves existing HTML alone — executable

- Files: `spec/hooks_spec.rb`

1. Stub tests: none new. Edit "leaves the site alone when no build was stored".
2. Stub interface: none.
3. Write tests and run red: set the page output to `"<html><head></head></html>"`, call `described_class.inject(site)`, and expect that output `eq` the original string.
4. Write code and run green: no `lib/` change. Run that example, then `bundle exec rspec`.

## Technology Validation

No new technology - validation not required. Nokogiri is not added.

## Dependencies

- Existing RSpec suite and `spec/support/site_fixtures.rb`
- Mutant, run once at the end of build: `bundle exec mutant run`
- The audit's prescribed remediations

## Challenges & Mitigations

- `stats_table` may omit the path unless rendering actually calls `file(path)`: the preflight run already saw `marked.md` recorded without `profile: true`. If a later Jekyll stops recording on the success path, call `Body.call` on a strict-variable error and read `stats_table` again. Do not put `instance_variable_get` back.
- Derived Markdown count may not equal 7 if a fixture path is Markdown but not a document: compare the derived number to 7 once, and adjust the predicate only if a named file is wrongly included or excluded. Do not hard-code 7 again.
- Deleting an example may drop a mutant kill: the end-of-build mutant run is the gate. Restore the unique assertion onto the kept example; do not restore the smell.
- `config.order = :random` is not set in the suite. The gate is three explicit shuffled seeds, so a permanent order change is not required.
- Strip-tags may still fail if Rouge inserts text between `puts` and `:hi`: assert the two tokens are present in order in the stripped text, still without pinning `</span>`.

## Pre-Mortem

- The plan treats a green strengthened example as proof and never checks mutants until the end, so a deleted example's unique kill is found late: the mutant run stays the last build step, and a kill loss sends that one example back, not the whole suite.
- Parsing highlight HTML with string `include` still couples to Rouge class names: accepted, because those two class names are the semantic layer the audit asks for, and the span-boundary pins are what get removed. The stripped-text check is in unit 6, not only in Challenges.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [x] Preflight
- [x] Build
- [ ] QA

## QA Results (2026-09-23) - FAIL

Thirteen of fifteen findings remediated as prescribed; all recorded gates green (rspec 131/0, rubocop clean, mutant 2505/0 alive, seeds 1-3). Full findings in `memory-bank/active/.qa-validation-status`.

Blocking:

- Finding 13: `generator_spec.rb` "keeps llms.txt when cleanup runs without a later write" was kept, not deleted. The weaker duplicate remains alongside `hooks_spec.rb` "keeps llms.txt and deletes a file this plugin did not write".
- Finding 14: `hooks_spec.rb` "writes a nested category index into the destination" was kept, not deleted. The weaker duplicate remains alongside the byte-exact `generator_spec.rb` "writes the root, category, and collection indexes".

Build must rerun: delete each weaker duplicate and fold any unique mutant kill into a kept example under the correct subject (the plan's mitigation), then show `bundle exec mutant run` stays at 0 alive. If folding demonstrably cannot preserve the kill-set, escalate to Plan - the audit's delete remediation and its kill-set gate would conflict, and keeping both examples is not a sanctioned resolution.

Advisory: `spec/body_spec.rb` has two examples the plan did not call for ("returns the source when render_with_liquid is false", "renders include_relative from the page directory"); decide keep-or-drop deliberately during the rework.
