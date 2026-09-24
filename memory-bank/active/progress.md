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

