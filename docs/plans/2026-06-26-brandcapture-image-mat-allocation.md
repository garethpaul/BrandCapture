# BrandCapture Image Mat Allocation Boundary

Status: Completed

## Problem

The UIKit-to-OpenCV conversion methods validated image dimensions and Core
Graphics allocation results, but constructed destination `cv::Mat` buffers
outside an exception boundary. OpenCV or standard allocation failures could
therefore escape instead of returning the methods' documented empty result.

## Decision

Add one shared `BrandCaptureCreateImageMat` helper that catches `cv::Exception`
and `std::bad_alloc`. Route both four-channel color and one-channel grayscale
conversion through it before creating bitmap contexts.

## Verification

- The source contract failed first because the allocation helper was absent.
- `make check`
- External-directory `make check`
- Shared-helper and per-converter hostile mutations.
- `xcodebuild remains unavailable` on the Linux maintenance host.
- Repository and external-directory `make check`, shell syntax, and diff checks passed.
- Two isolated hostile mutations failed for the intended reason.
- Exact-head Check runs `28251597499` and `28251599017` passed; CodeQL run
  `28251598282` passed Actions and C/C++ analysis.
- Codex review failed before analysis with OpenAI API HTTP 401; immutable
  exact-head manual review found no actionable findings.
