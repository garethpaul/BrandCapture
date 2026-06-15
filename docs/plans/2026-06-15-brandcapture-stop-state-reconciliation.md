# BrandCapture Stop State Reconciliation

## Status: Planned

## Context

`stopCaptureIfNeeded` currently changes `isCapturing` and the capture controls
only when both local capture state is active and `videoCamera` is non-null. If
the camera reference disappears during lifecycle teardown or another ownership
transition, a stop request leaves the controller reporting an active capture
that it can no longer stop.

## Priority

Medium lifecycle correctness. Centralized shutdown must leave local state idle
even when the camera object is already unavailable.

## Requirements

- Return without side effects when capture is already idle.
- Stop `videoCamera` when an active capture still owns a camera instance.
- Always clear `isCapturing` and refresh capture controls after an active stop
  request, including the missing-camera path.
- Preserve the existing application-inactive, disappearing-view, explicit-stop,
  and teardown callers.
- Add a fail-closed static contract for stop-before-state ordering and focused
  hostile mutations.

## Scope Boundaries

- Do not change capture startup, detector setup, OpenCV processing, matching,
  homography, overlay drawing, storyboard wiring, dependencies, workflows, or
  Xcode project settings.
- Do not claim Xcode, simulator, camera, or physical-device validation from
  Linux.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Separate the idle guard from optional camera shutdown.
2. Reconcile active local state and controls after the optional stop call.
3. Extend the portable checker and maintained lifecycle documentation.
4. Record completed bounded validation and mutation evidence.

## Verification

- `sh -n scripts/check-baseline.sh`
- repository and external-directory `make check`
- focused hostile lifecycle-ordering and completed-plan mutations
- plist/workspace XML, exact-diff, artifact, credential-pattern, and whitespace
  audits

## Remaining Risks

- Objective-C++ compilation, simulator lifecycle transitions, and physical
  camera behavior require macOS/Xcode and suitable hardware or fixtures.
