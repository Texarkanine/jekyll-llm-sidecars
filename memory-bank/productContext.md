# Product Context

## Target Audience

People who publish sites with Jekyll and want those sites to also offer [llmstxt.org](https://llmstxt.org/) text for language models and other agents.

## Use Cases

- Publish a Markdown index at `/llms.txt`.
- Optionally publish a concatenated Markdown corpus at `/llms-full.txt`.
- Optionally publish the same index and corpus beside each category and each included collection.
- Publish a Markdown sidecar for each included Markdown-source page, and point HTML at that sidecar with an alternate link.
- Leave HTML-source pages linked at their original URLs. Include them in indexes and leave them out of `llms-full.txt`.
- Turn the plugin off for a single entry with front matter.
- Register extra scopes (tags, authors, custom archives) so those groupings get their own indexes.
- When [jekyll-archives](https://github.com/jekyll/jekyll-archives) is installed, follow its category permalink and slug mode. The plugin still works when that gem is absent.

## Key Benefits

A Jekyll site can offer LLM-oriented Markdown indexes, corpora, and source sidecars from the same build that produces the HTML site. Sidecars are the source body, with front matter removed, rather than a conversion of the rendered HTML.

## Success Criteria

Generated files and HTML alternate links match the output and configuration contract in `README.md`.

## Key Constraints

- Sidecars are source bodies. Liquid runs unless the entry sets `render_with_liquid: false`.
- A sidecar is not written when Jekyll has already written a page, a post, or a static file at that path. The existing file stays.
- `create_llms_txt`, `create_llms_full`, and `create_markdown` choose which artifacts are written. `include_categories`, `include_collections`, and registered scope builders choose which scopes exist.
- Default include list is pages and posts. Default exclude list is `/README.md`, `/CHANGELOG.md`, `/404.html`, and `/assets/**/*`. A site that sets `exclude_paths` replaces that list.
- The project is licensed under the GNU Affero General Public License, version 3 (`LICENSE`).
