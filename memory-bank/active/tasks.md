# Tasks

## sidecar-liquid-cache

- [ ] Render the sidecar body with `Liquid::Template.parse` and `render!`, not `site.liquid_renderer.file`
- [ ] Regression: Liquid plus a fence, `:pre_render` rewrites the fence, HTML shows the rewrite, sidecar keeps the fence
