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

## 2026-09-24 - BUILD - COMPLETE

* Work completed
    - `Body.render_liquid` uses `Liquid::Template.parse` and `render!` and does not touch `site.liquid_renderer`
    - Regression: a `:pre_render` fence rewrite appears in the HTML and the sidecar keeps the original fence with Liquid expanded
    - RSpec 143 examples, 0 failures. RuboCop clean
* Decisions made
    - Stay in the generate phase. Do not invalidate Jekyll's liquid cache and do not move the body snapshot to after `:pre_render`
* Insights
    - The failing HTML still showed `FENCE` until the path-keyed parse was removed. The sidecar expectation `T\n\nFENCE\n` held on both sides of the fix

## 2026-09-24 - QA - COMPLETE (FAIL)

* Work completed
    - Semantic review of `body.rb` and `body_spec.rb` against the brief; re-ran RSpec (143 examples, 0 failures, 100% coverage) and RuboCop (clean)
    - Confirmed parity with Jekyll's `render_liquid` on parse options, payload, and registers by reading the installed Jekyll 4.4.1 source
* Decisions made
    - FAIL on one documentation finding: `systemPatterns.md` still claims the body slot calls `Jekyll::Renderer#render_liquid`; Build must rerun for that one-line fix
    - Three advisories accepted as-is: dropped Liquid warning logs, raw (unformatted) error re-raise, sidecar renders absent from `--profile` stats
* Insights
    - The implementation itself is minimal and correct; the only gap is the memory bank describing the mechanism this task replaced

## 2026-09-24 - BUILD - COMPLETE

* Work completed
    - Replaced the stale sentence in `memory-bank/systemPatterns.md`: the body slot calls `Liquid::Template.parse` and `render!` and does not use `site.liquid_renderer`
* Decisions made
    - Documentation only. No code change. The three QA advisories stay as they are
* Insights
    - The persistent pattern file is what a later reader uses to find the render path, so the old `Renderer#render_liquid` sentence was the blocking miss

## 2026-09-24 - QA - COMPLETE (PASS)

* Work completed
    - Re-reviewed `body.rb`, `body_spec.rb`, and `systemPatterns.md` against the brief; re-ran RSpec (143 examples, 0 failures, 100% coverage) and RuboCop (clean)
    - Independently re-confirmed parity between `Body.render_liquid` and Jekyll's `render_liquid` by reading `renderer.rb` and `liquid_renderer/file.rb` in the installed Jekyll 4.4.1 gem
* Decisions made
    - PASS. The round-1 documentation blocker is resolved; the three advisories (dropped warnings, unformatted error re-raise, sidecar renders absent from `--profile`) stand as accepted trade-offs with no further action
* Insights
    - `Liquid::Template.parse(content, line_numbers: true).render!(payload, info)` is exactly Jekyll's own parse/render call minus the `@renderer.cache[@filename] ||=` memoization, which is the one line this task needed to remove
