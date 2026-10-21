# Task: Sidecar introducing headings

* Task ID: sidecar-preamble
* Complexity: Level 2
* Type: simple enhancement

Markdown sidecars gain the introducing lines a vanilla Jekyll post layout shows. The title is an H1 on every sidecar. A post also gets its date, and its author when that value is a non-blank string. `subtitle` stays off the sidecar: it is not a predefined Jekyll variable, and neither Minima nor Jekyll's own post-layout tutorial renders it. Categories, tags, description, and the devblog's "a fable" article stay off for the same reason: a run-of-the-mill header does not introduce the page with them.

## Recommendation

Stock introducing lines, from Jekyll's predefined front matter and the post layout in the official blogging tutorial (`h1` title, then `date - author`):

- **Title.** H1, every sidecar. The text is `Summary.line(item).name` (front matter title, otherwise the filename the index already uses). An empty name is a bare `#`, matching an empty site title on `llms.txt`.
- **Date.** Posts only. One line, `YYYY-MM-DD`, from `item.data["date"]` after Jekyll has read the post (filename date counts). Format with `strftime` on that value so a `-0500` evening stays on that calendar day.
- **Author.** Posts only, and only when `item.data["author"]` is a string that contains a non-whitespace character. The line is `YYYY-MM-DD - author`. No author: the date alone. Author is not read from site config.
- **Subtitle.** Omit. Not predefined ([Jekyll front matter](https://jekyllrb.com/docs/front-matter/)). Minima and the tutorial layout do not render it. The devblog does, from its own layout. Omitting it is the defensible choice. A later addition would be a plain paragraph under the H1 and above the date, not an H2.
- **Also omit.** Categories and tags (predefined, but not the header), `description` (already the index note), collection labels, and theme articles such as "a" / "an".

The preamble is concatenated in `Generator#render_row` for `:sidecar` only. `Body.call` stays the rendered source. `llms-full.txt` keeps its H2 and does not gain a second title or the date.

## Test Plan (TDD)

### Behaviors to Verify

- Page with a title → `# Title`, a blank line, then the rendered source. No date line.
- Page with no title → H1 is the filename the index uses (`my-page.md`).
- Page with `date` and `author` in front matter → still no meta line.
- Post with a filename date and no author → meta line is that `YYYY-MM-DD` only.
- Post with a string author → meta line is `YYYY-MM-DD - author`.
- Post date `2020-01-02 23:00:00 -0500` → meta date is `2020-01-02`.
- Post author blank, or not a string → date only.
- Post with `subtitle`, categories, tags, and `description` whose body does not contain those strings → sidecar does not contain them.
- Site config `author` does not appear when the post has no author.
- Post body that already starts with the same H1 → both headings remain.
- Collection document that is not a post, even with `date` and `author` → title and body only.
- `llms-full.txt` for a post → still `## Title` plus the source body, no date line.
- `Body.call` → still the rendered source only.

### Test Infrastructure

- Framework: RSpec
- Test location: `spec/`
- Conventions: one file per class, `process_site` / `build_site` / `read_dest` from `spec/support/site_fixtures.rb`, full sidecar strings compared with `eq`
- New test files: `spec/preamble_spec.rb`

## Implementation Plan

### 1. Preamble — executable

- Files: `lib/jekyll-llm-sidecars/preamble.rb`, `lib/jekyll-llm-sidecars.rb`, `spec/preamble_spec.rb`

1. Stub tests: empty examples in `spec/preamble_spec.rb` for each behavior above except the `llms-full.txt` and `Body.call` rows (those stay on the generator and body specs).
2. Stub interface: `JekyllLlmSidecars::Preamble.call(item)` returning `""`, required from `lib/jekyll-llm-sidecars.rb` beside the body require. Document the return value: the H1, the optional post meta line, and a trailing blank line, ready to concatenate with the body.
3. Write tests and run red: build a site per example, find the page or post, and `eq` `Preamble.call(item)` to the heading block.
4. Write code and run green: implement `Preamble.call` from `Summary.line` for the H1 and from post `data["date"]` / string `data["author"]` for the meta line. Do not read `subtitle`, categories, tags, description, or site author.

### 2. Sidecar file — executable

- Files: `lib/jekyll-llm-sidecars/generator.rb`, `spec/generator_spec.rb`, `spec/body_spec.rb`

1. Stub tests: add an example that the post sidecar for `_posts/2020-01-04-later.md` is `# Later\n\n2020-01-04\n\nLater body.\n` at `/2020/01/04/later.md`, and that `/llms-full.txt` is unchanged. Leave the new example's assertion empty until the next substep. Update the existing full-string sidecar expectations in the same edit as the assertion fill, not before.
2. Stub interface: none. `Generator#render_row` already returns the sidecar body.
3. Write tests and run red. New and updated expectations:
   - `/2020/01/04/later.md` → `# Later\n\n2020-01-04\n\nLater body.\n`
   - `/liquid.md` → `# Liquid\n\nHello Liquid\n`
   - `/frozen.md` → `# Frozen\n\nHello {{ page.title }}\n`
   - `/my-page.md` → `# my-page.md\n\nPage body.\n`
   - `/z.md` → `# Z\n\nZ\n`
   - `spec/body_spec.rb` written sidecar → `# T\n\nT\n\nFENCE\n`
   - Corpus strings in `spec/generator_spec.rb` stay exactly as they are, including `## Later\n\nLater body.\n` with no date.
4. Write code and run green: in `render_row`, for `:sidecar`, return `Preamble.call(entry.item)` concatenated with `entry.body`. Do not change `Body.call` or `corpus_block`.

### 3. Contract text — prose/policy

- Files: `README.md`, `memory-bank/productContext.md`, `memory-bank/systemPatterns.md`
- No tests: prose/policy artifact

1. In the README Sidecars section, state the H1, the post meta line, the omissions (subtitle, categories, tags, description), and that the source body is otherwise unchanged.
2. In the README `llms-full.txt` section, say the corpus uses the rendered source body and its own H2, and does not repeat the sidecar preamble.
3. Replace the product-context sentence that says a sidecar is only the source body with the preamble rule.
4. In system patterns, state that the sidecar file is the preamble plus the body slot, and the corpus reads the body slot only.

### 4. Devblog build — validation

- Files: `devblog` `Gemfile` and `Gemfile.lock`, temporary, then restored. Do not commit either repository's validation edit.
- No tests: the behaviors above are already specified. This step runs the site build the operator asked for.

1. Point the `jekyll-llm-sidecars` line in the devblog `Gemfile` at `path: "../jekyll-llm-sidecars"`.
2. `bundle install` in the devblog, then `bundle exec jekyll build`.
3. Read `_site/2026/10/20/lintel.md`. It starts with the title H1, then `2026-10-20 - niko`, then the first body paragraph. It does not contain the category article "a fable".
4. Read the built sidecar for `blog/essay/_posts/2026-03-01-pink-margarine.md`. It has the title, the date, and `texarkanine`. It does not have `In Memoriam: Software Licensing (1980-2026)`.
5. Restore the devblog `Gemfile` and `Gemfile.lock` with git. Leave that working tree as it was.

## Technology Validation

No new technology - validation not required.

## Dependencies

- Jekyll's post reader, which stores a filename date on `data["date"]` before generate.
- The devblog checkout at `/home/mobaxterm/git/devblog` for the build check only.

## Challenges & Mitigations

- A `-0500` date rendered in the machine zone rolls the calendar day: format with `strftime("%Y-%m-%d")` on the Time Jekyll stored, and lock it with the `23:00:00 -0500` example.
- Preamble inside `Body.call` would duplicate the title under the corpus H2 and change every body-slot assertion: concatenation stays in `Generator#render_row` for `:sidecar`. Existing corpus `eq` strings are the regression.
- An author array or a blank string would print garbage: only a string that matches `/\S/` is used.
- The devblog `Gemfile.lock` will change during the path install: restore both files in their own git command after the build, including when the build fails.
- Mutant covers `JekyllLlmSidecars*`. Each preamble branch (post vs not, author present vs blank vs non-string) needs an example that calls `Preamble.call`. Do not add a guard that no example can reach.
- Exact sidecar `eq` strings in `spec/generator_spec.rb` and `spec/body_spec.rb` will go red once the file changes. They are listed in step 2 so none are left on the old body.

## Pre-Mortem

- The plan treats the devblog line "a fable by niko" as the spec and emits the category. The meta line is date and author only. A preamble example asserts the category string is absent. "a fable" is that theme's article plus the category.
- The plan puts the heading in the body slot, so `llms-full.txt` grows a second title and the date. Step 2 keeps `corpus_block` on `entry.body` and leaves the corpus `eq` strings unchanged.
- Filename dates never reach `data["date"]`, so posts built from `_posts/YYYY-MM-DD-*.md` lose the date the HTML shows. The later.md example has no `date` key in its front matter and expects `2020-01-04`.
- Subtitle omission is rejected because the devblog shows one. The brief allows omitting a subtitle when it is not a stock field. The recommendation records that, with the paragraph format to use if a later change adds it. A blocking preflight fail comes back to this plan.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [x] Pre-Mortem complete
- [ ] Preflight
- [ ] Build
- [ ] QA
