---
title: BrandCapture Projected Corner Tests
type: testing
date: 2026-06-16
status: completed
execution: code
---

# BrandCapture Projected Corner Tests

## Context

Projected overlay corners are checked for finite coordinates, convex ordering,
and minimum area, but that deterministic behavior is embedded in Objective-C++
and protected only by static source contracts because the vendored OpenCV
framework cannot run on Linux.

## Priority

Execute the production corner decisions with a standard C++11 compiler in the
canonical verification path without requiring UIKit, OpenCV linkage, Xcode, a
simulator, or camera hardware.

## Requirements

- Extract finite, convex, and one-square-pixel area decisions into
  framework-independent C++ used directly by `hasValidCorners`.
- Preserve exact four-corner cardinality, clockwise and counter-clockwise valid
  ordering, fail-closed non-finite handling, convexity, and area threshold.
- Cover valid squares, exact and below-threshold area, concave and crossing
  shapes, collinear or duplicate points, wrong counts, and non-finite values.
- Compile and run production behavior from a temporary directory that is
  removed on success, failure, or signal.
- Make `make check` execute the test when a C++ compiler is available and retain
  a truthful skip when it is not.
- Preserve matching, homography, OpenCV exceptions, camera state, overlay
  drawing, dependencies, assets, signing, and device-verification boundaries.

## Verification

- Focused executable C++ test and runner cleanup probes.
- Repository and external-directory `make check`.
- Mutation-sensitive contracts for production delegation, geometry decisions,
  exact cases, cleanup, Make/workflow execution, docs, and plan evidence.
- Exact-head hosted Ubuntu checks proving the executable behavior runs.

## Scope Boundary

This change does not claim Xcode, OpenCV framework, simulator, live-camera,
overlay-rendering, or physical-device execution.

## Verification Results

Completed on 2026-06-16:

- `sh -n scripts/check-baseline.sh scripts/test-projected-corners.sh` passed.
- The real C++11 executable passed all 12 geometry cases.
- Runner success, compiler failure status 7, and signal status 143 removed their
  explicit temporary output directories.
- Repository and external working directory `make check` passed.
- 13 hostile mutations were rejected across production delegation, cardinality,
  finite values, convex turns, area threshold, exact cases, cleanup, Make
  integration, project membership, plan evidence, and documentation.
- `xcodebuild` is unavailable on Linux, so no Xcode, OpenCV framework,
  simulator, camera, overlay, or device execution is claimed. Exact-head hosted
  Ubuntu behavior execution remains a required pre-merge gate.
