# Current Task: sidecar-collision-and-binary-write

**Complexity:** Level 1

## Build

- [x] Failing test: existing sidecar destination is kept and a warning is issued
- [x] Failing test: destination files are written with binary mode
- [x] Implement both in `Hooks.write`
- [x] Full test suite passes
- [x] Rebuild updates a sidecar that the page does not occupy

## QA

- [x] First review failed: `File.exist?` treated the plugin's own sidecar as a collision
- [x] The skip now uses Jekyll's destination for that path
- [x] README states the skip
- [x] Second review passed: skip is occupancy of a Jekyll site file, not disk existence
- [x] `File.write` uses `mode: "wb"`; census include/exclude matching is unchanged
- Advisory: `inject` still adds the alternate link when the sidecar write is skipped
