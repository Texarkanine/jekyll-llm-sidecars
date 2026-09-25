# jekyll-llm-sidecars

[![code coverage](https://codecov.io/gh/Texarkanine/jekyll-llm-sidecars/graph/badge.svg)](https://codecov.io/gh/Texarkanine/jekyll-llm-sidecars)

Publish an [`llms.txt`](https://llmstxt.org/) index and Markdown copies of your pages when Jekyll builds your site.

## Why?

Language models read Markdown more easily than HTML pages full of navigation, styles, and scripts. The [llms.txt proposal](https://llmstxt.org/) gives them a Markdown index at the root of a site, with links to Markdown versions of its pages. This plugin makes those files from your Jekyll sources at build time, so they always match the site you publish.

## Features

- `/llms.txt`: an index of your posts and pages in the llms.txt format.
- Sidecars: a `.md` file next to each HTML page, with the Markdown source of that page.
- A `<link rel="alternate" type="text/markdown">` tag in each page's `<head>` that points to its sidecar.
- Optional `/llms-full.txt`: the text of all included pages in one file.
- Optional `llms.txt` and `llms-full.txt` files for each category and each collection. Category files follow [jekyll-archives](https://github.com/jekyll/jekyll-archives) permalinks when that plugin is configured.
- A Ruby hook to add your own groups, if you have custom collections outside the default & what `jekyll-archives` provides (i.e. tags, authors, etc).
- A front matter setting to leave out a page.

## Requirements

- Ruby 3.3 or later
- Jekyll 4

## Installation

Add the gem to your `Gemfile`:

```ruby
group :jekyll_plugins do
  gem "jekyll-llm-sidecars"
end
```

Run:

```bash
bundle install
```

Jekyll loads every gem in the `jekyll_plugins` group. If you do not use that group, also add `jekyll-llm-sidecars` to the `plugins` list in `_config.yml`.

## Usage

Build your site as usual. You do not need any configuration.

```bash
bundle exec jekyll build
```

Set `url` in `_config.yml`, because all links in the output are absolute URLs made from `url` and `baseurl`. The site `title` and `description` become the heading and summary of `/llms.txt`. For example, this `_config.yml`:

```yaml
title: Example Blog
description: Notes on things.
url: https://example.com
```

gives this `/llms.txt`:

```markdown
# Example Blog

> Notes on things.

## Posts

- [Second](https://example.com/meta/2024/06/01/second.md): Second post body.
- [Hello, World](https://example.com/meta/2024/05/01/hello-world.md): The first post.

## Pages

- [About](https://example.com/about.md)
- [Contact](https://example.com/contact.html)
```

`Hello, World` has a `description` in its front matter, so that text follows the link. `Second` has no description, so Jekyll's excerpt of the post follows the link. `Contact` is an HTML source file, so it has no sidecar and the link goes to its HTML page.

To leave a page out of all output, add this to its front matter:

```yaml
llms: false
```

## Output

The plugin writes these files into your built site:

| File | Default | Contents |
| --- | --- | --- |
| `/llms.txt` | On | Index of all included pages |
| Sidecars (`*.md`) | On | Markdown source of each included Markdown page |
| `/llms-full.txt` | Off | Text of all included Markdown pages in one file |
| `llms.txt` and `llms-full.txt` in each category or collection directory | Off | The same files, limited to that category or collection |

It also adds a `<link rel="alternate" type="text/markdown" href="...">` tag to each page that has a sidecar. The tag goes immediately before `</head>`.

### llms.txt

- The first line is an H1 with the site `title`. If there is no `title`, the line is only `#`.
- A blockquote with the site `description` follows. If there is no `description`, there is no blockquote.
- Each H2 section is one collection. The heading is the collection label with its first letter in uppercase, for example `Posts`, `Pages`, or `Garden`. `Posts` comes first, then `Pages`, then the other collections in alphanumeric order. A section with no entries does not appear.
- In each section, entries are in date order, newest first. Entries with the same date are in order of their source path.
- Each entry is `- [name](url): notes`.
  - `name` is the title that Jekyll stored for the page. Jekyll gives posts and collection documents a title from the filename when front matter has no title. A page without a title uses its filename, for example `about.md`.
  - `url` is the sidecar URL. For an HTML source file, it is the page URL.
  - `notes` is the page `description`. If there is no description, it is the excerpt that Jekyll made. If there is neither, the entry has no `: notes` part. Line breaks in notes become spaces, so each entry stays on one line.

The plugin does not change titles, write excerpts, or escape characters in link text.

### Sidecars

A sidecar is the source of a Markdown page, not a conversion of its HTML. The plugin removes the front matter and renders Liquid. To keep Liquid tags as written, set `render_with_liquid: false` in the page's front matter.

A source file is Markdown when its extension is in the site's `markdown_ext` list. Jekyll's default list is `markdown`, `mkdown`, `mkdn`, `mkd`, and `md`. HTML source files get no sidecar.

The sidecar URL is the page URL with its extension changed to `.md`:

- `/foo/bar/baz.html` becomes `/foo/bar/baz.md`.
- `/foo/bar/` is a directory index, so it becomes `/foo/bar/index.md`.
- `/about` has no extension, so it becomes `/about.md`.

If that path is already where Jekyll wrote a page, a post, or a static file, the plugin warns and leaves that file in place. The index lists that page at its own URL, and the page gets no alternate link. A sidecar from an earlier build is not one of those files, so the next build replaces it.

### llms-full.txt

`llms-full.txt` is a common extension, not part of the llms.txt proposal. This plugin writes the sidecar text of each included Markdown page, in the same order as `llms.txt`. HTML source files are not included. The plugin removes line breaks at the end of each page and puts one blank line between pages.

In the root file, pages have no headings added. In a category or collection file, each page starts with an H1 of its title.

### Category and Collection Files

A category file set has the category name as its H1 and `Category: <name>` as its blockquote. A collection file set has the collection label as its H1 and `Collection: <label>` as its blockquote.

Category files go in the category archive directory. If jekyll-archives sets `permalinks.category`, the plugin uses that template. If not, it uses `/category/:name/`, which is the jekyll-archives default. If jekyll-archives sets `slug_mode`, the plugin uses that mode to make `:name`. The plugin does not need jekyll-archives.

Collection files go in `/<label>/`.

## Configuration

These are the default settings. You only need to add the keys that you want to change.

```yaml
llm_sidecars:
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

| Key | Default | Effect |
| --- | --- | --- |
| `create_markdown` | `true` | Write sidecars, link `llms.txt` entries to them, and add the alternate link tags. |
| `create_llms_txt` | `true` | Write `llms.txt` at the site root and for each category or collection that is on. |
| `create_llms_full` | `false` | Write `llms-full.txt` at the site root and for each category or collection that is on. |
| `include_categories` | `false` | Make a file set for each category that has included pages. |
| `include_collections` | `false` | Make a file set in `/<label>/` for each collection in `include_paths` that Jekyll writes out, except `posts`. |
| `include_paths` | `[pages, posts]` | What to include: `pages`, `posts`, and labels of collections with `output: true`. |
| `exclude_paths` | See above | Glob patterns for pages to leave out. |

Each setting is independent. For example, `include_categories: true` with `create_llms_full: true` gives each category an `llms-full.txt`.

### Excluding Pages

The plugin compares each `exclude_paths` pattern with three paths of each page, and leaves the page out if any of them match:

- The page URL, for example `/notes/`.
- The source path from the site root, with a leading `/`, for example `/_posts/2024-05-01-hello-world.md`.
- The full source path on disk.

Patterns use Ruby's [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch) with `File::FNM_PATHNAME`. To leave out a directory and everything in it, use `/dir/**/*`. This pattern also matches the directory index URL `/dir/`. The shorter `/dir/**` does not match pages in subdirectories.

When you set `exclude_paths`, your list replaces the default list. Copy the default entries into your list if you still want them.

### Custom Scopes

A scope is one group of pages with its own `llms.txt` and `llms-full.txt`. You can add scopes from a plugin in your site's `_plugins` directory, for example for tags, authors, or other archives.

This example makes a scope for each tag, in the directories that jekyll-archives uses for tag pages:

```ruby
# _plugins/llms_tag_scopes.rb
JekyllLlmSidecars.register_scope_builder do |site, _config, entries|
  template = site.config.dig("jekyll-archives", "permalinks", "tag") || "/tags/:name/"
  site.tags.filter_map do |name, items|
    scoped = entries.select { |entry| items.include?(entry.item) }
    next if scoped.empty?

    JekyllLlmSidecars::Scope.new(
      path_prefix: template.sub(":name", Jekyll::Utils.slugify(name)),
      title: name,
      description: "Tag: #{name}",
      entries: scoped
    )
  end
end
```

With this plugin, `/tags/foo/llms.txt` lists all posts with the tag `foo`.

The block gets the site, the configuration, and the list of included entries. `entry.item` is the Jekyll page or document. The block returns a list of `JekyllLlmSidecars::Scope` objects. The plugin ignores `nil` values and scopes with no entries. `title` and `description` become the H1 and blockquote of that scope's `llms.txt`.

## Troubleshooting

### A Page Is Missing From llms.txt

Check these causes:

- The page has `llms: false` in its front matter.
- The page matches a pattern in `exclude_paths`. Remember the default list if you did not set your own.
- The page is in a collection that is not in `include_paths`.

### A Page Has No Alternate Link

The plugin adds the tag only to pages that have a sidecar, and only when the page output contains `</head>`. Check that:

- The page is a Markdown source file, not an HTML source file.
- The page uses a layout that has a `<head>` element.
- `create_markdown` is not `false`.

### Links Use the Wrong Host

Links are built from `url` and `baseurl` in `_config.yml`. Set `url` to the address of your published site. `jekyll serve` changes `url` to the local server address, so check the output of `jekyll build` for production links.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, tests, and guidelines.
