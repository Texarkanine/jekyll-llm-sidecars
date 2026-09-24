# Progress

Rename the gem `jekyll-llms-txt` to `jekyll-llm-sidecars` (gem, files, module `JekyllLlmSidecars`, config key `llm_sidecars`), because RubyGems rejects the old name as too similar to `jekyll-llmstxt`. Output files and `llms: false` stay. The pending README rewrite lands with this work. devblog is out of scope.

**Complexity:** Level 2

## 2026-09-24 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Intent clarified with the operator; complexity set to Level 2.
* Decisions made
    - Config block key becomes `llm_sidecars:`; inner keys unchanged.
    - Module becomes `JekyllLlmSidecars`.
    - devblog is not touched; the operator updates it during QA.
* Insights
    - RubyGems `GemTypo` compares names after removing `-`/`_`; `jekyll-llmstxt` is protected until 2029-12, so every separator variant of the old name fails.

## 2026-09-24 - PLAN - COMPLETE

* Work completed
    - Plan written to `tasks.md`: one executable rename step (specs first), one prose step (README, CONTRIBUTING, memory bank).
* Decisions made
    - `Configuration#llms_txt` and `create_llms_txt` keep their names; they name the llms.txt artifact.
    - The site ivar `@llms_txt` becomes `@llm_sidecars`.
    - Keep the no-nested-namespace spec, retargeted to `jekyll/llm_sidecars`; add an old-`llms_txt`-key-ignored example by retargeting the existing "different config key" case.

## 2026-09-24 - PREFLIGHT - COMPLETE

* Work completed
    - Preflight result: `PASS WITH ADVISORY`. No plan edits.
* Insights
    - Advisories: replace every lib `JekyllLlmsTxt` reference, not only the module declarations. Widen the final sweep regex to include `@llms_txt`, `` `llms_txt` ``, `Jekyll::LlmsTxt`, and `jekyll/llms_txt`. Record a SumMem note for the rename, because the older notes name the old identifiers.
    - Innovation (optional): warn when a legacy `llms_txt:` block is present without `llm_sidecars:`, so devblog does not fall back to defaults silently.
