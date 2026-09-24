# Task: Exclude globs and corpus headings

* Task ID: exclude-globs-corpus-headings
* Complexity: Level 2
* Type: bug fix

`**` in an exclude glob matches the named directory, its index, and everything under it. A non-root `llms-full.txt` introduces each document with an H1 of that document's title. Every corpus separates documents with exactly two newlines. The root corpus stays body-only.

## Test Plan (TDD)

### Behaviors to Verify

- `/tags/**/*` matches `/tags/`, `/tags/index.html`, and `/tags/bitcoin/` when flags include `File::FNM_EXTGLOB | File::FNM_PATHNAME`.
- `/error/**/*` matches `/error/404.html` with those flags.
- `/garden/tags/**/*` matches `/garden/tags/` and `/garden/tags/foo/`, and does not match `/tags/`.
- A root corpus of bodies `A` and `B` is `A\n\nB`. A root corpus of bodies `A\n` and `B\n` is `A\n\nB`.
- A non-root corpus of two documents is `# Title\n\nbody\n\n# Other\n\nother`, using `entry.summary.name`.
- A sidecar is still the body alone.

### Test Infrastructure

- Framework: RSpec, `bundle exec rspec`
- Test location: `spec/census_spec.rb` for globs, `spec/generator_spec.rb` for corpus text
- Conventions: `build_site` / `process_site`, `frozen_string_literal`
- New test files: none

## Implementation Plan

### 1. Match `**` exclude globs — executable

- Files: `lib/jekyll/llms_txt/census.rb`, `spec/census_spec.rb`

1. Stub tests: add examples "excludes a directory index written with a double-star glob" and "excludes a one-segment path written with a double-star glob".
2. Stub interface: none. `Census` and `Configuration#exclude` already exist.
3. Write tests and run red: a page at `/tags/index.html` and a page at `/error/404.html` drop out when exclude is `["/tags/**/*"]` and `["/error/**/*"]`. Run those examples.
4. Write code and run green: pass `File::FNM_EXTGLOB | File::FNM_PATHNAME` to `File.fnmatch?` in `excluded?`. Run `bundle exec rspec spec/census_spec.rb`.

### 2. Separate corpus documents with two newlines — executable

- Files: `lib/jekyll/llms_txt/generator.rb`, `spec/generator_spec.rb`, `README.md`

1. Stub tests: change the two root join examples that expect `"A\n\nB\n"` and `"A\nB"`.
2. Stub interface: none. `Generator#render_row` already joins corpus bodies.
3. Write tests and run red: both examples expect `"A\n\nB"`. Run them.
4. Write code and run green: chomp trailing newlines on each body and `join("\n\n")` for the root corpus (`scope.path_prefix == "/"`). Update the README sentence that says corpora are joined by one newline and are not chomped. Run those examples.

### 3. Put each document title on its own H1 — executable

- Files: `lib/jekyll/llms_txt/generator.rb`, `spec/generator_spec.rb`, `README.md`

1. Stub tests: add "starts each document in a category corpus with that document's title".
2. Stub interface: none. `entry.summary.name` is already the link text.
3. Write tests and run red: a category build with two posts expects the corpus to equal `"# Alpha\n\nA\n\n# Beta\n\nB"`. Run it.
4. Write code and run green: for a non-root corpus, each block is `"# #{entry.summary.name}\n\n#{body}"` with the body chomped, and blocks are joined by `"\n\n"`. Sidecars stay the body alone. README states that a non-root corpus uses those H1s and that the root corpus does not. Run `bundle exec rspec`.

## Technology Validation

No new technology - validation not required.

## Dependencies

- Existing RSpec helpers in `spec/support/site_fixtures.rb`
- Ruby `File::FNM_EXTGLOB`, already present on this Ruby

## Challenges & Mitigations

- `FNM_EXTGLOB` can change older globs such as `/*.xml`: keep the existing exclude examples and run `spec/census_spec.rb` after the flag change.
- A body that is only newlines becomes an empty string after chomp, so two empty documents become `"\n\n"` or `"# T\n\n\n\n# U"`. Assert the headed example with normal one-line bodies.
- Collection corpora such as `/garden/llms-full.txt` use the same non-root path, so they gain H1s too. That is the same rule as tags and categories.

## Pre-Mortem

- The plan special-cases only the root and then a custom scope still renders like the root: the rule is `path_prefix == "/"`, and tags and categories are not that prefix.
- Chomping eats a meaningful trailing blank line inside one document: the operator asked for exactly two newlines between documents, which requires the chomp. A blank line inside a body is not at the end and stays.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [ ] Preflight
- [ ] Build
- [ ] QA
