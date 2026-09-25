# Project Brief

## User Story

As a Jekyll site author who uses plugins that rewrite document content in `:pre_render`, I want the Markdown sidecar to expand Liquid without storing that parse in Jekyll's document-path template cache, so that those plugins still see the content they rewrote when the page renders.

## Use-Case(s)

### A plugin rewrites content before render

A document contains Liquid and a fence. During `generate`, the sidecar expands the Liquid and keeps the fence. A `:pre_render` hook then rewrites the fence in `document.content`. The HTML page contains the rewrite. The `.md` sidecar still contains the fence.

### Discovery

This showed up with `jekyll-mermaid-prebuild`, which rewrites Mermaid fences in `:pre_render`. The sidecar gem has no Mermaid behavior. The failure is that the sidecar parses the document through `site.liquid_renderer.file(item.path)` early enough to cache the first body, so later plugins that follow Jekyll's render lifecycle are wrong. Documents with no Liquid tags are unaffected, because Jekyll does not consult that cache for them.

## Requirements

1. Liquid-render the sidecar body with `Liquid::Template.parse` and `render!`, using the payload and registers `Body` already builds.
2. Do not call `site.liquid_renderer.file(item.path).parse`.
3. Keep that work in the generate phase, before `:pre_render`. The sidecar stays source Markdown with Liquid expanded and the fence intact.
4. Do not move `Body.call` to after the rewrite hook. Do not invalidate `site.liquid_renderer.cache`. Do not change Mermaid-prebuild.

## Constraints

1. This gem does not treat Mermaid fences specially. The regression simulates the same lifecycle point: a `:pre_render` hook that rewrites document content.
2. The fixture needs both a Liquid tag and a fence, because the cache is only consulted when Liquid runs.

## Acceptance Criteria

1. A regression example has a Liquid tag and a fence, and a `:pre_render` hook rewrites the fence.
2. The HTML output contains the rewrite.
3. The sidecar body still contains the fence, with Liquid expanded.
