# BrandCapture Image Pixel Dimensions

Status: Completed
Date: 2026-06-09

## Goal

Keep UIImage-to-OpenCV conversion buffers sized from the underlying CGImage
pixels instead of point-based UIImage dimensions.

## Changes

- Added a shared pixel-size helper that reads `CGImageGetWidth` and
  `CGImageGetHeight`.
- Reused the helper in color and grayscale conversion paths before allocating
  OpenCV Mats.
- Added static baseline coverage that rejects `UIImage.size` buffer sizing and
  requires the completed plan.
- Documented the pixel-dimension conversion guard in the README, changelog, and
  vision.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
