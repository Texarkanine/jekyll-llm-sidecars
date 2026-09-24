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
