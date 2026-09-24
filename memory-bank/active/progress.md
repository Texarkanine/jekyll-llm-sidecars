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


## 2026-09-24 - PREFLIGHT - COMPLETE (FAIL (fixable))

* Work completed
    - Verified the `File::FNM_EXTGLOB | File::FNM_PATHNAME` fix against the brief's own globs and against the codebase's default exclude glob, by direct `File.fnmatch?` probing
    - Ran `spec/census_spec.rb`'s default-include example against `HEAD` to confirm its current pass depends on `/assets/**` matching nested paths
    - Simulated the old vs. new root-corpus join for the existing 7-body example to check for a divergence
* Decisions made
    - FAIL (fixable): the plan needs an added step migrating `Configuration::DEFAULT_EXCLUDE` (and its README and spec mirrors) from `/assets/**` to `/assets/**/*`, plus a step updating the untouched existing root-corpus example
* Insights
    - `File::FNM_PATHNAME` makes `X/**` (no trailing `/*`) stop matching more than one path segment deep - only `X/**/*` recurses fully. The shipped default exclude uses the old spelling

