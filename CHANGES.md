# BrandCapture Changes

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
