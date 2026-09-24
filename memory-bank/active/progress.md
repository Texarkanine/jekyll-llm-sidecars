# Progress

Make `**` exclude globs match the directory trees the configuration names, and put a scope H1 plus per-document H2s on tag and category `llms-full.txt` files.

**Complexity:** Level 2

## 2026-09-24 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Confirmed the operator's intent against the live tag and category corpora and the blog exclude list
    - Wrote the project brief
* Decisions made
    - Level 2, because the work is two contained output fixes and the corpus heading shape is already visible in the live files
* Insights
    - `File.fnmatch?` without `FNM_EXTGLOB` does not treat `**` as a directory tree
    - `Generator#render_row` joins corpus bodies with no headings

## 2026-09-24 - PLAN - COMPLETE

* Work completed
    - Wrote the implementation plan in `memory-bank/active/tasks.md`
* Decisions made
    - Document titles are H1s on every non-root corpus, including collection corpora
    - The root corpus stays body-only and uses the same two-newline join
    - Match `**` with `File::FNM_EXTGLOB | File::FNM_PATHNAME`
* Insights
    - The live `# scope` / `## page title` shape demotes headings that already start at H2 inside the body

## 2026-09-24 - PLAN - COMPLETE

* Work completed
    - Revised the plan after preflight `FAIL (fixable)`
* Decisions made
    - Ship `/assets/**/*` as the default exclude glob
    - Update the seven-body root corpus example along with the two short join examples
* Insights
    - `/assets/**` matches a nested path today and stops matching once `FNM_PATHNAME` is set

## 2026-09-24 - BUILD - COMPLETE

* Work completed
    - Implemented pathname glob matching, the two-newline corpus join, and per-document H1s on non-root corpora
    - `bundle exec rspec`: 132 examples, 0 failures
    - `bundle exec rubocop`: no offenses
    - Mutant on `Census#excluded?` and `Generator#corpus_block`: 82 kills, 0 alive
* Decisions made
    - Pass only `File::FNM_PATHNAME`. `FNM_EXTGLOB` is the same bits as or-ing it with `FNM_PATHNAME` when the flags do not overlap, and pathname alone matches the globs
* Insights
    - A body that ends in two newlines is what kills a chomp of only one newline



## 2026-09-24 - PREFLIGHT - COMPLETE (FAIL (fixable))

* Work completed
    - Verified the `File::FNM_EXTGLOB | File::FNM_PATHNAME` fix against the brief's own globs and against the codebase's default exclude glob, by direct `File.fnmatch?` probing
    - Ran `spec/census_spec.rb`'s default-include example against `HEAD` to confirm its current pass depends on `/assets/**` matching nested paths
    - Simulated the old vs. new root-corpus join for the existing 7-body example to check for a divergence
* Decisions made
    - FAIL (fixable): the plan needs an added step migrating `Configuration::DEFAULT_EXCLUDE` (and its README and spec mirrors) from `/assets/**` to `/assets/**/*`, plus a step updating the untouched existing root-corpus example
* Insights
    - `File::FNM_PATHNAME` makes `X/**` (no trailing `/*`) stop matching more than one path segment deep - only `X/**/*` recurses fully. The shipped default exclude uses the old spelling

## 2026-09-24 - PREFLIGHT - COMPLETE (PASS)

* Work completed
    - Re-verified both prior `FAIL (fixable)` findings against the revised plan: the `/assets/**/*` default-exclude migration and the seven-body corpus example update are both now in unit 1 and unit 2's stub-tests steps
    - Checked TDD ordering, convention compliance, dependency impact (`Manifest::Row#scope` always populated for `:corpus` rows), conflict detection, and completeness against `Census`, `Generator`, `Manifest`, `Scope`, `ScopeBuilder`, `Entry`, `Summary`, and the spec suite
* Decisions made
    - PASS: no further plan changes required before Build
* Insights
    - No existing test asserts category or collection `llms-full.txt` text, so unit 3's new heading test adds coverage without colliding with an existing example

## 2026-09-24 - QA - COMPLETE (PASS)

* Work completed
    - Reviewed the build commit against the implementation plan and project brief; re-ran `bundle exec rspec` (132 examples, 0 failures, 100% line coverage) and `bundle exec rubocop` (no offenses)
    - Wrote `memory-bank/active/.qa-validation-status` with findings and three non-blocking advisories
* Decisions made
    - PASS: implementation acceptable as-is; advisories (PATHNAME-only flag spelling vs plan, unpinned glob variants, `Scope#root?` predicate) do not block acceptance
* Insights
    - `File::FNM_PATHNAME` alone agrees with `FNM_EXTGLOB | FNM_PATHNAME` on every brief-relevant glob/path pair, so the flag-spelling deviation is behaviorally inert

## 2026-09-24 - REFLECT - COMPLETE

* Work completed
    - Wrote `memory-bank/active/reflection/reflection-exclude-globs-corpus-headings.md`
* Decisions made
    - systemPatterns and techContext stay as they are: the glob rule is now in the README and product context
* Insights
    - A one-newline chomp looks correct until a body ends in two newlines


