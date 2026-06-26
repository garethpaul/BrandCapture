---
title: BrandCapture Legacy Build and Camera Guide
type: documentation
status: completed
date: 2026-06-25
owner: repository maintainers
---

# BrandCapture Legacy Build and Camera Guide

## Context

The repository documents OpenCV 2.4.9 and CocoaPods 1.0.1 provenance but did
not explain how those historical constraints relate to the Xcode project, the
bundled detector reference, or the evidence that a simulator and physical
device can provide. The roadmap also retained build and target-image guidance
as open work after the underlying repository contracts were already available.

## Priority

1. Make the historical build contract explicit without claiming compatibility
   with current Apple tooling.
2. Tie detector verification to the checked-in `BrandCapture/clipper.jpg`
   reference and the exact implementation commit.
3. Separate simulator smoke evidence from physical camera and overlay evidence.

## Requirements

- R1. Document Xcode 6.3 compatibility, the app target's iOS deployment target 8.0,
  OpenCV 2.4.9, and CocoaPods 1.0.1 as historical repository facts.
- R2. Require lockfile-preserving installation and workspace builds from the
  same exact commit used for verification.
- R3. Identify `BrandCapture/clipper.jpg` and
  `BrandCaptureReferenceImageName` as one reviewed reference-image contract.
- R4. Limit simulator claims to build, launch, storyboard, and control smoke
  checks; require a physical iOS device for camera, permission, live-frame,
  overlay, orientation, and sustained-capture rows.
- R5. Keep fixtures synthetic and privacy-safe, and do not store camera frames
  or treat a successful build as runtime camera evidence.
- R6. Add static documentation contracts and remove completed roadmap items.

## Implementation Units

### U1: Maintainer Guidance

**Files:** `README.md`, `DEVICE_VERIFICATION.md`, `VISION.md`, `CHANGES.md`

Document the historical build facts, reference ownership, exact-commit rule,
and simulator-versus-device evidence boundary.

### U2: Durable Verification

**Files:** `scripts/check-baseline.sh`, this plan

Require the maintained guidance, truthful roadmap state, changelog evidence,
plan state, and local verification nonclaims in `make check`.

## Scope Boundaries

- Do not modify the Xcode project, Pod manifests or lockfile, source code,
  storyboard, signing, assets, bundle identifier, or workflow configuration.
- Do not modernize OpenCV, CocoaPods, Xcode, or deployment targets in this pass.
- Do not claim simulator camera support or transfer evidence between commits.
- No Xcode build, CocoaPods install, simulator launch, physical camera, or live overlay was executed.

## Verification Plan

- Run `scripts/check-baseline.sh` and repository/external-directory `make check`.
- Reject isolated documentation mutations across README, device prerequisites,
  roadmap state, changelog evidence, and plan status/nonclaims.
- Audit the diff for unintended project, dependency, asset, source, and workflow
  changes before commit.
- Wait for exact-head hosted Check and CodeQL before changing this plan to
  completed.

## Verification Results

- Repository and external-directory `make check` passed the static baseline,
  camera authorization integration gate, capture-state tests, projected-corner
  tests, and image matrix layout tests.
- All 13 isolated documentation mutations were rejected across README build
  facts and evidence boundaries, device prerequisites, roadmap state,
  changelog evidence, and plan status and runtime nonclaims.
- `xcodebuild` was unavailable on Linux. No Xcode build, CocoaPods install, simulator launch, physical camera, or live overlay was executed.
- Exact-head hosted Check and CodeQL passed.
