# Task: fix review crashes and missed names

* Task ID: fix-review-crashes
* Complexity: Level 2
* Type: bug fix

Three review crashes stay on the renamed tree: scope sort compares `Date` and `Time`, a nil `categories` value breaks category scopes, and an extensionless URL gets no `.md` sidecar. A tracked-file search found no leftover gem or module name outside memory-bank archives and generated coverage. `create_llms_txt` stays; it names the `llms.txt` artifact.


## Test Plan (TDD)

### Behaviors to Verify

- A `Date` and a later `Time` in one scope → no exception, and the later `Time` sorts first
- A `Date` and a `Time` that compare equal → no exception, then relative path ascending
- An undated page beside an epoch `Time` → existing path order, unchanged
- `include_categories: true`, one page with a present nil `categories` key, and one post in `record` → no exception, a `/category/record/` scope that lists only the post
- `include_categories: true` and only a nil `categories` key → no exception, and no category scope
- A Markdown page whose URL is `/about` → sidecar row path `/about.md`
- `/foo/bar/baz.html` → `/foo/bar/baz.md`, and `/foo/bar/` → `/foo/bar/index.md` (existing examples)

### Test Infrastructure

- Framework: RSpec via `bundle exec rspec`
- Test location: `spec/`
- Conventions: examples live under the class they exercise. Scope sort and category examples are in `spec/scope_spec.rb` and build entries with `JekyllLlmSidecars::Entry` or `build_site`. Manifest examples are in `spec/manifest_spec.rb` and use `rows_for`.
- New test files: none

## Implementation Plan

### 1. Scope sort — executable

- Files: `spec/scope_spec.rb`, `lib/jekyll-llm-sidecars/scope.rb`

1. Stub tests: two empty examples beside the existing sort examples in `spec/scope_spec.rb`.
2. Stub interface: none. `Scope#initialize` and `entry_time` already exist.
3. Write tests and run red: one example sorts `Date.new(2020, 1, 1)` after `Time.new(2020, 1, 2)`; one example gives both the same instant and expects path order `a.md`, `b.md`. Run those examples and confirm `NoMethodError`.
4. Write code and run green: `entry_time` returns `date.to_time` when `date` responds to `to_time`, otherwise `Time.at(0)`. Re-run the sort examples, including the two existing epoch examples.

### 2. Nil categories — executable

- Files: `spec/scope_spec.rb`, `lib/jekyll-llm-sidecars/scope_builder.rb`

1. Stub tests: two empty examples in the category section of `spec/scope_spec.rb`.
2. Stub interface: none. `category_names` already exists.
3. Write tests and run red: the mixed nil-and-`record` example, and the nil-only example. Confirm the mixed example raises `ArgumentError` from `uniq.sort`.
4. Write code and run green: `category_names` returns `Array(item.data["categories"])`. Re-run the category examples, including "adds one category scope per non-empty category".

### 3. Extensionless sidecar — executable

- Files: `spec/manifest_spec.rb`, `lib/jekyll-llm-sidecars/manifest.rb`, `README.md`

1. Stub tests: one empty example beside "adds one sidecar per Markdown entry" in `spec/manifest_spec.rb`.
2. Stub interface: none. `sidecar_path` already exists.
3. Write tests and run red: `permalink: /about` on a Markdown page, expect a sidecar path `/about.md`. Confirm the row is `/about`.
4. Write code and run green: when the URL has no `.` after the last `/` and does not end in `/`, append `.md`. Keep the trailing-slash and extension branches. Re-run the sidecar examples. In `README.md`, add the bullet that `/about` becomes `/about.md`. No test for the README sentence.

### 4. Missed names — prose/policy

- Files: whatever a search names, if any
- No tests: prose/policy artifact

1. Search tracked files for `jekyll-llms-txt`, `JekyllLlmsTxt`, and `jekyll/llms_txt`, excluding `memory-bank/archive/` and `coverage/`.
2. Rename a hit only when it is an inaccurate current name. Leave archives, `create_llms_txt`, and the checkout directory.

## Technology Validation

No new technology - validation not required

## Dependencies

- RSpec and the installed Jekyll 4.4.1 / Ruby 3.4.7 already in the bundle
- `Date#to_time` and `Time#to_time` from the standard library

## Challenges & Mitigations

- `Date#to_time` and a post `Time` can differ by timezone offset, so a same-calendar-day pair might not tie: the equal-instant example must use `date.to_time` as the `Time`, not a hand-built `Time.new` of that civil date.
- Jekyll may turn `permalink: /about` into `/about.html` or `/about/`. If the red example's URL is not `/about`, assert against the URL the fixture actually produces, or set the double's `url` to `/about` and call `add_sidecars`.
- `Array("record")` is `["record"]`. Posts already store arrays via `populate_categories`. Re-run the existing category example so a string category is not required for this fix.
- A blind replace of `llms_txt` would rename `create_llms_txt`. The search step lists hits and edits only inaccurate project names.

## Pre-Mortem

- The plan treats the README as the sidecar contract and then edits a case the code never emits: Challenge 2 already covers verifying the URL before locking the assertion.
- Archives and coverage still contain the old name, and a later search treats them as misses: the search step excludes those trees. The checkout directory is also excluded.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [x] Preflight
- [x] Build
- [x] QA

## QA Results

PASS. All four units match the plan exactly; both new sort examples, both new category examples, and the new sidecar example exist and pass. Independent name re-search confirms no inaccurate old gem or module name remains. Full suite 138 examples, 0 failures; RuboCop clean. One non-blocking advisory carried over from preflight: a precomputed sort key would avoid per-comparison `to_time` calls.
