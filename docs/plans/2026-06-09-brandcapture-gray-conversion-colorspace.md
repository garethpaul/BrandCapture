# BrandCapture Grayscale Conversion Colorspace

Status: Completed
Date: 2026-06-09

## Goal

Keep grayscale UIImage-to-OpenCV conversion aligned with the one-channel Mat
buffer that receives the rendered image data.

## Changes

- Switched grayscale conversion to an explicit `CGColorSpaceCreateDeviceGray()`
  color space.
- Used one-channel `kCGImageAlphaNone` bitmap info for the grayscale context.
- Released the created color space on failure and success paths.
- Extended the SDK-free baseline, README, changelog, and vision with the
  grayscale conversion contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode build, simulator/device verification, and CocoaPods verification
still require a macOS host with the legacy OpenCV/CocoaPods toolchain.
