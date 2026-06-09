# BrandCapture Changes

## 2026-06-09

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
