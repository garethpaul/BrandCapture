# BrandCapture Convex Projected Corners

Status: Completed

## Problem

The projected-corner validator rejects missing, non-finite, and near-zero-area
quadrilaterals, but a concave or self-crossing four-point result can still pass
the area threshold. A valid perspective projection of the rectangular target
must remain convex before it is returned to the camera overlay.

## Requirements

1. Require OpenCV convexity for all four projected corners.
2. Keep finite-coordinate validation before convexity evaluation.
3. Keep the existing one-square-pixel area threshold after convexity.
4. Preserve matcher thresholds, homography calculation, overlay edges, camera
   lifecycle, dependencies, and public interfaces.
5. Add mutation-sensitive source, ordering, documentation, and completed-plan
   contracts.

## Scope Boundaries

- Do not modify vendored OpenCV or CocoaPods files.
- Do not change descriptor matching, target setup, camera capture, storyboard,
  permissions, or overlay styling.
- Do not claim Xcode, OpenCV runtime, simulator, camera, or physical-device
  verification when those environments are unavailable.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Root and external-directory `make check` passed the complete source,
  storyboard, workflow, documentation, and plan contract gate.
- The vendored OpenCV 2.4.9 header confirms `isContourConvex(InputArray)` is
  available for the existing point vector; the checked-in framework is a
  Mach-O Apple binary and cannot execute on this Linux host.
- Six hostile mutations were rejected for missing convexity, inverted
  convexity, validation reordering, removed header inclusion, documentation
  drift, and reopened plan status.
- Exact diff, shell syntax, generated-artifact, vendored-path, whitespace, and
  credential-shaped addition audits passed.
- Xcode, OpenCV runtime, simulator, camera, and physical-device execution were
  unavailable and are not claimed.
