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
- Reconcile active capture state even when camera ownership is already absent
- Keep camera authorization and session startup in an app-owned, generation-tagged
  state machine so delayed callbacks cannot make controls claim stale capture
- Preserve user-started authorization through the system permission prompt only;
  genuine backgrounding must cancel the generation before any camera startup
- Keep image conversion buffer formats explicit before OpenCV processing
- Keep OpenCV image buffer dimensions tied to underlying CGImage pixels
- Keep feature detection failure paths explicit before descriptor matching
- Keep atomic reference-detector setup fail-closed before camera matching
- Keep the descriptor filter's inclusive descriptor-match threshold explicit
- Require finite matcher distances before descriptor threshold calculation
- Keep non-degenerate projected geometry mandatory before overlay drawing
- BrandCapture rejects non-convex projected quadrilaterals before overlay drawing.
- Projected corner behavior remains executable with a standard C++11 compiler,
  independent of Xcode, OpenCV linkage, and camera hardware.
- Keep OpenCV frame-processing failures contained at the camera callback
- Keep desktop OpenCV research code out of the iOS app target
- Keep camera permission copy specific to user-started local processing
- Keep GitHub Actions running the static `make check` baseline before review
- Keep Make verification rooted to the loaded repository Makefile
- Keep non-persisted checkout credentials in hosted verification
- Maintain the target image and detection code relationship
- Avoid changes that require unavailable Apple tooling without documenting them
- Keep exact-commit BrandCapture device verification matrix evidence separate
  from portable checks, with unexecuted Xcode, OpenCV, camera, overlay, and
  device rows explicit

Next priorities:

- Add build and manual camera verification details to the README
- Modernize OpenCV and iOS toolchain assumptions in a dedicated pass
- Add safer failure handling when feature detection cannot produce corners
- Clarify target-image configuration for new brand examples
- Execute the device verification matrix with synthetic references and
  privacy-safe permission, geometry, overlay, lifecycle, and sustained-use evidence
- Keep Image matrix layout validation in the portable gate so native image
  export cannot drift from its supported grayscale and four-channel formats.

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
