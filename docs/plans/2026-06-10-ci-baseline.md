# BrandCapture CI Baseline

## Status: Completed

## Context

`BrandCapture` has an SDK-free Objective-C++ and OpenCV source baseline behind
`make check`, with Xcode builds guarded for macOS hosts. The repository needs a
lightweight GitHub Actions gate so camera, permission, and project-file
contracts run before review.

## Objectives

- Run the existing static baseline in GitHub Actions.
- Keep the hosted job independent of Xcode, CocoaPods, and camera hardware.
- Minimize workflow token access and pin third-party action code by commit.
- Make the workflow presence part of the checked repository contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned `actions/checkout` to a reviewed commit, limited repository access to
  read-only, and bounded runs with a timeout and concurrency cancellation.
- Reused the existing guarded Makefile targets, which run static checks and
  skip Xcode build work when `xcodebuild` is unavailable.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Add a macOS/Xcode build job once the required Xcode, CocoaPods, and simulator
  baseline are documented.
