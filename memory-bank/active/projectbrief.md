# Project Brief

## User Story

As a site author, I want a sidecar write to leave an existing destination file alone, and I want generated Markdown files to keep their newlines on Windows, so that a build does not replace a page or rewrite line endings.

## Use-Case(s)

### Use-Case 1

A Markdown page whose permalink is already `/about.md` is rendered by Jekyll to that same path. The plugin warns and does not replace that file with the sidecar body.

### Use-Case 2

Sidecars, `llms.txt`, and `llms-full.txt` are written with binary mode so Windows does not translate newlines.

## Requirements

1. If a sidecar destination already exists, warn and do not write that sidecar.
2. Write this plugin's destination files with `mode: "wb"`.
3. Do not change `exclude_paths` or `include_paths` matching in this task. That decision is the creative exploration in `memory-bank/active/creative/creative-exclude-path-identity.md`.

## Constraints

1. The sidecar URL rule stays "the page URL with its extension changed to `.md`".
2. Indexes and corpora are still written when their destination is free. The existence check applies to sidecars.

## Acceptance Criteria

1. A page written at the sidecar path keeps its rendered output, and the build logs a warning.
2. The plugin's `File.write` calls pass `mode: "wb"`.
3. Census exclude matching is unchanged.
