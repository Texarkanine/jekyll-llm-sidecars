# Active Context

## Current Task: sidecar-liquid-cache
**Phase:** BUILD - COMPLETE

## What Was Done
- `Body` Liquid-renders with `Liquid::Template.parse` and `render!`. It no longer calls `site.liquid_renderer.file`.
- A regression registers a `:pre_render` hook that rewrites a fence. The HTML contains the rewrite. The sidecar body is `T\n\nFENCE\n`.
- Full RSpec suite: 143 examples, 0 failures. RuboCop: 27 files, no offenses.

## Next Step
- Level 1 QA.
