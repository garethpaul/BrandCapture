## BrandCapture Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

BrandCapture is an iOS app that detects a target brand image from live camera
input using OpenCV feature matching.

The repository is useful as a compact Objective-C++ and OpenCV sample for
camera capture, SURF feature extraction, descriptor matching, and overlaying a
detected object boundary. Setup notes live in [`README.md`](README.md).

The goal is to preserve the computer-vision prototype while making future camera
privacy, dependency, and verification work explicit.

The current focus is:

Priority:

- Preserve the OpenCV 2.4.9 and CocoaPods workspace setup
- Keep the camera-to-feature-detection flow easy to inspect
- Keep storyboard controls wired to the capture-state code
- Keep camera preview wiring validated before capture setup
- Keep camera capture scoped to an active foreground application lifecycle
- Keep image conversion buffer formats explicit before OpenCV processing
- Keep OpenCV image buffer dimensions tied to underlying CGImage pixels
- Keep feature detection failure paths explicit before descriptor matching
- Keep OpenCV frame-processing failures contained at the camera callback
- Keep desktop OpenCV research code out of the iOS app target
- Keep camera permission copy specific to user-started local processing
- Keep GitHub Actions running the static `make check` baseline before review
- Maintain the target image and detection code relationship
- Avoid changes that require unavailable Apple tooling without documenting them

Next priorities:

- Add build and manual camera verification details to the README
- Modernize OpenCV and iOS toolchain assumptions in a dedicated pass
- Add safer failure handling when feature detection cannot produce corners
- Clarify target-image configuration for new brand examples

Contribution rules:

- One PR = one focused camera, OpenCV, build, or documentation change.
- Run `pod install` and open the workspace for build verification.
- Include device or simulator notes for camera behavior changes.
- Keep `.github/workflows/check.yml` aligned with the static baseline until a
  macOS build job is documented.
- Preserve sample images and explain replacements.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Camera input is sensitive. Do not upload frames, store captured images, or add
analytics without explicit documentation and user control.

Future brand-recognition changes should make target images and processing
location clear.

## What We Will Not Merge (For Now)

- Camera data upload behavior
- OpenCV migrations bundled with unrelated app behavior changes
- Target image changes without rationale
- Generated signing material, local paths, or private assets

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
