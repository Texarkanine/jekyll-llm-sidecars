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

## 2026-10-21 - PLAN - COMPLETE

* Work completed
    - Wrote the Level 2 plan for task `sidecar-preamble`.
* Decisions made
    - Sidecar H1 uses the same title string as the index. Posts add `YYYY-MM-DD`, and ` - author` when the author is a non-blank string.
    - Subtitle is omitted. It is not a predefined Jekyll variable, and Minima and the official post-layout tutorial do not render it.
    - Categories, tags, description, and the devblog category article stay off the sidecar.
    - The preamble is concatenated in `Generator#render_row` for sidecar rows. `Body.call` and the corpus stay on the source body.
* Insights
    - `llms-full.txt` already prefixes each page with an H2 of its title. Putting the new H1 into the body slot would print the title twice.

## 2026-10-21 - PLAN - COMPLETE

* Work completed
    - Revised the plan after preflight `FAIL (fixable)`.
* Decisions made
    - The offset-date example sets `timezone: America/Chicago` and expects the meta date to equal Liquid's `date: "%Y-%m-%d"` (`2020-01-02`). `strftime` runs on the Time Jekyll stored. `ENV["TZ"]` is restored in an `ensure`.
    - Blank author and non-string author are separate examples. No empty-name branch.
    - Docs step also updates the README sidecar table cell and the product-context constraints bullet. The built pink-margarine sidecar is `_site/2026/03/01/pink-margarine.md`.
    - Acceptance criterion 2 now says a `subtitle` is not added, and the README records why.
* Insights
    - Jekyll 4.4.1 `Utils.parse_date` is `Time.parse(input).localtime`. On UTC CI, `2020-01-02 23:00:00 -0500` is stored as `2020-01-03`. Lintel's noon `-0500` timestamp stays `2026-10-20`.

## 2026-10-21 - PREFLIGHT - COMPLETE

* Work completed
    - Ran the Level 2 preflight. The first line of `.preflight-status` is `FAIL (fixable)`.
* Decisions made
    - The offset-date behavior and the challenges bullet have to change before build. `strftime` on the Time Jekyll stored matches Liquid's civil day. It does not keep a `-0500` evening on the authored calendar day once `Utils.parse_date` has called `localtime`.
* Insights
    - Under `TZ=UTC`, Jekyll 4.4.1 stores `2020-01-02 23:00:00 -0500` as `2020-01-03 04:00:00 +0000`. CI and the devblog deploy both build on GitHub Actions, which is UTC. The filename-date example and the lintel noon timestamp stay on their calendar days.
