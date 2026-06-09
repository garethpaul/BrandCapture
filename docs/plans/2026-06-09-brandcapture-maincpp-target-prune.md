# BrandCapture Main.cpp Target Prune

Status: Completed

## Context

`BrandCapture/main.cpp` is a desktop OpenCV research sample with Windows file
paths, webcam capture, and debug display windows. The iOS app already has
`main.m` as its application entry point and uses `features.mm` for the reusable
OpenCV matching path, but `main.cpp` was still listed in the app target Sources
phase.

## Plan

- Remove `main.cpp` from the iOS target Sources phase.
- Keep the `main.cpp` file reference in the project navigator for historical
  review.
- Extend the SDK-free baseline so desktop sample code does not re-enter the iOS
  app compile path.
- Document the target-prune contract in the README, changelog, and vision notes.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
