---
task_id: llms-txt-plugin
complexity_level: 3
date: 2026-09-23
status: completed
---

# TASK ARCHIVE: jekyll-llms-txt plugin

## SUMMARY

A Jekyll 4 plugin that publishes the LLM-friendly text in `README.md`: `/llms.txt`, optional `/llms-full.txt`, optional category and collection indexes, Markdown sidecars, and HTML alternate links. The first implementation passed its own suite and failed on real builds. The rework calls `Jekyll::Renderer#render_liquid`, writes destination files instead of `site.static_files`, walks `collection.docs`, and joins corpus bodies with one newline and no chomp. The second QA passed.

## REQUIREMENTS

- Generated files and alternate links match `README.md`. Config key is `llms-txt`. Per-entry opt-out is front matter `llms: false`. Each flag is independent.
- Namespace is `Jekyll::LlmsTxt`. Do not alias `Jekyll::Llms`.
- CI and tests follow the sibling gems, including Mutant. Specs observe public results. An ignore is allowed only after a structure check shows two mutants cannot be told apart. No `send` in specs.
- Do not edit the devblog `_config.yaml`. `cannot load such file -- jekyll/llms` is that site's plugin, not this gem.
- One `Entry` per document. Summary and body are slots filled at most once. `Entry.new` returns the entry already registered for that same document object. `Census.call` clears the table at the start of each build.

The original acceptance line that the devblog builds unchanged is still unmet. The rework accepted the stale `require "jekyll/llms"` in `../devblog/_plugins/20_llms_scope_builders.rb`. The rest of that file already calls `Jekyll::LlmsTxt`. No config-interface change was proposed.

## IMPLEMENTATION

One generator pass selects documents, registers one `Jekyll::LlmsTxt::Entry` each, groups those same objects into scopes, and builds one manifest row per output path. A second insert of a path fails. Writers read slots. They do not render again.

Creative options were a path cache, shared Entry slots, and parallel arrays. Shared Entry slots won: process-once is a property of the object, and a URL is a binding, not an identity. The note "census is the only constructor" did not survive. The operator locked `Entry.new` to return the registered object. That is what shipped.

Key files:

- `lib/jekyll/llms_txt/census.rb` — include list, exclude globs, `llms: false` via `item.data`. Collections are read through `docs`, or `[]` when the name is missing.
- `lib/jekyll/llms_txt/body.rb` — `Renderer.new(site, item).render_liquid` with `payload["page"]` set to `item.to_liquid` and Jekyll's `info` hash (`registers`, `strict_filters`, `strict_variables`). Converters and layouts do not run.
- `lib/jekyll/llms_txt/generator.rb` — stores path and content on `BuildState`, sets `Jekyll::LlmsTxt.current_destinations` to absolute dest paths. Corpus text is `map(&:body).join("\n")`.
- `lib/jekyll/llms_txt/hooks.rb` — `:site, :post_render` injects the alternate link, `:clean, :on_obsolete` removes this build's dest paths from the obsolete array, `:site, :post_write` writes with `FileUtils.mkdir_p` and `File.write`.
- `lib/jekyll/llms_txt/entry.rb`, `manifest.rb`, `scope.rb`, `scope_builder.rb`, `summary.rb`, `configuration.rb`.

`section_label` uses `item.is_a?(Jekyll::Page)`. Inside `module Jekyll`, the `Page`, `Utils`, `Renderer`, and `LlmsTxt` const nodes are one constant each. Those four are the Mutant ignores in `config/mutant.yml`.

Friction: the clean hook receives only the obsolete path array, so the keep list cannot live only on the site. `generate` replaces the module-level list before cleanup. A nil path on `Page#path` crashes `LiquidRenderer#normalize_path` before Liquid runs, because a nil filename matches `when theme_dir && regex`. `Convertible#render_with_liquid?` is false when the body has no Liquid construct, so a test that deletes `config["liquid"]` must include a tag or `Body.call` returns before it reads that key.

## TESTING

RSpec: 130 examples, 0 failures, line coverage 357/357. RuboCop: 27 files, no offenses. Mutant 0.17: 2505 mutations, 2505 kills, 0 alive, 0 timeouts.

The first QA failed on a green suite. Quiet fixtures never loaded `jekyll-sitemap`, never rendered `{% include %}` or `{% highlight %}`, and hid the `to_ary` deprecation. The rework specs cover those. The second QA, run as `/niko-qa`, repeated the three commands and built a scratch site with the real `jekyll-sitemap` gem, categories, a collection, highlight, include, and `relative_url`. `site.process` finished, `sitemap.xml` built, `site.static_files` stayed free of these files, and `generate` then `cleanup` without a later write left `llms.txt` in place.

`bundle exec jekyll build` in `../devblog` on branch `jekyll-llms-txt` still stops at plugin load: `cannot load such file -- jekyll/llms` from `_plugins/20_llms_scope_builders.rb:7`. `_config.yaml` was not edited.

Two QA advisories did not block. The nil-output hook example assigns `site.@llms_txt` directly. A notes line built from an excerpt that ends in a newline keeps a trailing space, and the suite expects that.

## LESSONS LEARNED

- A quiet spec site can sit at 100% mutation coverage while another plugin walking `site.static_files` still raises. A scratch site that loads `jekyll-sitemap` is a different oracle.
- `Site#process` renders after `generate`. A strict-Liquid error in that later render does not prove the sidecar `info` hash was strict. `Body.call` on a page whose body contains a tag is the observation that isolates the sidecar.
- `:clean, :on_obsolete` is given the obsolete path array and nothing else. The keep list has to be module state that `generate` replaces before cleanup.
- `[]` and `fetch` are the same only while the key is present. Deleting `config["liquid"]`, or setting `strict_variables` to false while the key exists, separates them. `item.data["llms"]` and `item["llms"]` differ when a page subclass overrides `[]`.

## PROCESS IMPROVEMENTS

Preflight that opens the hook call site caught the Unit 4 hole before build. The same reading, against `Renderer#render_liquid` and `Collection#docs`, is what the rework plan was built from. The devblog gate stops before a site write and does not exercise this gem. The scratch site with `jekyll-sitemap` is the check that does.

## TECHNICAL IMPROVEMENTS

None proposed. The optional consolidation of `site.@llms_txt` and `current_destinations` into one channel was left unused. The nil-output spec still assigns the instance variable directly. Both were recorded as advisories, not work.

## NEXT STEPS

Update `../devblog/_plugins/20_llms_scope_builders.rb` so it requires this gem instead of `jekyll/llms`. That change belongs in the devblog. Do not edit its `_config.yaml` to make the require succeed.
