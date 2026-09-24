# Project Brief

## User Story

As a maintainer of a Jekyll site, I want exclude globs and scope corpora to match what the configuration asks for, so `llms.txt` and `llms-full.txt` are the documents a reader expects.

## Use-Case(s)

### Exclude the trees the config names

A glob such as `/tags/**/*` or `/error/**/*` excludes that directory, its index, and everything under it.

### Headings on tag and category corpora

A tag or category `llms-full.txt` opens with an H1 of the scope name, then an H2 of each document title before that document's body.

## Requirements

1. `/**` in an exclude glob matches the directory itself, its index, and nested paths.
2. Tag and category `llms-full.txt` files include the scope H1 and a per-document H2.
3. The root `llms-full.txt` stays the joined sidecar bodies, with no added heading.

## Constraints

1. Site configuration is not part of this change.
2. Follow TDD for the new matching and corpus text.

## Acceptance Criteria

1. `/tags/`, `/tags/index.html`, `/tags/bitcoin/`, and `/error/404.html` match the globs the blog uses.
2. A category or custom-scope corpus starts with `# {scope title}` and `## {document title}` before each body.
3. Existing root corpus join tests still pass.
