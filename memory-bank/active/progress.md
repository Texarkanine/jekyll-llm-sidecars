# Progress

Markdown sidecars drop the introducing lines a reader sees on the HTML page. The title must appear as an H1. Subtitle and the other heading-like lines need a recommendation, then an implementation, proved by unit tests and a devblog build against this gem on disk, then a non-draft pull request.

**Complexity:** Level 2

## 2026-10-21 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Restated the request against the live lintel sidecar and the lintel post source. The operator approved the restatement.
    - Classified the work as Level 2.
* Decisions made
    - Level 2, not Level 1. The published contract today is "source body, front matter removed," so this is a change to that contract, not a crash in one component.
    - Level 2, not Level 3. One subsystem composes the sidecar text. Choosing which introducing lines to keep is planning, not a new feature across multiple subsystems.
* Insights
    - The lintel HTML line "a fable by niko" is not a `subtitle` field. The post's front matter has `title`, `date`, `description`, `author`, and `tags`. `subtitle` appears on other posts and in the post layout.
