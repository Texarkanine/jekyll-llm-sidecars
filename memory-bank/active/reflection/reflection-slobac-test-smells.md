---
task_id: slobac-test-smells
date: 2026-09-23
complexity_level: 2
---

# Reflection: Fix SLOBAC test smells

## Summary

The 15 findings in the 2026-09-23 SLOBAC audit are remediated in the spec suite. RSpec, RuboCop, and mutant (2505 kills, 0 alive) are green.

## Requirements vs Outcome

Each finding is addressed as the audit prescribed. Two Body examples were added beyond the plan (`render_with_liquid: false`, and `include_relative`) because those kills only run from `spec/body_spec.rb`. The unflagged `NoMethodError` pin is unchanged. No production code changed.

## Plan Accuracy

The file list and the order of smell fixes were right. The plan said to delete the weaker cleanup and category examples. That deletion drops kills unless the assertion is folded into an example mutant still runs for that subject. The first build kept the duplicate examples instead of folding. Preflight was right that a Liquid error message does not carry the path, and that Rouge splits `puts :hi`.

## Build & QA Observations

The first QA failed on findings 13 and 14. The rework deleted those standalone examples and folded the kills into examples already under `Generator` and `Hooks`. A second `generate` plus `cleanup` removes `/category/record/llms.txt`, so the nested read has to happen before that cleanup.

## Insights

### Technical
- Mutant runs only the examples that executed the mutated subject. A stronger example in another file does not keep that subject's kill-set.
- Jekyll 4.4 does not call Liquid when the body has no tag, so `stats_table` stays empty until the body contains a tag.
- After a later `generate` and `cleanup`, the nested category index is gone even though the first write created it.

### Process
- When the audit says delete a redundant example and also keep the kill-set, fold the assertion into an example under the mutated subject before deleting. QA caught the first build skipping that fold.

### Million-Dollar Question

Examples would be grouped under the subject mutant executes, and each kill would be one assertion on that example. The duplicate examples would never have been separate tests.
