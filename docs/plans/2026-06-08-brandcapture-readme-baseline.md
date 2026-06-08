# BrandCapture README Baseline

## Goal

Keep the generated README aligned with the source-level camera and OpenCV baseline.

## Scope

- Document the SDK-free baseline command.
- Preserve the CocoaPods workspace entry point and legacy OpenCV/CocoaPods provenance.
- Record that this Linux host cannot run Xcode or CocoaPods verification.
- Avoid changing app code, project settings, or vendored Pods.

## Verification

- `scripts/check-baseline.sh`
