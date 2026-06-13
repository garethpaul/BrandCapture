---
title: BrandCapture Degenerate Corner Rejection
type: reliability
status: completed
date: 2026-06-13
---

# BrandCapture Degenerate Corner Rejection

## Status: Completed

## Problem Frame

`hasValidCorners()` rejects the wrong corner count and non-finite coordinates,
but accepts four finite points whose projected quadrilateral has no meaningful
area. A collapsed homography result can therefore reach camera overlay drawing
as a line or point instead of following the existing no-corners path.

## Scope Boundaries

- Preserve the bundled target image, SURF settings, descriptor matching,
  homography algorithm, camera lifecycle, and overlay appearance.
- Keep the existing four-corner and finite-coordinate checks.
- Do not update OpenCV, CocoaPods, Xcode project metadata, assets, or signing.
- Do not claim simulator, camera, or OpenCV runtime coverage on this Linux host.

## Requirements

- R1. Four finite projected corners must be rejected when their quadrilateral
  area is less than one square pixel.
- R2. `detect()` must validate transformed corners before returning them to the
  camera delegate.
- R3. The caller must retain its existing corner validation before drawing.
- R4. The deterministic checker must reject missing, zeroed, inverted, or
  bypassed projected-area validation.
- R5. Maintenance documentation must describe the fail-closed geometry guard
  and link this completed plan.

## Implementation

1. Extend `hasValidCorners()` with a shoelace-area calculation over the four
   projected points and a one-square-pixel minimum.
2. Apply `hasValidCorners()` immediately after `perspectiveTransform()` and
   return the established empty-corner result for rejected geometry.
3. Add source-order and exact-boundary contracts to `scripts/check-baseline.sh`.
4. Update the README, vision notes, and changelog without changing runtime
   dependencies or project metadata.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations for missing area validation, a zero minimum,
  inverted comparison, bypassed detector validation, stale plan status, and
  missing verification evidence must each fail the checker.
- Record unavailable Xcode/OpenCV/camera execution truthfully.

## Work Completed

- Added a one-square-pixel minimum projected area while retaining the existing
  four-corner and finite-coordinate validation.
- Rejected transformed corners inside `detect()` before returning them, while
  preserving the camera callback's existing validation before drawing.
- Added exact threshold, shoelace calculation, comparison, source-order, caller,
  documentation, and plan contracts to the SDK-free checker.
- Updated maintenance documentation without changing dependencies, assets,
  project metadata, camera lifecycle, feature matching, or overlay styling.

## Verification Completed

- `make lint`, `make test`, `make build`, `make check`, and `make verify` passed.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Five isolated hostile source mutations were rejected: missing validation, a
  zero minimum, an inverted comparison, disabled shoelace accumulation, and a
  bypassed detector guard.
- Two isolated hostile plan mutations were rejected: stale completion status
  and missing mutation-verification evidence.
- The Make gates reported `xcodebuild not found`; no xcodebuild, OpenCV execution, simulator camera,
  or physical-device validation is claimed.
