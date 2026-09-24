---
task_id: fix-review-crashes
date: 2026-09-24
complexity_level: 2
---

# Reflection: fix review crashes and missed names

## Summary

Three review crashes are fixed, and the leftover-name search found nothing inaccurate to rename. The suite passed and QA passed.

## Requirements vs Outcome

Date sort, nil categories, and extensionless sidecar URLs behave as the brief asked. The README now lists `/about` → `/about.md`. No gem or module rename was needed. Archives, coverage, `create_llms_txt`, and the checkout directory were left alone, matching the operator's confirmation.

## Plan Accuracy

The sequence and files held. `permalink: /about` is the URL `/about` on Jekyll 4.4.1, so the double fallback was unused. The equal-instant example used `date.to_time`, and the tie held. The mixed nil-category example failed in `uniq.sort`, and the nil-only example failed on `include?`, which is what the red runs showed.

## Build & QA Observations

Each new example failed for the planned reason, then passed after the one-line change. The full suite was 138 examples, RuboCop was clean, and the gem built. QA passed without changing the implementation.

## Insights

### Technical

- `Date <=> Time` is nil on this Ruby, so a sort that calls `zero?` on the comparison has to coerce both sides to `Time` first. `Hash#fetch`'s default does not run when the key is present and nil; `Array` does.

### Process

- Nothing notable

### Million-Dollar Question

The boundary coercions are the fit. Jekyll posts and jekyll-archives date pages will keep different date classes, and front matter will keep storing nil. Converting at `entry_time`, `category_names`, and `sidecar_path` is the small place those differences should die.
