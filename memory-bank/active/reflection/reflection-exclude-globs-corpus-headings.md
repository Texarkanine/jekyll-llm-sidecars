---
task_id: exclude-globs-corpus-headings
date: 2026-09-24
complexity_level: 2
---

# Reflection: Exclude globs and corpus headings

## Summary

Exclude globs written as `/**/*` now match the directory, its index, and nested paths. A non-root `llms-full.txt` starts each document with an H1 of that document's title, and every corpus separates documents with exactly two newlines. The suite is green.

## Requirements vs Outcome

The four brief requirements landed. Collection corpora get the same H1s as tags and categories, because they share the non-root path. The root corpus stays body-only. `FNM_EXTGLOB` was dropped; `FNM_PATHNAME` alone matches the globs.

## Plan Accuracy

The heading shape changed before the plan was written: document titles stay H1s, and the live scope-H1 / page-H2 shape was rejected. Preflight caught that `FNM_PATHNAME` breaks the old `/assets/**` default, and that the seven-body corpus example also had to change.

## Build & QA Observations

The first mutant run left three alive: two equivalent flag spellings, and a chomp that only removed one newline. A body ending in two newlines killed the chomp. QA passed with advisories only.

## Insights

### Technical
- Ruby `File.fnmatch?` does not treat `**` as a directory tree until `FNM_PATHNAME` is set. `/tags/**/*` then matches `/tags/` and `/tags/index.html`. `/assets/**` stops matching a nested file, so the default is `/assets/**/*`.
- `FNM_EXTGLOB | FNM_PATHNAME` and `FNM_EXTGLOB ^ FNM_PATHNAME` are the same integer, because those flag bits do not overlap.

### Process
- A join rule that says "exactly two newlines" needs a fixture whose body already ends in more than one newline, or the chomp mutant survives.

### Million-Dollar Question

Corpus text would have been defined as chomped documents joined by `\n\n`, with a document H1 on every scope except the root, and exclude globs would have been specified as pathname globs from the first test.
