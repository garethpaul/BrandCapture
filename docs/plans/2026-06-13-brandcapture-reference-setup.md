---
title: BrandCapture Atomic Reference Setup
type: reliability
status: completed
date: 2026-06-13
---

# BrandCapture Atomic Reference Setup

## Status: Completed

## Problem Frame

`setup()` decodes the bundled reference image and mutates global OpenCV image,
keypoint, and descriptor state as each stage completes. Detector or extractor
operations can raise `cv::Exception`, and a failed later setup can otherwise
leave partially refreshed or stale reference state available to camera-frame
matching.

## Scope Boundaries

- Preserve the `clipper.jpg` target, SURF Hessian threshold, descriptor type,
  matching threshold, camera behavior, overlay style, and public setup API.
- Do not change OpenCV/CocoaPods versions, project settings, assets, detector
  algorithms, or frame-processing behavior.
- Catch only `cv::Exception`; do not swallow Objective-C exceptions or unrelated
  C++ failures.
- Keep verification SDK-free because `xcodebuild`, the legacy OpenCV runtime,
  simulator camera, and physical-device execution are unavailable here.

## Implementation Units

### U1: Clear Published Reference State Before Setup

Files:

- Modify `BrandCapture/features.mm`

Approach:

- Centralize release/clear operations for the global object image, keypoints,
  and descriptors.
- Clear prior published state before validating a new setup request so every
  failure leaves matching disabled rather than retaining a stale target.

### U2: Stage OpenCV Work And Commit Only On Success

Files:

- Modify `BrandCapture/features.mm`

Approach:

- Decode, detect, and extract into local image/keypoint/descriptor values inside
  one `cv::Exception` boundary.
- Validate image data, non-empty keypoints, and non-empty descriptors before
  assigning any local result to the global matching state.
- Return `false` for missing resources, invalid decoded images, empty feature
  output, or OpenCV exceptions.

### U3: Extend Source And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require clear-before-validation ordering, local staging, one setup exception
  boundary, validation before publication, and completed plan evidence.
- Preserve all existing descriptor, homography, frame exception, camera
  lifecycle, checkout, and project-file contracts.
- Add isolated hostile mutations for stale-state retention, direct global
  mutation, missing validation, exception escape, and documentation drift.

## Verification

- `make check` and `make verify` passed the static camera/OpenCV baseline and
  root wrappers.
- Absolute-path `make check` passed from `/tmp`.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Ten isolated hostile mutations were rejected across clear-before-setup,
  clear ordering, local image/keypoint/descriptor staging, descriptor
  validation, publication ordering, exception type, descriptor cleanup, and
  README evidence.
- Tooling is unavailable; no xcodebuild, OpenCV execution, simulator camera, or
  physical-device validation is claimed.
