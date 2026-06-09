# BrandCapture Camera Permission Copy

Status: Completed
Date: 2026-06-09

## Goal

Keep iOS camera permission copy specific to the app behavior that exists:
user-started, on-device target-image detection.

## Changes

- Replaced generic camera permission text with copy describing user-started
  capture and bundled target-image detection on device.
- Added a source-baseline guard for the exact camera usage description.
- Added a baseline guard against unused microphone or location permission text.
- Documented the permission-copy contract in the README, changelog, and vision.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full Xcode build, simulator/device verification, and CocoaPods verification
still require a macOS host with the legacy OpenCV/CocoaPods toolchain.
