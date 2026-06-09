# BrandCapture Changes

## 2026-06-08

- Centralized capture button state so Stop stays disabled until camera capture
  is active.
- Guarded UIImage/OpenCV Mat conversion helpers against nil image input and
  failed Core Graphics allocation.
- Added a changelog for repository maintenance.
- Restored README verification notes for the Objective-C++ camera/OpenCV source baseline.
- Extended the baseline script to require changelog and local toolchain-limit documentation.
