---
task_id: sidecar-preamble
complexity_level: 2
date: 2026-10-21
status: completed
---

# TASK ARCHIVE: Sidecar introducing headings

## SUMMARY

Markdown sidecars open with the index title as an H1. A post adds `YYYY-MM-DD`, and ` - author` when the author is a non-blank string. Subtitle, categories, tags, description, and the devblog's "a fable" line stay off. The README says why a subtitle is omitted. Pull request 6 is open.

## REQUIREMENTS

A reader who saw the HTML introduction should still see those lines on the sidecar. The title is required. Other introducing lines follow stock Jekyll fields: date and author on posts, and no subtitle, because `subtitle` is not a predefined Jekyll field and a run-of-the-mill post header does not show it. Proof was the gem's unit tests and a devblog `bundle exec jekyll build` against this gem on disk, then a non-draft pull request.

## IMPLEMENTATION

`Preamble.call` builds the heading. `Generator#render_row` concatenates it for sidecar rows only. `Body.call` stays the rendered source, so `llms-full.txt` still puts that source under its own H2. README, product context, and system patterns state that contract.

The date is `strftime("%Y-%m-%d")` on the Time Jekyll stored. Jekyll 4.4.1's `Utils.parse_date` is `Time.parse(input).localtime`, so the civil day is the machine zone, which is the day Liquid prints. CI on this branch asks setup-ruby for Ruby `3.4` because `ubuntu-latest` only has the latest 3.4 patch. `.ruby-version` is the exact local pin.

## TESTING

RSpec: 157 examples, 0 failures. RuboCop: 29 files, no offenses. The preamble specs went red on an empty return, then green. The generator specs went red on the old body strings, then green. The corpus strings stayed put.

Devblog build against the local gem: `_site/2026/10/20/lintel.md` starts with the title and `2026-10-20 - niko`, and does not contain "a fable". `_site/2026/03/01/pink-margarine.md` has the title, `2026-03-01 - texarkanine`, and not the subtitle. The devblog Gemfile and lockfile were restored.

The first QA failed because the Sidecars section listed the subtitle omission and did not give the reason. One sentence fixed it. The second QA passed.

## LESSONS LEARNED

Jekyll's stored date is already in the machine zone. Formatting that Time matches the HTML. Parsing the raw front matter to keep an authored offset would not.

`Jekyll::Document` has no `name`. A post with no title in front matter still has the slug title on `data["title"]`.

A review suggested `item.date` so a lone dateless draft would not abort the build. Dismissed. With Jekyll's default `future: false`, reading the draft already fills `data["date"]`. The crash also needs `future: true` and that draft as the only included document. A blog's other pages or posts fill the date during the root-scope sort.

## PROCESS IMPROVEMENTS

When an acceptance criterion names the sentence a document must contain, the plan's prose step has to name that sentence. "State the omissions" was not enough for "record why."

## TECHNICAL IMPROVEMENTS

None. The body slot stays the rendered source, and the sidecar file adds the preamble at render time. The meta line does not move onto `Summary::Line`. The index does not print that line.

## NEXT STEPS

None. Pull request 6 is open.
