# Current Task: fix unbundled require in CI

**Complexity:** Level 1

## Build

- [x] Reproduce the CI failure by giving the child an empty gem home
- [x] Pass the parent `$LOAD_PATH` into that child without Bundler setup

What broke: `spec/version_spec.rb` started Ruby with `Bundler.with_unbundled_env` and `-Ilib` only. CI has Jekyll only inside the bundle, so `require "jekyll"` failed.

What changed: the child still runs outside Bundler, with an empty `GEM_HOME`, and receives the parent load path via `-I`. The script aborts if `Jekyll::LlmsTxt` is already defined.

Files: `spec/version_spec.rb`

## QA

✅ PASS

- Completeness: both require-path examples remain; the child gets the parent `$LOAD_PATH` via `-I`, runs outside Bundler setup, and aborts if `Jekyll::LlmsTxt` is already defined. Empty `GEM_HOME` / `GEM_PATH` matches CI. Non-blocking: "push the change" is wrap-up, not a code gap.
- KISS / DRY / YAGNI: one helper, no extra abstractions, no speculative API. Empty gem home and the preload abort are required by the brief.
- Integrity (advisory): `Dir.mktmpdir` without a block leaves a temp dir per example. `spec_helper` already supplies a cleaned `@temp_dir`. Does not block acceptance.
- Regression / docs: same Open3 + `with_unbundled_env` shape; no product docs needed.
