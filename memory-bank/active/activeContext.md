# Active Context

## Current Task: Exclude globs and corpus headings
**Phase:** PLAN - COMPLETE

## What Was Done
- Wrote the Level 2 plan for `exclude-globs-corpus-headings`
- Each non-root corpus document gets an H1 of `entry.summary.name`. The root corpus stays body-only
- Documents are separated by exactly two newlines
- Exclude matching will pass `File::FNM_EXTGLOB | File::FNM_PATHNAME`

## Next Step
- Preflight validation
