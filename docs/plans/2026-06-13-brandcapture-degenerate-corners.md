---
title: BrandCapture Degenerate Corner Rejection
type: reliability
status: planned
date: 2026-06-13
---

# BrandCapture Degenerate Corner Rejection

## Status: Planned

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
