# Active Context

## Current Task: Fix SLOBAC test smells
**Phase:** BUILD - COMPLETE

## What Was Done
- Restored `scope_builders` with an `around` hook in `spec/scope_spec.rb`
- Moved the eight Body Liquid examples to `spec/body_spec.rb` and asserted rendered strings for the lax cases
- Removed the `LiquidRenderer` `@stats` read. `spec/body_spec.rb` records `page.path` through `stats_table` for `docs/marked.md`
- Derived the Markdown body-computer count from the fixture
- Asserted highlight class names and tag-stripped text
- Drove the nil-output case through `process_site` and deleted the `@llms_txt` setup
- Asserted `Hooks.inject` leaves existing HTML unchanged when no build is stored

## Key Decisions
- Mutant selects examples by the subject they execute
- Finding 13: the cleanup-keep assertion is on "writes llms.txt into the destination". The separate generator example is gone
- Finding 14: the nested category read is on "keeps llms.txt and deletes a file this plugin did not write", before cleanup. The separate hooks example is gone

## Next Step
- QA review


## Files
- `/home/mobaxterm/git/jekyll-llms-txt/spec/body_spec.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/spec/generator_spec.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/spec/hooks_spec.rb`
- `/home/mobaxterm/git/jekyll-llms-txt/spec/scope_spec.rb`

## Next Step
- QA review
