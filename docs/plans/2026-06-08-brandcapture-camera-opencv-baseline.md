---
title: BrandCapture Camera and OpenCV Baseline
type: fix
status: completed
date: 2026-06-08
---

# BrandCapture Camera and OpenCV Baseline

## Summary

Raise the baseline for the legacy Objective-C++ BrandCapture demo by tightening
camera capture lifecycle state, making OpenCV feature detection fail safely when
matches are unavailable, preserving camera privacy metadata and OpenCV pod pins,
and adding an SDK-free source check plus README guidance.

---

## Problem Frame

The app uses `CvVideoCamera` and OpenCV SURF matching to detect a reference
image in the camera stream. Detection loops assume the matcher returned as many
matches as the reference descriptor count, which can read past the match vector
when descriptors are missing or sparse. The feature matcher also uses Objective-C
Foundation calls, so it needs to be tracked as Objective-C++ source. The view
controller marks capture as active before the camera starts and does not
consistently clear that state when stopping on disappearance. Xcode is
unavailable in this environment, so the pass needs source-level verification.

---

## Requirements

- R1. OpenCV detection must return no corners when setup, descriptors, matches, or homography are insufficient.
- R2. Drawing must occur only when four detected corners are available.
- R3. Camera capture state must start as inactive and update consistently when starting, stopping, or leaving the screen.
- R4. Objective-C++ sources must be tracked as `.mm` in the Xcode project.
- R5. `NSCameraUsageDescription`, OpenCV 2.4.9, CocoaPods 1.0.1, bundle ID, and deployment targets must remain documented and guarded.
- R6. The repository must include README verification notes and an SDK-free baseline check.

---

## Key Technical Decisions

- **Return an empty corner vector on detection failure:** This lets the caller
  avoid drawing a false zero-size box.
- **Iterate actual match counts:** Matcher output size, not descriptor row count,
  is the safe upper bound.
- **Track Objective-C++ source explicitly:** Both the controller and feature
  matcher use Objective-C++ boundaries and should be `.mm` files in Xcode.
- **Preserve legacy OpenCV:** This pass keeps OpenCV 2.4.9 and CocoaPods output
  intact instead of rewriting the old pod/project setup.
- **Use source checks:** Neither XcodeBuildMCP nor `xcodebuild` is available, so
  simulator build verification remains follow-up work.

---

## Scope Boundaries

- This pass does not modernize OpenCV, CocoaPods, or deployment targets.
- This pass does not redesign the camera UI.
- This pass does not add simulator/device camera verification.
- This pass does not remove committed Pods.

---

## Implementation Units

### U1. Harden Detection Failure Paths

- **Goal:** Avoid out-of-bounds match reads and bogus overlay drawing.
- **Files:** `BrandCapture/features.mm`, `BrandCapture/ViewController.mm`
- **Patterns:** Guard missing image path, empty descriptors, empty matches, insufficient good matches, empty homography, and corner count before drawing.
- **Test Scenarios:**
  - Source check fails if loops use `descriptors_object.rows` as the match index upper bound.
  - Source check fails if FLANN match query/train indices are not validated before keypoint lookup.
  - Source check fails if the feature matcher is tracked as `.cpp` instead of `.mm`.
  - Source check fails if `good_matches.size() < kMinimumGoodMatches` is not guarded.
  - Source check fails if `processImage:` draws without checking `hasValidCorners(corners)`.
- **Verification:** `scripts/check-baseline.sh`

### U2. Stabilize Camera Lifecycle State

- **Goal:** Keep capture state consistent with the actual camera session.
- **Files:** `BrandCapture/ViewController.mm`
- **Patterns:** Start inactive, guard duplicate start/stop calls, disable capture when setup fails, stop camera and clear state on disappearance/dealloc.
- **Test Scenarios:**
  - Source check fails if `isCapturing = NO` initialization is removed.
  - Source check fails if stop paths do not clear `isCapturing`.
- **Verification:** `scripts/check-baseline.sh`

### U3. Document and Guard Legacy Toolchain

- **Goal:** Leave a repeatable maintenance gate for the old iOS/OpenCV project.
- **Files:** `README.md`, `scripts/check-baseline.sh`
- **Patterns:** Short toolchain, verification, and modernization notes; source checks for privacy metadata and pod/project pins.
- **Test Scenarios:**
  - README documents `scripts/check-baseline.sh`.
  - Script verifies `NSCameraUsageDescription`, OpenCV 2.4.9, CocoaPods 1.0.1, bundle ID, and deployment targets.
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

---

## Risks & Dependencies

- Runtime camera behavior still requires Xcode and a simulator/device with camera support or test imagery.
- SURF/nonfree OpenCV APIs remain legacy and should be migrated in a separate pass.
- Committed Pods are preserved to avoid changing dependency provenance.

---

## Sources / Research

- `BrandCapture/ViewController.mm` owns camera setup and overlay drawing.
- `BrandCapture/features.mm` owns SURF setup, matching, and homography.
- `BrandCapture/Info.plist` contains the camera usage description.
- `Podfile.lock` pins OpenCV 2.4.9 and CocoaPods 1.0.1.
- `BrandCapture.xcodeproj/project.pbxproj` pins bundle ID and deployment targets.
