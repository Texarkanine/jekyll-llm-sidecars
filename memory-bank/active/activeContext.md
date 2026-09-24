# Active Context

- **Current Task:** rename-jekyll-llm-sidecars
- **Phase:** REFLECT - COMPLETE
- **What Was Done:**
    - Moved `/home/mobaxterm/git/jekyll-llms-txt/lib/jekyll-llms-txt.rb` → `lib/jekyll-llm-sidecars.rb`, `lib/jekyll-llms-txt/` → `lib/jekyll-llm-sidecars/`, `jekyll-llms-txt.gemspec` → `jekyll-llm-sidecars.gemspec`.
    - Renamed `JekyllLlmsTxt` → `JekyllLlmSidecars` in every lib file (module lines, `scope_builders`, `current_destinations`, hook registrations) and every spec.
    - `Configuration` reads `site.config["llm_sidecars"]`; site ivar `@llms_txt` → `@llm_sidecars` in `generator.rb` and `hooks.rb`.
    - Updated `Gemfile.lock`, `config/mutant.yml`, `.rubocop.yml`, `.github/workflows/release-please.yaml`, `.github/workflows/update-gemfile-lock.yaml`, `release-please-config.json`, `README.md`, `CONTRIBUTING.md`, `memory-bank/systemPatterns.md`, `memory-bank/techContext.md`.
    - Specs: retargeted to the new names; the "different config key" example now asserts the old `llms_txt:` block is ignored; `version_spec.rb` checks `require "jekyll-llm-sidecars"` and that `jekyll/llm_sidecars` raises LoadError.
    - Verification: 133 examples pass, 100% line coverage; RuboCop clean; `gem build` produces `jekyll-llm-sidecars-0.1.0.gem` with the new file list; Mutant 2569/2569 kills.
- **Deviations:**
    - `lib/jekyll-llm-sidecars/scope_builder.rb`: `::Jekyll::Utils.slugify` → `Jekyll::Utils.slugify`. Mutant showed the leading `::` alive (equivalent constant lookup in the flat module). The survivor predates this task (introduced in `925b26d`, match-sibling-layout); CONTRIBUTING bucket A says simplify.
    - `spec/scope_spec.rb` `scoped_paths` helper split onto two lines because the longer module name exceeded the 120-column limit.
- **Next Step:** Operator runs `/niko-archive`. Operator also updates devblog to the new gem name, module, and `llm_sidecars:` block.
