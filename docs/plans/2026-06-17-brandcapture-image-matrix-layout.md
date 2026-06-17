---
title: BrandCapture Image Matrix Layout
type: reliability
status: completed
date: 2026-06-17
owner: repository maintainers
---

# BrandCapture Image Matrix Layout

## Context

`UIImageFromCVMat:` copies `cv::Mat` bytes into Core Graphics while retaining
the Mat row stride. It currently accepts any nonempty Mat, including unsupported
depths or channel counts, and computes the copied byte length as
`elemSize() * total()`. For a non-contiguous region of interest that length
omits row padding while `CGImageCreate` still receives the larger source stride,
creating an inconsistent buffer contract. Unsupported layouts can likewise
produce invalid color-space, bits-per-pixel, and alpha combinations.

## Priority

1. Fix the deterministic buffer length and layout invariant because it can
   expose Core Graphics to an invalid byte range.
2. Execute the production layout decision in the existing portable C++ gate.
3. Defer dependency and Xcode modernization because the repository lacks a
   compatible macOS runtime and those changes have a larger behavioral surface.

## Requirements

- R1. Accept only nonempty 8-bit single-channel grayscale and four-channel
  RGBA-compatible Mats produced by the maintained conversion paths.
- R2. Reject unsupported depths and channel counts before allocating Core
  Graphics objects.
- R3. Clone non-contiguous Mats before exporting bytes so copied length and row
  stride describe the same tightly packed buffer.
- R4. Validate positive dimensions and overflow-safe row and total byte counts.
- R5. Use grayscale alpha metadata for one channel and skip-last alpha metadata
  for four channels.
- R6. Keep Core Graphics ownership and failure cleanup balanced.
- R7. Add portable production-helper tests, Make integration, static contracts,
  maintained guidance, and truthful completed verification evidence.

## Key Technical Decisions

- KTD1. Put dimension, channel, byte-width, row-stride, and total-length checks
  in a framework-independent C++ header consumed directly by Objective-C++.
- KTD2. Clone only after the original Mat passes supported type and dimension
  checks; then validate the cloned continuous layout before copying data.
- KTD3. Support only the layouts this repository creates rather than guessing
  channel order for arbitrary two- or three-channel Mats.

## Implementation Units

### U1: Portable Layout Contract

**Files:** `BrandCapture/ImageMatrixLayout.hpp`,
`Tests/ImageMatrixLayoutTests.cpp`

Define and execute overflow-safe accepted-layout and byte-length behavior for
grayscale and four-channel image buffers.

### U2: UIKit Bridge Enforcement

**File:** `BrandCapture/ViewController.mm`

Reject unsupported Mats, clone non-contiguous input, consume the portable
layout result, and use channel-appropriate Core Graphics bitmap metadata.

### U3: Canonical Verification

**Files:** `scripts/test-image-matrix-layout.sh`, `scripts/check-baseline.sh`,
`Makefile`, `.github/workflows/ci.yml`

Compile the production helper with the host C++11 compiler, enforce cleanup,
and execute it in repository and hosted checks.

### U4: Maintained Guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document supported layouts, the non-contiguous clone boundary, and the native
runtime evidence that remains unavailable on Linux.

## Test Scenarios

- Accept tightly packed 8-bit grayscale and four-channel layouts.
- Reject zero/negative dimensions, unsupported channels, multi-byte elements,
  undersized row strides, and row/total byte overflow.
- Prove non-contiguous production input is cloned before byte export.
- Preserve nil/failure cleanup for color space, provider, and image creation.
- Preserve projected-corner, feature-matching, camera-state, and static gates.

## Scope Boundaries

- Do not infer BGR/RGB ordering for unsupported three-channel Mats.
- Do not modify camera capture formats, OpenCV matching, overlay geometry,
  dependencies, signing, assets, or storyboard behavior.
- Do not claim Xcode, Core Graphics runtime, simulator, camera, or physical
  device execution from portable tests.
- Do not merge or close stacked pull requests without owner authorization.

## Verification Plan

- Reproduce the missing contract by showing the pre-change bridge accepts an
  unsupported/non-contiguous layout without a production helper guard.
- Run focused portable layout and existing projected-corner tests.
- Run repository and external-directory `make check` with explicit timeouts.
- Reject isolated mutations for supported channels, byte width, dimensions,
  stride, overflow, clone ordering, bitmap metadata, cleanup, Make wiring,
  guidance, plan status, and verification evidence.
- Audit the exact diff, generated artifacts, credentials, file modes, conflict
  markers, dependencies, and whitespace before commit.

## Work Completed

- Added a portable, overflow-safe contract for the supported grayscale and
  four-channel image matrix layouts.
- Guarded UIKit export by depth and channel count, cloned non-contiguous Mats,
  and passed only validated byte length, stride, and bitmap metadata to Core
  Graphics.
- Added the production helper to the Xcode project and canonical portable test
  gate with maintained static contracts and repository guidance.

## Verification Results

- Focused projected-corner and image matrix layout C++ executables passed.
- Repository and external-directory `make check` passed the static baseline and
  both portable executables; xcodebuild is unavailable on Linux, so no native
  build, Core Graphics runtime, simulator, camera, or device result is claimed.
- Twelve isolated hostile mutations were rejected across supported channels,
  byte width, packed stride, overflow, production depth and clone guards,
  bitmap metadata, Make wiring, runner cleanup, guidance, and plan status.
- Review identified the OpenCV single-row continuous-but-padded edge case; the
  production helper now executes that clone decision and its focused cases pass.
