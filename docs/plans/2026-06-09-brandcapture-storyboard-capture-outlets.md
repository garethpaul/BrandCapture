# BrandCapture Storyboard Capture Outlets

## Status: Completed

## Goal

Wire the storyboard Start, Stop, and toolbar controls to `ViewController` so the
existing capture-control state logic actually reaches the UI.

## Scope

- Connect `startCaptureButton`, `stopCaptureButton`, and `toolbar` outlets in
  `Base.lproj/Main.storyboard`.
- Preserve the existing button actions and image-view outlet.
- Extend the SDK-free baseline to guard the storyboard outlet wiring.
- Document the wiring contract in README and CHANGES.

## Out Of Scope

- Opening or resaving the storyboard in Xcode.
- Changing camera capture behavior, OpenCV matching, Pods, or project settings.
- Running simulator/device camera verification on this non-macOS host.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
