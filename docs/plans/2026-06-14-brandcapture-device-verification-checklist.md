# BrandCapture Device Verification Checklist

Status: In Progress

## Problem

Portable contracts cover reference setup, exact descriptor matches, finite
distances, finite and nondegenerate projected corners, and convexity, but no
checklist defines repeatable simulator or physical-camera evidence for the
exact implementation commit.

## Requirements

1. Add an exact-commit matrix for permission, reference capture, live matching,
   rejection cases, overlay geometry, lighting, orientation, interruption,
   sustained use, and relaunch.
2. Require synthetic references and sanitized Xcode, iOS, device, camera,
   result, and evidence fields.
3. Keep repository checks separate from unexecuted Xcode, OpenCV runtime,
   camera, simulator, and physical-device scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change Objective-C++, Xcode project, storyboard, vendored OpenCV,
  detector thresholds, reference assets, or runtime behavior.
- Do not add device identifiers, camera captures, room imagery, brand/customer
  data, screenshots, logs, archives, or signing material.
- Do not claim Xcode, simulator, OpenCV framework, camera, or physical-device
  execution from portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded repository validation.
