# BrandCapture Preview Outlet Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep camera startup safe when storyboard preview wiring is missing by avoiding
`CvVideoCamera` setup with a nil parent image view.

## Changes

- Initialized capture state before camera setup.
- Guarded `self.imageView` before creating `CvVideoCamera`.
- Left detector readiness false and synchronized controls when the preview
  outlet is unavailable.
- Extended the SDK-free baseline and documentation to enforce the preview outlet
  guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
