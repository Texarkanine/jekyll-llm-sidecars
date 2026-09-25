# Active Context

## Current Task: sidecar-liquid-cache
**Phase:** COMPLEXITY-ANALYSIS - COMPLETE

## What Was Done
- Classified as Level 1. The bug is in `JekyllLlmSidecars::Body`: it Liquid-renders through Jekyll's path-keyed template cache during `generate`, so a later `:pre_render` content rewrite is ignored for documents that contain Liquid.
- The fix stays in that one class. The regression simulates the rewrite hook. Mermaid-prebuild is the discovery, not the change.

## Next Step
- Load the Level 1 workflow and build.
