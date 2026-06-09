# BrandCapture Scene Keypoint Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep camera-frame detection on an explicit no-corners path when SURF finds no
keypoints in the scene image.

## Changes

- Returned empty corners immediately after scene keypoint detection when no
  keypoints are available.
- Avoided descriptor extraction and matcher setup for empty scene-keypoint
  inputs.
- Extended the SDK-free baseline, README, changelog, and vision with the
  scene-keypoint guard.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full Xcode build, simulator/device verification, and CocoaPods verification
still require a macOS host with the legacy OpenCV/CocoaPods toolchain.
