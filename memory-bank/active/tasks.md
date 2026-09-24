# Current Task: fix unbundled require in CI

**Complexity:** Level 1

## Build

- [x] Reproduce the CI failure by giving the child an empty gem home
- [x] Pass the parent `$LOAD_PATH` into that child without Bundler setup

What broke: `spec/version_spec.rb` started Ruby with `Bundler.with_unbundled_env` and `-Ilib` only. CI has Jekyll only inside the bundle, so `require "jekyll"` failed.

What changed: the child still runs outside Bundler, with an empty `GEM_HOME`, and receives the parent load path via `-I`. The script aborts if `Jekyll::LlmsTxt` is already defined.

Files: `spec/version_spec.rb`
