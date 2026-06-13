---
title: BrandCapture Finite Match Distance Guard
type: reliability
status: planned
date: 2026-06-13
---

# BrandCapture Finite Match Distance Guard

## Status: Planned

## Problem Frame

`detect()` computes its good-match threshold from OpenCV matcher distances
without first requiring those distances to be finite. If every matcher result
has an infinite distance, the threshold also becomes infinite and the inclusive
comparison accepts those invalid matches for homography input.

## Scope Boundaries

- Preserve the bundled target image, SURF settings, inclusive three-times-minimum
  threshold, homography algorithm, camera lifecycle, and overlay appearance.
- Keep exact zero-distance descriptor matches eligible for homography.
- Do not update OpenCV, CocoaPods, Xcode project metadata, assets, or signing.
- Do not claim simulator, camera, or OpenCV runtime coverage on this Linux host.

## Requirements

- R1. `detect()` must fail closed when any matcher distance is not finite.
- R2. Finite zero-distance matches must retain the existing inclusive threshold.
- R3. Non-finite distances must be rejected before minimum-distance calculation
  and before good-match collection.
- R4. The deterministic checker must reject a missing, weakened, or reordered
  finite-distance guard.
- R5. Maintenance documentation must describe the matcher-output boundary and
  link this completed plan.

## Implementation

1. Validate every raw match distance with `std::isfinite()` before updating the
   minimum-distance accumulator.
2. Return the established empty-corner result immediately for invalid matcher
   output while leaving finite threshold behavior unchanged.
3. Add exact source-order and fail-closed contracts to
   `scripts/check-baseline.sh`.
4. Update the README, vision notes, and changelog without changing runtime
   dependencies or project metadata.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- External-working-directory `make check`
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations for a missing finite check, an inverted predicate,
  a continuing instead of fail-closed branch, reordered validation, stale plan
  status, and missing verification evidence must each fail the checker.
- Record unavailable Xcode/OpenCV/camera execution truthfully.
