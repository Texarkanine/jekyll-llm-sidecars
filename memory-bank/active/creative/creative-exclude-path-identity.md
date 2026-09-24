# Decision: Exclude Path Identity

## Context

`exclude_paths` is compared with three strings for every page: the served URL (`item.url`), the site-root source path (`/#{item.relative_path}`), and `item.path`. The third value is a relative path for a `Jekyll::Page` and an absolute disk path for a `Jekyll::Document`. A page is excluded if any candidate matches.

The decision is which identity a glob is allowed to name.

It matters because a permalink can put a page somewhere other than its source path. If one identity matches an exclude glob and the other does not, the page is both "in" and "out" depending on which path the author had in mind. Generated pages may have no source file, so a source-only rule cannot name them. The default globs (`/README.md`, `/CHANGELOG.md`, `/404.html`, `/assets/**/*`) name source files, not the URLs those files are served at.

Constraints:

- `include_paths` names collections (`pages`, `posts`, labels). It is not a path glob.
- A configured `exclude_paths` list replaces the defaults.
- Front matter `llms: false` already opts one entry out.
- This exploration does not change code.

## Options Evaluated

- **URL only**: Every glob is matched against `item.url` and nothing else.
- **Source path only**: Every glob is matched against the site-root source path and nothing else.
- **One identity per page**: A page with a source file is matched only against that source path. A generated page with no source file is matched only against its URL.
- **Any candidate (current)**: A glob may match the URL, the source path, or the disk path. The first hit excludes the page.

## Analysis

| Criterion | URL only | Source path only | One identity per page | Any candidate |
| --- | --- | --- | --- | --- |
| One page, one decision | Yes | Yes | Yes | No. Source and URL can disagree. |
| Default globs keep working | No. `/README.md` is not the served URL. | Yes | Yes, for files that have a source path | Yes, via the source candidate |
| Generated page with no source file | Yes, by URL | No | Yes, by URL | Only if `item.url` or a synthetic path matches |
| Exclude by the public permalink | Yes | No | No, for a real file | Sometimes |
| Absolute disk path in config | Gone | Gone | Gone | Present, and inconsistent between pages and documents |

Key insights:

- The split the author described is the current rule. Exclusion is "any candidate matches," so a glob written for `_posts` drops a post whose public URL is `/blog/hello/`, and a glob written for `/blog/` drops that same post whose file is `_posts/2024-01-01-hello.md`. Neither reading is more correct once both are consulted.
- `include_paths` does not create that split. It chooses collections. The split is inside `exclude_paths`.
- The absolute disk path is the candidate that does not belong in a shared config file. Page and document disagree on what `item.path` is.

## Decision

**Low-Confidence Result**: Two rules avoid the split, and they disagree about what a glob means.

The recommendation is **one identity per page**: match the site-root source path when the page has one, and match the URL only when it does not. A single page is never tested against both, so a radical permalink cannot be included under one path and excluded under the other. The default globs keep matching source files. A generated page can still be named by the URL it was given.

What that gives up: an author cannot exclude a real file by its public URL. `/blog/**` would not match a post that is merely served there.

**URL only** is the other defensible choice, if globs should mean "what the public site looks like." It forces the default list to be rewritten, and those URLs depend on permalink style, so `/README.md` stops being a stable default.

**Any candidate** stays the handy rule and keeps the corner: there is still no author-facing answer when the two paths disagree.

## Implementation Notes

- Do not change census matching until this choice is confirmed.
- If the recommendation is accepted, `candidate_paths` becomes one string, the README "Excluding Pages" section lists that one string, and the absolute `item.path` candidate goes away.
- The census specs that exclude via `about.path` and via `/about.md` would be rewritten to the chosen identity.
