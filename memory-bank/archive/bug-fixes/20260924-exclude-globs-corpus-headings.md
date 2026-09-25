---
task_id: exclude-globs-corpus-headings
complexity_level: 2
date: 2026-09-24
status: completed
---

# TASK ARCHIVE: Exclude globs and corpus headings

## SUMMARY

`/**/*` exclude globs now match the named directory, its index, and nested paths. A non-root `llms-full.txt` starts each document with an H1 of that document's title. Every corpus separates documents with exactly two newlines. The root corpus stays body-only.

## REQUIREMENTS

- A glob such as `/tags/**/*` or `/error/**/*` excludes that directory, its index, and everything under it.
- Each document in a tag or category corpus keeps its title as an H1. There is no scope H1.
- Documents in every `llms-full.txt` are separated by exactly two newlines.
- The root `llms-full.txt` stays joined sidecar bodies, with no added heading.

## IMPLEMENTATION

`Census#excluded?` passes `File::FNM_PATHNAME` to `File.fnmatch?`. The default assets glob is `/assets/**/*`, because `/assets/**` stops matching nested files under that flag.

`Generator#corpus_block` chomps trailing newlines on each body and joins the blocks with `\n\n`. When `scope.path_prefix` is not `/`, the block is `# {entry.summary.name}` plus the body. Collection corpora use that same non-root path, so they get H1s too. Sidecars stay the body alone.

## TESTING

- `bundle exec rspec`: 132 examples, 0 failures.
- `bundle exec rubocop`: no offenses.
- Mutant on `Census#excluded?` and `Generator#corpus_block`: 82 kills, 0 alive. An earlier full run left three alive; a body ending in two newlines killed the one-newline chomp, and `FNM_PATHNAME` alone replaced the `FNM_EXTGLOB | FNM_PATHNAME` spelling because those bits do not overlap.
- Preflight failed once, then passed after the default-glob migration and the seven-body corpus example were added to the plan.
- QA passed. Advisories: the flag spelling, a few unpinned glob variants, and a possible `Scope#root?` helper.

## LESSONS LEARNED

Ruby `File.fnmatch?` does not treat `**` as a directory tree until `FNM_PATHNAME` is set. `FNM_EXTGLOB | FNM_PATHNAME` and `FNM_EXTGLOB ^ FNM_PATHNAME` are the same integer. A chomp of one trailing newline looks correct until a body ends in two.

## PROCESS IMPROVEMENTS

A join rule that says "exactly two newlines" needs a fixture whose body already ends in more than one newline.

## TECHNICAL IMPROVEMENTS

Corpus text would have been defined as chomped documents joined by `\n\n`, with a document H1 on every scope except the root, and exclude globs would have been pathname globs from the first test.

## NEXT STEPS

None.
