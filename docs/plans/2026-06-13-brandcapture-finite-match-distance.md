---
title: BrandCapture Finite Match Distance Guard
type: reliability
status: completed
date: 2026-06-13
---

# BrandCapture Finite Match Distance Guard

## Status: Completed

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

## Work Completed

- Added a fail-closed finite check for each raw OpenCV match distance before
  updating the minimum-distance accumulator.
- Preserved the inclusive three-times-minimum threshold and eligibility of
  finite zero-distance matches.
- Added exact guard-count, fail-closed branch, and source-order contracts to the
  SDK-free checker.
- Updated maintenance documentation without changing dependencies, assets,
  project metadata, camera lifecycle, homography behavior, or overlay styling.

## Verification Completed

- `make lint`, `make test`, `make build`, `make check`, and `make verify` passed.
- External-working-directory `make check`, `sh -n scripts/check-baseline.sh`,
  and `git diff --check` passed.
- Six isolated hostile mutations were rejected: a missing finite check, an
  inverted predicate, a continuing branch, validation after minimum-distance
  calculation, stale plan status, and missing mutation-verification evidence.
- The Make gates reported `xcodebuild not found`; no xcodebuild, OpenCV execution, simulator camera,
  or physical-device validation is claimed.
