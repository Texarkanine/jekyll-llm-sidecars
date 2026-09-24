# Progress

Warn and skip when a sidecar destination already exists. Write this plugin's files in binary mode. Leave include and exclude path matching unchanged until the creative result is decided.

**Complexity:** Level 1

## 2026-09-24 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Classified the write-hook fixes as Level 1
    - Held include and exclude path changes out of this task
* Decisions made
    - A sidecar whose destination file already exists is not written
    - Plugin destination writes use binary mode
* Insights
    - Matching a page against both its source path and its URL can exclude it for one identity and include it for the other, and there is no author-facing rule for that split

## 2026-09-24 - BUILD - COMPLETE

* Work completed
    - Existing sidecar destinations are kept, with a warning
    - Plugin destination files are written in binary mode
    - Full RSpec suite and RuboCop passed
* Decisions made
    - A path ending in `.md` is the sidecar check. Indexes and corpora still write when their destination exists
* Insights
    - The collision shows up after Jekyll's own write, so the check belongs in `Hooks.write`

## 2026-09-24 - BUILD - COMPLETE

* Work completed
    - QA found that `File.exist?` skipped the plugin's own previous sidecar
    - The skip now matches a Jekyll page, document, or static file destination
    - A later build rewrites a sidecar when the page does not occupy that path
    - 141 examples passed
* Decisions made
    - An existing plugin sidecar is not a collision. A destination Jekyll just wrote is.

## 2026-09-24 - QA - COMPLETE (FAIL)

* Work completed
    - Reviewed `Hooks.write` against the brief
    - Reproduced a stale sidecar on the second `jekyll build` into the same destination
* Decisions made
    - FAIL. Build must rerun. `File.exist?` is the wrong predicate
* Insights
    - `keep_destinations` removes plugin paths from Jekyll's obsolete list, so every sidecar still exists when `:site, :post_write` runs. Existence cannot tell a permalink collision from a file this plugin wrote on the last build
