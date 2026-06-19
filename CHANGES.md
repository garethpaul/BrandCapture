# BrandCapture Changes

## 2026-06-13

- Cleared stale reference state and staged OpenCV setup locally before publishing
  a fully validated image, keypoint, and descriptor set.
- Retained zero-distance descriptor matches at the inclusive
  three-times-minimum threshold so exact reference matches can proceed to
  homography validation.
- Added an SDK-free regression contract and maintenance documentation for the
  inclusive matcher boundary.

## 2026-06-12

- Disabled checkout credential persistence in the canonical static Check job
  and added exact repository contracts for that boundary.
- Contained OpenCV exceptions across camera-frame detection and overlay drawing
  so one rejected frame no longer unwinds through the video delegate callback.
- Extended the SDK-free baseline and maintenance notes for the fail-closed frame
  processing boundary.
- Hardened the exception-boundary checker to reject missing or duplicated
  ordering markers before comparing their source positions.

## 2026-06-10

- Stopped camera capture when the application resigns active and removed the
  lifecycle observer during controller teardown.
- Made baseline and Xcode workspace paths location-independent and pinned CI to
  the stable Ubuntu 24.04 runner image.
- Added a GitHub Actions check workflow that runs the existing `make check`
  baseline on pushes, pull requests, and manual dispatches.
- Pinned the checkout action and limited the workflow token to read-only
  repository access with bounded execution.
- Added an SDK-free guard requiring the CI workflow and completed CI baseline
  plan to remain checked in.

## 2026-06-09

- Removed the desktop OpenCV `main.cpp` sample from the iOS target sources while
  leaving it available in the project navigator for reference.
- Switched UIImage/OpenCV conversion buffers to CGImage pixel dimensions instead
  of point-based `UIImage.size` values.
- Guarded camera setup when the storyboard preview image outlet is unavailable,
  leaving capture disabled instead of building a camera with a nil parent view.
- Tightened camera permission copy to describe user-started, on-device target
  image detection and guarded unused microphone/location permission text.
- Skipped scene descriptor extraction when SURF detects no scene keypoints so
  empty frames return the existing no-corners result directly.
- Corrected grayscale UIImage conversion to use an explicit device-gray color
  space with matching one-channel bitmap info and release handling.
- Wired the storyboard Start, Stop, and toolbar outlets to `ViewController` so
  the existing capture-control state synchronization reaches the UI controls.
- Extended the SDK-free baseline and README notes to guard capture-control
  storyboard wiring.

## 2026-06-08

- Added `make check` as the root wrapper for the BrandCapture source baseline
  and optional Xcode build.
- Centralized capture button state so Stop stays disabled until camera capture
  is active.
- Guarded UIImage/OpenCV Mat conversion helpers against nil image input and
  failed Core Graphics allocation.
- Added a changelog for repository maintenance.
- Restored README verification notes for the Objective-C++ camera/OpenCV source baseline.
- Extended the baseline script to require changelog and local toolchain-limit documentation.
