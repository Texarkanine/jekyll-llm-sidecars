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
