---
task_id: slobac-test-smells
complexity_level: 2
date: 2026-09-24
status: completed
---

# TASK ARCHIVE: Fix SLOBAC test smells

## SUMMARY

All 15 findings in `.slobac/2026-09-23T19-16-57/audit.md` are remediated in the spec suite. Production code did not change. RSpec, RuboCop, and mutant (2505 kills, 0 alive) are green.

## REQUIREMENTS

- Fix each finding with the audit's prescribed remediation and gates.
- Finding 12 deletes the weaker alternate-link example. Finding 15 moves the eight Body Liquid examples into `spec/body_spec.rb` and asserts the rendered strings.
- Leave unflagged examples as they are, including the `NoMethodError` pin.
- The mutation kill-set must not shrink. The `scope_builders` restore must stay green under shuffled order.

## IMPLEMENTATION

Changes are in `spec/body_spec.rb` (new), `spec/generator_spec.rb`, `spec/hooks_spec.rb`, and `spec/scope_spec.rb`.

- `scope_builders` is saved and restored with `around do ... ensure ... end`.
- Lax Liquid examples assert `eq("x\n")` or `eq("\n")`.
- The `@stats` read is gone. `stats_table` includes `page.path` for `docs/marked.md`, whose body contains a Liquid tag.
- The body-computer count is derived from the fixture. Highlight text is checked after stripping tags.
- A nil output is reached through `process_site`. Inject with no stored build leaves existing HTML unchanged.
- The alternate-link check looks inside `<head>` on the sidecar example.
- The cleanup-keep assertion sits on "writes llms.txt into the destination". The nested category read sits on the hooks cleanup example, before the second cleanup.

Two Body examples were added beyond the plan (`render_with_liquid: false`, and `include_relative`) because those kills only run from `spec/body_spec.rb`.

## TESTING

- `bundle exec rspec`: 129 examples, 0 failures. Shuffled seeds 1, 2, and 3 passed after the `scope_builders` restore. QA also ran seed 2.
- `bundle exec rubocop`: no offenses.
- `bundle exec mutant run`: 2505 kills, 0 alive, 0 timeouts.
- Preflight failed once on a Liquid error message that does not carry the path, and on the contiguous substring `puts :hi`. The revised oracles passed with an advisory.
- The first QA failed because findings 13 and 14 were still separate examples. The second QA passed after those assertions were folded into examples mutant still runs.

## LESSONS LEARNED

Mutant runs only the examples that executed the mutated subject. A stronger example in another file does not keep that subject's kill-set. Jekyll 4.4 does not call Liquid when the body has no tag, so `stats_table` stays empty until the body contains a tag. A later `generate` plus `cleanup` removes `/category/record/llms.txt` even though the first write created it. That fact is also in `memory-bank/techContext.md`.

## PROCESS IMPROVEMENTS

When an audit says to delete a redundant example and also keep the kill-set, fold the assertion into an example under the mutated subject before deleting. The first build kept both examples. QA caught that.

## TECHNICAL IMPROVEMENTS

Examples would be grouped under the subject mutant executes, so each kill is one assertion on that example and the duplicate examples would not exist.

## NEXT STEPS

None.
