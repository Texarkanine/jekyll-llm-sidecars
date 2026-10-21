---
task_id: sidecar-preamble
date: 2026-10-21
complexity_level: 2
---

# Reflection: Sidecar introducing headings

## Summary

Sidecar files now open with the index title as an H1. A post adds its date, and its author when that value is a non-blank string. The devblog build of the lintel post shows that heading. QA passed after the README recorded why a subtitle is left off.

## Requirements vs Outcome

The title is on every sidecar. The date and the author are on posts, which is what a run-of-the-mill post header shows. Subtitle, categories, tags, description, and the devblog's "a fable" line stay off. The subtitle omission is the recommendation the brief allowed, and the README now says why. `llms-full.txt` still uses the source body under its own H2. Nothing was added beyond that contract.

## Plan Accuracy

The file list and the order held: preamble class, then sidecar concatenation, then the contract text, then the devblog build. The offset-date example was wrong until preflight measured `Utils.parse_date`. The challenges that mattered were that one, and keeping the preamble out of the body slot. The devblog Gemfile restore was uneventful.

## Build & QA Observations

The preamble specs went red on an empty return, then green. The generator specs went red on the old body strings, then green, and the corpus strings stayed put. The devblog lintel sidecar starts with the title and `2026-10-20 - niko`. Pink margarine has the date and `texarkanine`, and not the subtitle. The first QA failed because the Sidecars section listed the omission and did not give the reason acceptance criterion 2 names. One sentence fixed it. The second QA passed.

## Insights

### Technical

- Jekyll 4.4.1 stores `Time.parse(input).localtime`. An authored offset is already gone, and the civil day is the machine zone, which is the day Liquid prints. Formatting that stored Time matches the HTML. Parsing the raw front matter to keep the authored day would not.
- `Jekyll::Document` has no `name`. A post with no title in front matter still has the slug title on `data["title"]`.

### Process

- When an acceptance criterion names the sentence a document must contain, the plan's prose step has to name that sentence. "State the omissions" was not enough for "record why."

## Million-Dollar Question

The split we built is the one to keep. The body slot stays the rendered source, the corpus keeps its H2, and the sidecar file adds the preamble at render time. Putting the meta line on `Summary::Line` would share a type with the index for a line the index does not print.
