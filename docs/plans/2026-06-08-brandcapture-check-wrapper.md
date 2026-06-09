---
title: BrandCapture Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# BrandCapture Check Wrapper

## Summary

Expose the BrandCapture source baseline and optional Xcode build through the
shared root `make check` command.

## Requirements

- R1. Preserve `scripts/check-baseline.sh` as the SDK-free verification gate.
- R2. Run an Xcode simulator build only when `xcodebuild` is available.
- R3. Keep Linux verification useful without CocoaPods or Xcode.
- R4. Document the wrapper in README and CHANGES.

## Verification

- `make check`
- `git diff --check`
