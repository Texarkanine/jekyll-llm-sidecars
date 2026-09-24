# Active Context

## Current Task: fix review crashes and missed names
**Phase:** QA - COMPLETE (PASS)

## What Was Done
- `entry_time` returns `date.to_time` when the date responds to `to_time`, otherwise `Time.at(0)`.
- `category_names` returns `Array(item.data["categories"])`.
- `sidecar_path` appends `.md` when the last path segment has no dot. README lists `/about` → `/about.md`.
- Tracked-file search found no inaccurate gem or module name to rename. Hits were SumMem history, this task's brief, and the search step itself.

## Next Step
- QA review.

## Files modified
- `/home/mobaxterm/git/jekyll-llms-txt/lib/jekyll-llm-sidecars/scope.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/lib/jekyll-llm-sidecars/scope_builder.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/lib/jekyll-llm-sidecars/manifest.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/spec/scope_spec.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/spec/manifest_spec.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/README.md`

## Deviations
- None. `permalink: /about` stayed `/about`, so the manifest example did not need a double.
