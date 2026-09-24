# Project Brief

## User Story

As a site owner using this plugin, I want date sorting, empty categories, and extensionless sidecar URLs to build correctly, and any leftover old project names updated, so the build does not crash and the published name is `jekyll-llm-sidecars`.

## Use-Case(s)

### Use-Case 1

A build that includes both a post (`Time` date) and a jekyll-archives year, month, or day page (`Date` date) writes `llms.txt` instead of raising `NoMethodError` during sort.

### Use-Case 2

With `include_categories: true`, a page whose front matter has a present nil `categories` key still produces category scopes.

### Use-Case 3

A Markdown page whose URL has no extension and no trailing slash gets a `.md` sidecar path, and the index and alternate link use that path.

### Use-Case 4

Any remaining reference that still uses the old project name is updated to `jekyll-llm-sidecars`. The checkout directory stays `jekyll-llms-txt`.

## Requirements

1. Normalize entry dates to `Time` before comparing them in scope sort.
2. Treat a missing or nil `categories` value as an empty list when building category scopes.
3. Append `.md` when a sidecar URL has no extension. Keep the trailing-slash `index.md` behavior.
4. Where an inaccurate old name was missed, rename it to `jekyll-llm-sidecars`.

## Constraints

1. Do not move or rename the checkout directory on disk.
2. Most of the rename already happened in another thread. Change a name only when it is still inaccurate.
3. The three fixes are the review findings on pull request 1, discussion comments 4097834519, 4097834528, and 4097834533.

## Acceptance Criteria

1. Sorting a `Date` against a `Time` does not raise, and newer dates still sort first, then by relative path.
2. A nil `categories` value does not raise while category scopes are built, and real category names still produce scopes.
3. An extensionless URL such as `/about` becomes a sidecar path ending in `.md`. A trailing-slash URL still becomes `index.md`.
4. A search of the checkout finds no leftover old project name except the directory path itself.
