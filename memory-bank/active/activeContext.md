# Active Context

## Current Task: Exclude globs and corpus headings
**Phase:** BUILD - COMPLETE

## What Was Done
- `File.fnmatch?` now uses `File::FNM_PATHNAME`, so `/tags/**/*` matches `/tags/index.html` and `/error/**/*` matches `/error/404.html`
- Default exclude assets glob is `/assets/**/*`
- Corpus bodies are chomped and joined with two newlines
- A non-root corpus starts each document with `# {entry.summary.name}`

## Files
- `lib/jekyll/llms_txt/census.rb`
- `lib/jekyll/llms_txt/configuration.rb`
- `lib/jekyll/llms_txt/generator.rb`
- `spec/census_spec.rb`
- `spec/configuration_spec.rb`
- `spec/generator_spec.rb`
- `README.md`
- `memory-bank/productContext.md`

## Next Step
- QA review
