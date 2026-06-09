---
title: BrandCapture Capture Control State
type: fix
status: completed
date: 2026-06-08
---

# BrandCapture Capture Control State

## Summary

Keep Start and Stop button availability synchronized with detector readiness
and active camera capture state.

## Requirements

- R1. Detector setup failure keeps both capture controls disabled.
- R2. Start is enabled only when the detector is ready and capture is inactive.
- R3. Stop is enabled only when the detector is ready and capture is active.
- R4. Capture state updates run after initial setup, successful start, and stop.
- R5. README, changelog, and source baseline document the control-state contract.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`

This environment does not provide XcodeBuildMCP, `xcodebuild`, or `pod`, so
simulator/device verification remains follow-up work on a matching legacy macOS
toolchain.
