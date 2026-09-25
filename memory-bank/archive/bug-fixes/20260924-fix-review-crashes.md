---
task_id: fix-review-crashes
complexity_level: 2
date: 2026-09-24
status: completed
---

# TASK ARCHIVE: fix review crashes and missed names

## SUMMARY

Three review crashes are fixed. Scope sort coerces dates with `to_time`, a nil `categories` value becomes `[]`, and an extensionless sidecar URL gets `.md` appended. A search found no inaccurate old gem or module name left to rename. QA passed.

## REQUIREMENTS

- Normalize entry dates to `Time` before comparing them, so a jekyll-archives `Date` and a post `Time` do not raise.
- Treat a missing or nil `categories` value as an empty list when `include_categories` is on.
- Append `.md` when a sidecar URL has no extension. Keep the trailing-slash `index.md` behavior.
- Rename a leftover `jekyll-llms-txt` name only when it is still inaccurate. Leave archives, coverage, `create_llms_txt`, and the checkout directory.

## IMPLEMENTATION

- `lib/jekyll-llm-sidecars/scope.rb`: `entry_time` returns `date.to_time` when the date responds to `to_time`, otherwise `Time.at(0)`.
- `lib/jekyll-llm-sidecars/scope_builder.rb`: `category_names` returns `Array(item.data["categories"])`.
- `lib/jekyll-llm-sidecars/manifest.rb`: `sidecar_path` appends `.md` when the last path segment has no dot.
- `README.md` lists `/about` → `/about.md`.
- The name search hit only SumMem history and this task's own text. No product rename.

`permalink: /about` is the URL `/about` on Jekyll 4.4.1. The equal-instant sort example uses `date.to_time` so the pair ties and then orders by relative path. The mixed nil-category case failed in `uniq.sort`; the nil-only case failed on `include?`.

## TESTING

New examples in `spec/scope_spec.rb` and `spec/manifest_spec.rb` failed for those reasons, then passed after each one-line change. The full suite was 138 examples, 0 failures, with full line coverage. RuboCop reported no offenses. `gem build` produced `jekyll-llm-sidecars-0.1.0.gem`. QA passed without changing the implementation.

## LESSONS LEARNED

`Date <=> Time` is nil on this Ruby, so a sort that calls `zero?` has to coerce both sides to `Time` first. `Hash#fetch`'s default does not run when the key is present and nil. `Array` does.

The boundary coercions are the fit. Jekyll posts and jekyll-archives date pages will keep different date classes, and front matter will keep storing nil. Converting at `entry_time`, `category_names`, and `sidecar_path` is where those differences should stop.

## PROCESS IMPROVEMENTS

Nothing notable. The plan's sequence held, and the permalink fallback was unused.

## TECHNICAL IMPROVEMENTS

None. A precomputed sort key was noted in preflight and left as a sketch.

## NEXT STEPS

None.
