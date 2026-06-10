# BrandCapture Camera Inactive Lifecycle

## Status: Completed

## Context

BrandCapture stopped its OpenCV camera session when the capture view
disappeared, but iOS may resign the application active state while that view
remains onscreen. App switching, device locking, and system interruptions could
therefore leave capture running beyond the active foreground interaction that
the permission copy describes.

## Objectives

- Stop active camera capture whenever the application resigns active.
- Reuse the existing idempotent capture-stop and control-state path.
- Remove application lifecycle observation when the controller is released.
- Preserve user-started capture semantics and existing view-disappearance
  cleanup.
- Keep the lifecycle contract verifiable without Xcode or camera hardware.

## Work Completed

- Registered for `UIApplicationWillResignActiveNotification` during controller
  setup.
- Added a focused lifecycle callback that routes through
  `stopCaptureIfNeeded`.
- Removed the notification observer during controller teardown before releasing
  camera delegate ownership.
- Extended the SDK-free baseline to enforce registration, callback reuse,
  observer removal, documentation, and completed plan status.
- Made Makefile baseline and Xcode workspace paths repository-rooted.
- Fixed the hosted CI runner to Ubuntu 24.04 and retained superseded-run
  cancellation.

## Verification

- `make check`
- `make -f /tmp/brandcapture-second-pass/Makefile check`
- `scripts/check-baseline.sh`
- Baseline mutation checks for notification registration, callback shutdown,
  observer removal, Makefile paths, CI, and plan status
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The current host does not provide Xcode, CocoaPods, an iOS simulator, or camera
hardware. Workspace compilation and live background/lock-screen transitions
remain manual checks on a macOS host with the documented legacy toolchain.

## Follow-Up Candidates

- Add an application-active policy for automatically resuming only if product
  requirements explicitly call for it; current behavior requires a new user
  Start action.
- Add simulator or device lifecycle coverage after a reproducible legacy Xcode
  environment is available.
