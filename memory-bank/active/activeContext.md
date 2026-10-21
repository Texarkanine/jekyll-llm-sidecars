# Active Context

## Current Task: Sidecar introducing headings
**Phase:** PREFLIGHT - COMPLETE (PASS WITH ADVISORY)

## What Was Done
- Classified the work as Level 2 and wrote the plan in `memory-bank/active/tasks.md`.
- Recommendation: every sidecar starts with an H1 of the index title. Posts add one line, `YYYY-MM-DD`, plus ` - author` when the author is a non-blank string. Subtitle, categories, tags, description, and the devblog's "a fable" line stay off. The preamble is joined only when the sidecar file is rendered, so `llms-full.txt` keeps the source body under its own H2.
- Preflight failed fixable: Jekyll's `parse_date` is `Time.parse(input).localtime`, so an offset evening does not stay on the authored day. The offset example now pins `timezone: America/Chicago`, expects Liquid's own `%Y-%m-%d`, and restores `ENV["TZ"]`. Advisories applied: split the author examples, drop the bare-`#` branch, name the pink-margarine sidecar path, and list the remaining "source body only" sentences in the docs step. Acceptance criterion 2 now records the subtitle omission.
- Second preflight passed with advisories. The docs step now names the README Features bullet and keeps the Liquid sentence. Use-case 1 no longer says the sidecar shows a subtitle. `Preamble` stays its own class.

## Next Step
- Build, starting at `Preamble`.
