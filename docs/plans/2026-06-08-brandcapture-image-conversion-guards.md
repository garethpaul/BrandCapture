---
title: BrandCapture Image Conversion Guards
type: fix
status: completed
date: 2026-06-08
---

# BrandCapture Image Conversion Guards

## Summary

Make the Objective-C++ UIImage/OpenCV Mat bridge fail closed when called with
invalid image data or when Core Graphics cannot allocate conversion objects.

## Requirements

- R1. `cvMatFromUIImage:` and `cvMatGrayFromUIImage:` must return an empty
  `cv::Mat` for nil images, missing `CGImage` values, invalid dimensions, or
  failed bitmap contexts.
- R2. `UIImageFromCVMat:` must return `nil` for empty Mat data or failed Core
  Graphics provider/image allocation.
- R3. The SDK-free baseline script must guard these failure paths.
- R4. Avoid changing the camera UI, OpenCV dependency version, or CocoaPods
  provenance.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
