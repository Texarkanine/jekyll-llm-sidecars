# Progress

Stop the sidecar from parsing a document into Jekyll's path-keyed Liquid cache during `generate`, so a later `:pre_render` content rewrite still reaches the HTML page. The `.md` sidecar stays source Markdown with Liquid expanded.

**Complexity:** Level 1

## 2026-09-24 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Classified the sidecar Liquid-cache bug as Level 1
    - Recorded the brief: parse with `Liquid::Template` directly, keep the work in `generate`, and regress with a `:pre_render` rewrite rather than Mermaid itself
* Decisions made
    - Level 1. One component, `JekyllLlmSidecars::Body`, and the approach is already specified
* Insights
    - Mermaid-prebuild exposed the bug. The contract is to leave Jekyll's render cache alone so other `:pre_render` plugins keep working
