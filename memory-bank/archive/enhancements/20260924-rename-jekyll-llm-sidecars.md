---
task_id: rename-jekyll-llm-sidecars
complexity_level: 2
date: 2026-09-24
status: completed
---

# TASK ARCHIVE: Rename Gem to jekyll-llm-sidecars

## SUMMARY

Renamed the gem from `jekyll-llms-txt` to `jekyll-llm-sidecars`: gem name, require path, `lib/jekyll-llm-sidecars/`, module `JekyllLlmSidecars`, and the `_config.yml` block key `llm_sidecars:`. RubyGems rejects the old name because its typo check strips `-`/`_` and matches the protected gem `jekyll-llmstxt` (protected until 2029-12). Output files and `llms: false` did not change. QA passed.

## REQUIREMENTS

- Clean-break rename of the gem, files, module, and config block. Nothing was published, so nothing stays compatible.
- `Configuration#llms_txt` and the inner key `create_llms_txt` keep their names. They name the `llms.txt` artifact.
- Output files stay `llms.txt`, `llms-full.txt`, and `*.md` sidecars. Front matter `llms: false` stays.
- GitHub URLs point at `Texarkanine/jekyll-llm-sidecars`. The operator renames the repository.
- The rewritten README (sibling layout, codecov badge, no RubyGems badge yet) shipped with this work.
- `../devblog` is out of scope. The operator updates it.

## IMPLEMENTATION

Specs were retargeted first and run red (`LoadError` on `require "jekyll-llm-sidecars"`), then the files moved with `git mv` and references renamed. The site ivar `@llms_txt` became `@llm_sidecars`. An existing example now asserts that a lone `llms_txt:` block is ignored. `version_spec.rb` expects `jekyll/llm_sidecars` to raise `LoadError`.

`Gemfile.lock`, `config/mutant.yml`, `.rubocop.yml`, both workflows, and `release-please-config.json` use the new name. README, CONTRIBUTING, `systemPatterns.md`, and `techContext.md` do too.

One change outside the rename: `::Jekyll::Utils.slugify` became `Jekyll::Utils.slugify` in `ScopeBuilder#category_prefix`. Mutant showed the leading `::` alive. It was an equivalent lookup left by the earlier module flattening. `scoped_paths` in `spec/scope_spec.rb` was split onto two lines because the longer module name exceeded 120 columns.

## TESTING

RSpec: 133 examples, 0 failures, 100% line coverage. RuboCop: 27 files, no offenses. `gem build` produced `jekyll-llm-sidecars-0.1.0.gem` with only the new paths. Mutant: 2569/2569 kills, 0 alive. QA passed with advisories only (the dropped `::`, the silent old config key, a pre-existing `homepage_uri` warning). A hidden-file search for the old names found only `create_llms_txt` and the old-key spec.

## LESSONS LEARNED

- RubyGems `GemTypo` uppercases a name and strips `-`/`_`. Check that before the first build of a new gem. A match with 10,000 downloads or a release within five years blocks the name.
- `rg` skips dotfiles unless `--hidden` is set. A `--hidden` sweep of this repo must exclude `.mutant/`, or the Mutant cache floods the output.
- After a namespace change, run the full Mutant suite. The alive `::` spelling was not in a file this task meant to change.

## PROCESS IMPROVEMENTS

Nothing further. The plan's sequence held, and its two named risks (over-replacing `llms_txt`, a stale `Gemfile.lock`) were the ones that needed care.

## TECHNICAL IMPROVEMENTS

Nothing in the code. The useful change is upstream: pick the gem name after the RubyGems check, then derive the module and config key from it, as the siblings do.

## NEXT STEPS

- Operator updates `../devblog`: Gemfile gem name, `_config.yaml` block key `llm_sidecars:`, and `JekyllLlmSidecars` in `_plugins/20_llms_scope_builders.rb`.
- Operator renames the GitHub repository, then `git remote set-url origin`.
- Before the first release: `HELPER_APP_ID`, `HELPER_APP_PRIVATE_KEY`, `CODECOV_TOKEN`, the `rubygems.org` environment, a Codecov repo, and a pending trusted publisher for `jekyll-llm-sidecars`. Add the RubyGems badge to the README after the gem is published.
