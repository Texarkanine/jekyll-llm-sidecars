# System Patterns

## How This System Works

`README.md` is the output contract. One generator pass selects documents, registers one `JekyllLlmsTxt::Entry` per document, and fills that entry's summary slot and body slot at most once. Scopes and the manifest hold those entry objects.

`Entry.new` returns the entry already registered for that document object. `Census.call` clears the table at the start of each build, so a later build does not keep the previous entry. A second `Entry.new` for the same object does not install new computers.

The body slot calls `Jekyll::Renderer#render_liquid`. The Markdown converter and the layout do not run.

Generated files are destination output. `Generator#generate` stores each path and its content, and sets `JekyllLlmsTxt.current_destinations` to the absolute destination paths. Those files are not members of `site.static_files`. Jekyll cleans the destination before it writes, and the clean hook receives only the obsolete path list, so the hook removes `current_destinations` from that list. `:site, :post_write` then writes the stored files. A path omitted from the list is left for the cleaner to delete.

## Destination Files

Anything that walks `site.static_files` must not see these files. They have no source URL. Putting them back on that list is what made `jekyll-sitemap` raise.

## Entry Identity

The intern table compares documents by object identity. A URL is a binding, not an identity: one document can appear in the root index, a category, a collection, and a custom scope, and each of those lists the same entry.
