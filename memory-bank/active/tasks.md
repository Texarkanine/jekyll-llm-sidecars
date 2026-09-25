# Tasks

## sidecar-liquid-cache

- [x] Render the sidecar body with `Liquid::Template.parse` and `render!`, not `site.liquid_renderer.file`
- [x] Regression: Liquid plus a fence, `:pre_render` rewrites the fence, HTML shows the rewrite, sidecar keeps the fence

`JekyllLlmSidecars::Body` parsed the document through `Jekyll::Renderer#render_liquid`, which stores the first parse in `site.liquid_renderer.cache` under the document path. A later `:pre_render` rewrite of `document.content` never reached the HTML render for documents that contain Liquid.

`Body.render_liquid` now calls `Liquid::Template.parse` and `render!` with the same payload and registers. The generate-phase snapshot is unchanged, so the sidecar stays source Markdown with Liquid expanded.

Files: `lib/jekyll-llm-sidecars/body.rb`, `spec/body_spec.rb`.

## QA Result: FAIL

- [x] Blocking: `memory-bank/systemPatterns.md` now says the body slot calls `Liquid::Template.parse` and `render!` and does not use `site.liquid_renderer`
- Advisory: Liquid parse warnings no longer logged; Liquid errors raise without Jekyll's path-formatted log line; `--profile` stats skip sidecar renders

Code, tests (143 examples, 0 failures), and RuboCop verified clean. Full findings in `.qa-validation-status`.
