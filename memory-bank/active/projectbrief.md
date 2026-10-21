# Project Brief

## User Story

As a reader of a Jekyll site, I want the Markdown sidecar to keep the heading-like lines that introduce the HTML page, so that flipping from the HTML to the sidecar does not drop the title or other crucial introducing lines.

## Use-Case(s)

### Use-Case 1

A reader opens a post's HTML page on a vanilla Jekyll site with a run-of-the-mill theme, sees the title, the date, and on some posts a subtitle, then opens the Markdown sidecar and still sees those introducing lines. The title is an H1.

### Use-Case 2

The same reader opens a page that has no subtitle. The sidecar still has the title. Nothing is invented to fill a subtitle that the page does not have.

## Requirements

1. The Markdown sidecar includes the document title as an H1. Omitting the title is out of scope for a "minimal" sidecar.
2. Recommend, then apply, a treatment for the other heading-like introducing lines a run-of-the-mill theme shows: the subtitle when the page has one, and lines such as the date and the "a fable by niko" line on the lintel post. Markdown has no subtitle construct, so the subtitle format is part of that recommendation. Omitting a subtitle can be defended. Omitting the title cannot.
3. The guiding test is surprise: a person who saw the HTML introduction should not find those lines gone in the sidecar.
4. Stock Jekyll fields win over theme-only inventions. Expose a subtitle when it is a stock field.
5. Prove the change with the gem's unit tests and with a real `bundle exec jekyll build` of the devblog after its gem spec points at this gem on disk.
6. When the work is done, open a non-draft pull request.

## Constraints

1. Sidecars stay Markdown for language models and other agents. This change adds introducing lines. It does not turn the sidecar into a conversion of the rendered HTML.
2. The devblog Gemfile path change is a local validation setup. It is not a change to publish from the devblog repository unless that repository's own workflow requires it.
3. Validation uses both unit tests and a real devblog build.

## Acceptance Criteria

1. A sidecar for a document with a title begins with an H1 of that title.
2. A sidecar for a document with a `subtitle` does not add that subtitle. The README records why: it is not a predefined Jekyll field, and a run-of-the-mill post header does not show it.
3. Other heading-like introducing lines that a run-of-the-mill theme shows are either present, or their omission is an explicit recommendation recorded with the work.
4. The lintel post, built through the devblog with this gem on disk, no longer opens the sidecar on the first body paragraph with the title absent.
5. The gem's unit tests cover the new sidecar text.
6. A non-draft pull request is open for the change.
