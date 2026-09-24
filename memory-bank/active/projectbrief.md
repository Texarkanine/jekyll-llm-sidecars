# Project Brief

## User Story

As a maintainer of this plugin, I want every finding in `.slobac/2026-09-23T19-16-57/audit.md` fixed so the suite asserts the behaviors it names.

## Use-Case(s)

### Fix the audited smells

Apply the prescribed remediation for each of the 15 findings in that audit. The audit is the requirements document.

## Requirements

1. Fix all 15 findings using that report's prescribed remediations and gates.
2. Where one finding supersedes another, follow the later instruction: delete the weaker alternate-link test instead of strengthening it, and move the eight Body Liquid examples into `spec/body_spec.rb` while applying the rendered-value assertions.
3. Leave items under "Tests considered but not flagged" as they are, including the `NoMethodError` pin the report only marks for a human look.

## Constraints

1. Product behavior stays the same. Changes stay in the spec suite unless a prescribed remediation needs a single project-level test helper.
2. The mutation kill-set must not shrink.
3. The shared-state fix must keep the suite green under shuffled example order.

## Acceptance Criteria

1. Each of the 15 findings is addressed as the audit prescribes.
2. `bundle exec rspec` passes, including under several shuffled seeds.
3. `bundle exec mutant run` still kills every mutant it killed before this work.
