# Project Brief

## User Story

As a maintainer of a Jekyll site, I want exclude globs and scope corpora to match what the configuration asks for, so `llms.txt` and `llms-full.txt` are the documents a reader expects.

## Use-Case(s)

### Exclude the trees the config names

A glob such as `/tags/**/*` or `/error/**/*` excludes that directory, its index, and everything under it.

### Headings on tag and category corpora

Each document in a tag or category `llms-full.txt` keeps its own title as an H1. There is no scope H1, and a document title is not demoted to an H2.

## Requirements

1. `/**` in an exclude glob matches the directory itself, its index, and nested paths.
2. Each document in a tag or category `llms-full.txt` is introduced by an H1 of that document's title.
3. Documents in every `llms-full.txt` are separated by exactly two newlines.
4. The root `llms-full.txt` stays the joined sidecar bodies, with no added heading.

## Constraints

1. Site configuration is not part of this change.
2. Follow TDD for the new matching and corpus text.

## Acceptance Criteria

1. `/tags/`, `/tags/index.html`, `/tags/bitcoin/`, and `/error/404.html` match the globs the blog uses.
2. A category or custom-scope corpus uses `# {document title}` for each document, with that document's existing headings left as they are.
3. Adjacent documents are separated by exactly two newlines, including in the root corpus.
