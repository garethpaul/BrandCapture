# BrandCapture Frame Exception Containment

## Status: Completed

## Goal

Keep a single unsupported or malformed camera frame from terminating the
Objective-C++ video callback when OpenCV feature extraction or overlay drawing
throws an exception.

## Problem

`detect` contains exceptions from descriptor matching and homography work, but
the camera delegate still calls detector extraction and four `cv::line`
operations outside a complete exception boundary. OpenCV can report invalid
frame formats, allocation failures, or drawing errors with `cv::Exception`.
Allowing one of those exceptions to unwind through `processImage:` can crash
the capture session instead of dropping only the affected frame.

## Scope

- Keep the existing detector-ready and corner-validation guards.
- Catch `cv::Exception` around detection and overlay drawing at the camera
  delegate boundary.
- Skip only the current frame when OpenCV rejects processing.
- Extend the SDK-free baseline and maintenance documentation for the fail-closed
  callback contract.

## Out Of Scope

- Changing SURF thresholds, descriptor matching, homography, or overlay style.
- Swallowing Objective-C exceptions or non-OpenCV C++ exceptions.
- Updating CocoaPods, OpenCV, deployment targets, or Xcode project settings.

## Verification

- `make check`
- `sh -n scripts/check-baseline.sh`
- Targeted baseline mutation checks
- `git diff --check`

XcodeBuildMCP, Xcode, iOS Simulator, and camera hardware are unavailable in this
session. Workspace compilation and live camera verification remain deferred to
a compatible macOS host with the legacy OpenCV toolchain.
