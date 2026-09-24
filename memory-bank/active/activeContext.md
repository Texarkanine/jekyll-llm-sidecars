# Active Context

## Current Task: sidecar-collision-and-binary-write
**Phase:** QA - COMPLETE (PASS)

## What Was Done

- A sidecar is skipped only when a Jekyll page, document, or static file already uses that destination.
- A later build rewrites a sidecar the page does not occupy.
- Destination writes use `mode: "wb"`.
- 141 examples passed. RuboCop reported no offenses.
- Include and exclude path matching was not changed.

## Next Step

- Level 1 QA.
