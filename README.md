# jekyll-llms-txt

Jekyll plugin that produces various [LLM-friendly text versions of files](https://llmstxt.org/) alongside regular pages.

## Installation

Add to `Gemfile` and run `bundle install`
```ruby
group :jekyll_plugins do
  gem "jekyll-llms-txt"
end
```

Add to `_config` file:

```yaml
plugins:
  - jekyll-llms-txt
```


## Output

- `/llms.txt`: Markdown index of included entries, in the [llms.txt](https://llmstxt.org/) format. An H1 is the site or scope name. A blockquote is the description when that text is present. H2 headings group the file lists. Each item is `- [name](url)`, with optional `: notes`.
- `/llms-full.txt`: the sidecar body strings in entry order. Trailing newlines on each body are removed, and bodies are joined by exactly two newlines. The root file has no heading. A scope file starts each body with an H1 of that document's title. No `Source:` line or horizontal rule.
- Per-category and per-collection `llms.txt` / `llms-full.txt` beside those scopes (optional).
- `*.md` sidecars for included Markdown sources. The source extension is whatever the site lists in `markdown_ext`. Jekyll's default list is `markdown`, `mkdown`, `mkdn`, `mkd`, and `md`. A file URL keeps its directory and swaps the extension for `.md` (`/foo/bar/baz.html` becomes `/foo/bar/baz.md`). A URL that ends in `/` is that directory's index, so the sidecar is `index.md` (`/foo/bar/` becomes `/foo/bar/index.md`).
- HTML `<link rel="alternate" type="text/markdown" href="...">` inside `<head>`, pointing at sidecars. The position among other head tags is not fixed.

`name` in each list item is the title Jekyll stored for that page, when that title is present. Posts and collection documents already receive a titleized filename when front matter has none. A page with no title uses the filename Jekyll stored (`about.md` stays `about.md`). `notes` are the page `description` when it is present. When it is not, notes are the excerpt Jekyll generated, when that excerpt is present. When neither is present, notes are omitted. Newlines in notes become a single space, so the item stays on one line. The plugin does not invent a title or an excerpt, and it does not escape characters in the link text. Index links and alternate-link hrefs are absolute, built from the site `url` and `baseurl`.

H2 sections are the collections those entries belong to. The heading is the label with its first letter uppercased (`posts` becomes `Posts`, `pages` becomes `Pages`, `garden` becomes `Garden`). Sections appear as Posts, then Pages, then every other collection in alphanumeric order by label. A section with no entries is omitted. Inside a section, entries are ordered by date, newest first, and by relative path when the date is the same. `llms-full.txt` uses that same order, skipping HTML-source entries. A page-side shuffle or a tag list sorted by count is not copied.

A missing site `title` leaves the H1 empty. A missing site `description` omits the blockquote. A category scope uses the category name as its H1 and `Category: ` plus that name as its blockquote. A collection scope uses the collection label as its H1 and `Collection: ` plus that label as its blockquote. A custom scope uses the title and description the builder passed.

Sidecars are source bodies, not HTML-to-Markdown conversions. Front matter is removed. Liquid is rendered unless `render_with_liquid: false` is set. HTML-source entries stay linked by their original URLs. HTML-only entries appear in indexes but are omitted from `llms-full.txt`.

## Configuration

```yaml
llms_txt:
  create_markdown: true
  create_llms_txt: true
  create_llms_full: false
  include_categories: false
  include_collections: false
  include_paths:
    - pages
    - posts
  exclude_paths:
    - /README.md
    - /CHANGELOG.md
    - /404.html
    - /assets/**/*
```

- `create_markdown`: generate sidecars for Markdown sources, link `llms.txt` to those sidecars, and add HTML alternate links. Default: `true`.
- `create_llms_txt`: generate `llms.txt` at the site root and for each active scope. Default: `true`.
- `create_llms_full`: generate `llms-full.txt` at the site root and for each active scope. Default: `false`.
- `include_categories`: include a scope for each non-empty category after include/exclude filtering. Default: `false`.
- `include_collections`: include a scope under `/{label}/` for each included writeable collection (not `pages`/`posts`). Default: `false`.
- `include_paths`: `pages`, `posts`, and output collection names. Default: `[pages, posts]`.
- `exclude_paths`: URL, Markdown path, or source path globs. `**` matches a directory, its index, and everything under it. Default: `[/README.md, /CHANGELOG.md, /404.html, /assets/**/*]`.

Per-entry opt-out:

```yaml
llms: false
```

### Category Paths

Category files land under the category archive path. When [jekyll-archives](https://github.com/jekyll/jekyll-archives) configures `permalinks.category`, that template is used. Otherwise the default is `/category/:name/`, matching jekyll-archives' stock category permalink. When archives configures `slug_mode`, that mode is used when slugifying `:name`. The gem does not require jekyll-archives; it just plays nice with it if it is present.

### Custom Scopes

Sites can register additional scoped write targets (e.g. tags, authors, custom archives or aggregations).

For example, if you had "tags" on posts, and URLs like `/tags/foo/` that showed a list of all posts tagged with `foo`, you could register a scope builder like this:

```ruby
# _plugins/llms_tag_scopes.rb
Jekyll::LlmsTxt.register_scope_builder do |site, _config, entries|
  template = site.config.dig("jekyll-archives", "permalinks", "tag") || "/tags/:name/"
  site.tags.filter_map do |name, items|
    scoped = entries.select { |entry| items.include?(entry.item) }
    next if scoped.empty?

    Jekyll::LlmsTxt::Scope.new(
      path_prefix: template.sub(":name", Jekyll::Utils.slugify(name)),
      title: name,
      description: "Tag: #{name}",
      entries: scoped
    )
  end
end
```

Then, `/tags/foo/llms.txt` would show all the posts tagged with `foo`.
