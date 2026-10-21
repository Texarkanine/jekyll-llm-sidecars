# Active Context

## Current Task: Sidecar introducing headings
**Phase:** BUILD - COMPLETE

## What Was Done
- `Preamble.call` builds the sidecar heading. `Generator#render_row` concatenates it for sidecar rows only. `Body.call` and the corpus stay on the source body.
- Every sidecar starts with an H1 of the index title. Posts add `YYYY-MM-DD`, plus ` - author` when the author is a non-blank string. Subtitle, categories, tags, description, and a site-level author stay off.
- README, product context, and system patterns state that contract.
- Devblog `bundle exec jekyll build` against this gem wrote `_site/2026/10/20/lintel.md` as the title H1, then `2026-10-20 - niko`, with no "a fable". `_site/2026/03/01/pink-margarine.md` has the title, `2026-03-01 - texarkanine`, and not the subtitle. The devblog Gemfile and lockfile were restored.
- RSpec: 157 examples, 0 failures. RuboCop: 29 files, no offenses.

## Key decisions
- The date is `strftime("%Y-%m-%d")` on the Time Jekyll stored. The Chicago example locks that to Liquid's own date filter.
- `Preamble` stays its own class.

## Deviations
- None. The written-file check that a source H1 is kept sits in `spec/generator_spec.rb`. `Preamble.call` only asserts that the heading block does not include the body.

## Files
- `/home/mobaxterm/git/jekyll-llm-sidecars/lib/jekyll-llm-sidecars/preamble.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/lib/jekyll-llm-sidecars.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/lib/jekyll-llm-sidecars/generator.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/spec/preamble_spec.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/spec/generator_spec.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/spec/body_spec.rb`
- `/home/mobaxterm/git/jekyll-llm-sidecars/README.md`
- `/home/mobaxterm/git/jekyll-llm-sidecars/memory-bank/productContext.md`
- `/home/mobaxterm/git/jekyll-llm-sidecars/memory-bank/systemPatterns.md`

## Next Step
- QA review.
