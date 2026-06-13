---
title: BrandCapture Zero-Distance Descriptor Matches
type: fix
date: 2026-06-13
---

# BrandCapture Zero-Distance Descriptor Matches

## Summary

Allow exact OpenCV descriptor matches to reach homography validation without
changing the existing threshold for positive match distances.

## Problem Frame

`BrandCapture/features.mm` keeps matches whose distance is strictly less than
three times the minimum distance. When the best descriptors match exactly,
the minimum is zero and the strict comparison rejects every zero-distance
match. A perfect reference match can therefore fail before localization.

## Requirements

- R1. A descriptor whose distance equals the computed threshold must remain a
  candidate, including an exact match at zero distance.
- R2. Positive-distance matches must keep the existing three-times-minimum
  threshold and minimum-good-match guard.
- R3. Invalid match indexes, empty descriptors, homography failures, and
  invalid output corners must retain their current fail-closed behavior.
- R4. The SDK-free baseline must detect regression to a strict comparison and
  document the exact-match boundary and platform-validation limitation.

## Key Technical Decisions

- **Use an inclusive comparison:** Changing `<` to `<=` fixes the zero-distance
  boundary without introducing a new heuristic or tuning constant.
- **Keep the matcher pipeline unchanged:** Descriptor extraction, FLANN
  matching, index validation, homography, and corner validation remain outside
  this change.
- **Enforce the source contract statically:** The legacy Xcode/OpenCV toolchain
  is unavailable on this host, so the repository checker will pin the inclusive
  boundary and supporting documentation while macOS/device execution remains a
  stated follow-up risk.

## Implementation Units

### U1. Accept Threshold-Equal Matches

- **Files:** `BrandCapture/features.mm`
- **Goal:** Include descriptor distances equal to
  `kGoodMatchDistanceMultiplier * min_dist` while preserving the surrounding
  minimum-count and index guards.
- **Covers:** R1, R2, R3

### U2. Add Regression And Maintenance Contracts

- **Files:** `scripts/check-baseline.sh`, `README.md`, `CHANGES.md`, `VISION.md`
- **Goal:** Require the inclusive matcher boundary, reject the prior strict
  comparison, and record the exact-match behavior and unavailable native
  runtime coverage.
- **Covers:** R4

## Verification

- Run the focused static baseline and root `make check` wrappers from the
  repository and an external working directory.
- Run shell syntax and diff checks.
- Apply isolated hostile mutations for the inclusive comparison,
  three-times-minimum multiplier, minimum-good-match guard, and plan/docs
  contracts; each mutation must fail the checker.
- Do not claim Xcode, OpenCV 2.4.9, simulator, camera, or device execution when
  those tools are unavailable.

## Risks

- Inclusive comparison can retain matches exactly on a positive threshold;
  this is the intended mathematical boundary and leaves the existing minimum
  count, index, homography, and corner checks in place.
- Static source verification cannot prove behavior of the legacy FLANN/SURF
  pipeline on supported Apple hardware.
