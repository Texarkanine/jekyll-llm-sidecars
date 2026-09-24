# Active Context

## Current Task: fix unbundled require in CI
**Phase:** COMPLEXITY-ANALYSIS - COMPLETE

## What Was Done
- Classified as Level 1: a bug fix in one spec helper. The child Ruby process drops the bundle, so `require "jekyll"` fails on CI.

## Next Step
- Load the Level 1 workflow
