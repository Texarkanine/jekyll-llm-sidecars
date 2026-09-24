# Progress

Fix every finding in `.slobac/2026-09-23T19-16-57/audit.md` using that report's prescribed remediations and gates, honoring the superseding findings and leaving unflagged tests alone.

**Complexity:** Level 2

## 2026-09-23 - COMPLEXITY-ANALYSIS - COMPLETE

* Work completed
    - Confirmed the operator's intent: fix all 15 audited smells
    - Wrote the project brief from that confirmation
* Decisions made
    - Level 2, because the change is a self-contained enhancement of the spec suite and the audit already prescribes the remediations
* Insights
    - Finding 12 deletes the generator alternate-link example instead of strengthening it
    - Finding 15 moves the eight Body Liquid examples into `spec/body_spec.rb` and applies findings 4–7 there

## 2026-09-23 - PLAN - COMPLETE

* Work completed
    - Wrote the implementation plan in `memory-bank/active/tasks.md`
* Decisions made
    - No `lib/` change and no new gem
    - Replace the `@stats` read with a Liquid error that names the document path
    - Restore `scope_builders` with an `around` hook in `spec/scope_spec.rb`
    - Assert highlight class and text with string checks instead of Nokogiri
* Insights
    - Strengthened oracles should already be green if the product matches the audit; a red run means the oracle is wrong

## 2026-09-23 - PREFLIGHT - COMPLETE

* Work completed
    - Validated the Level 2 plan against the audit, the specs, Body/Hooks/scope_builders, and Jekyll 4.4.1 / Liquid 4.0.4
    - Wrote `memory-bank/active/.preflight-status`; first line is `FAIL (fixable)`
* Decisions made
    - Fail the gate: unit 3's path-in-message oracle and unit 6's `puts :hi` substring cannot pass with no lib/ change
    - Do not edit the plan; known fixes are `stats_table` includes `page.path`, and strip-tags for highlight text
* Insights
    - Jekyll logs `format_error(e, path)` then re-raises the Liquid error; `template_name` stays nil
    - `stats_table` already lists `marked.md` on the error path without `profile: true`
    - Highlight HTML splits `puts` and `:hi` across Rouge spans

## 2026-09-23 - PLAN - COMPLETE

* Work completed
    - Revised units 1, 3, and 6 in `memory-bank/active/tasks.md` from the preflight findings
* Decisions made
    - Attribute Liquid renders through `stats_table`, not the exception message
    - Assert highlight text only after stripping tags
    - Write the scope-builder `around` hook with `do`/`end`
* Insights
    - The brace form of `around` with `ensure` is a SyntaxError on this Ruby

## 2026-09-23 - PREFLIGHT - COMPLETE

* Work completed
    - Re-validated the revised Level 2 plan against the audit, the specs, Body/Hooks/scope_builders, and Jekyll 4.4.1 / Liquid 4.0.4
    - Wrote `memory-bank/active/.preflight-status`; first line is `PASS WITH ADVISORY`
* Decisions made
    - Pass the gate: unit 3's `stats_table` include of `page.path` and unit 6's strip-tags `puts :hi` both hold with no lib/ change
    - Do not edit the plan; the nested-path / fold-into-unit-2 idea is advisory
* Insights
    - `LiquidRenderer#file` records the normalized path on every call; `profile: true` is not required
    - After tag strip, the highlight sidecar text is `puts :hi\n`
    - On a root `marked.md`, `page.path` equals `page.name`, so the scheduled `stats_table` oracle would not kill a `item.path` → `item.name` mutant
