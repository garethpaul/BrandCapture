#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT="$ROOT_DIR/BrandCapture.xcodeproj/project.pbxproj"
VIEW_HEADER="$ROOT_DIR/BrandCapture/ViewController.h"
VIEW_CONTROLLER="$ROOT_DIR/BrandCapture/ViewController.mm"
FEATURES="$ROOT_DIR/BrandCapture/features.mm"
FEATURES_HEADER="$ROOT_DIR/BrandCapture/features.hpp"
INFO_PLIST="$ROOT_DIR/BrandCapture/Info.plist"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if ! grep -Fq "BrandCapture Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  "README.md" \
  "docs/plans/2026-06-08-brandcapture-camera-opencv-baseline.md" \
  "BrandCapture.xcworkspace/contents.xcworkspacedata" \
  "BrandCapture.xcodeproj/project.pbxproj" \
  "BrandCapture/ViewController.h" \
  "BrandCapture/ViewController.mm" \
  "BrandCapture/features.mm" \
  "BrandCapture/features.hpp" \
  "BrandCapture/clipper.jpg" \
  "BrandCapture/Info.plist" \
  "Podfile" \
  "Podfile.lock"; do
  require_file "$path"
done

if git -C "$ROOT_DIR" ls-files 'BrandCapture/ViewController.m' | grep -q .; then
  printf '%s\n' "ViewController must be tracked as Objective-C++ (.mm), not Objective-C (.m)." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files 'BrandCapture/features.cpp' | grep -q .; then
  printf '%s\n' "features must be tracked as Objective-C++ (.mm), not C++ (.cpp)." >&2
  exit 1
fi

if ! grep -Fq "ViewController.mm" "$PROJECT"; then
  printf '%s\n' "Xcode project must reference ViewController.mm." >&2
  exit 1
fi

if ! grep -Fq "features.mm" "$PROJECT"; then
  printf '%s\n' "Xcode project must reference features.mm." >&2
  exit 1
fi

if ! grep -Fq "sourcecode.cpp.objcpp" "$PROJECT"; then
  printf '%s\n' "Objective-C++ files must have Objective-C++ file type in the project." >&2
  exit 1
fi

if ! grep -Fq "BOOL isDetectorReady;" "$VIEW_HEADER"; then
  printf '%s\n' "ViewController must track detector readiness." >&2
  exit 1
fi

if ! grep -Fq "isCapturing = NO;" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must start with capture state inactive." >&2
  exit 1
fi

if ! grep -Fq 'BrandCaptureReferenceImageName = @"clipper.jpg"' "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must preserve the target image name." >&2
  exit 1
fi

if ! grep -Fq "isDetectorReady = setup(BrandCaptureReferenceImageName);" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must preserve setup readiness state." >&2
  exit 1
fi

if ! grep -Fq "if (isCapturing || !isDetectorReady || self.videoCamera == nil)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must guard duplicate starts, failed detector setup, and missing camera state." >&2
  exit 1
fi

if ! grep -Fq "stopCaptureIfNeeded" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must centralize stop handling." >&2
  exit 1
fi

if ! grep -Fq "isCapturing && self.videoCamera != nil" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must guard duplicate stops and missing camera state." >&2
  exit 1
fi

if ! grep -Fq "if (!isDetectorReady)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must skip frame processing when setup fails." >&2
  exit 1
fi

if ! grep -Fq "if (!hasValidCorners(corners))" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must guard invalid detection corners." >&2
  exit 1
fi

if ! grep -Fq "hasValidCorners" "$FEATURES_HEADER"; then
  printf '%s\n' "features.hpp must expose the corner validator." >&2
  exit 1
fi

if ! grep -Fq "static std::vector<Point2f> emptyCorners()" "$FEATURES"; then
  printf '%s\n' "features.mm must return explicit empty detections on failure." >&2
  exit 1
fi

if ! grep -Fq "path == nil" "$FEATURES"; then
  printf '%s\n' "features.mm must guard missing bundled target images." >&2
  exit 1
fi

if ! grep -Fq "descriptors_object.empty() || descriptors_scene.empty()" "$FEATURES"; then
  printf '%s\n' "features.mm must guard empty descriptor sets before matching." >&2
  exit 1
fi

if grep -Fq "i < descriptors_object.rows" "$FEATURES"; then
  printf '%s\n' "features.mm must not index matches by descriptor row count." >&2
  exit 1
fi

if ! grep -Fq "i < matches.size()" "$FEATURES"; then
  printf '%s\n' "features.mm must iterate actual matcher output size." >&2
  exit 1
fi

if ! grep -Fq "matches.size() < kMinimumGoodMatches" "$FEATURES"; then
  printf '%s\n' "features.mm must require enough raw matches before distance filtering." >&2
  exit 1
fi

if ! grep -Fq "good_matches.size() < kMinimumGoodMatches" "$FEATURES"; then
  printf '%s\n' "features.mm must require enough matches before homography." >&2
  exit 1
fi

if ! grep -Fq "static_cast<size_t>(good_matches[i].queryIdx) >= keypoints_object.size()" "$FEATURES" ||
  ! grep -Fq "static_cast<size_t>(good_matches[i].trainIdx) >= keypoints_scene.size()" "$FEATURES"; then
  printf '%s\n' "features.mm must validate match keypoint indices before dereferencing them." >&2
  exit 1
fi

if ! grep -Fq "object.size() < kMinimumGoodMatches || scene.size() < kMinimumGoodMatches" "$FEATURES"; then
  printf '%s\n' "features.mm must require enough homography input points." >&2
  exit 1
fi

if ! grep -Fq "H.empty()" "$FEATURES"; then
  printf '%s\n' "features.mm must guard empty homography results." >&2
  exit 1
fi

if ! grep -Fq "std::isfinite" "$FEATURES"; then
  printf '%s\n' "features.mm must reject non-finite detected corners." >&2
  exit 1
fi

if grep -Fq "drawMatches(" "$FEATURES"; then
  printf '%s\n' "features.mm must not build unused match visualizations during frame processing." >&2
  exit 1
fi

if grep -Fq "printf(" "$FEATURES"; then
  printf '%s\n' "features.mm must not print per-frame camera diagnostics." >&2
  exit 1
fi

if grep -Fq "NSLog(@" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must not log camera detection setup or frame state." >&2
  exit 1
fi

if ! grep -Fq "NSCameraUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Camera permission usage description must be present." >&2
  exit 1
fi

if ! grep -Fq "pod 'OpenCV', '2.4.9'" "$PODFILE"; then
  printf '%s\n' "Podfile must keep the expected OpenCV pin." >&2
  exit 1
fi

if ! grep -Fq "OpenCV (2.4.9)" "$POD_LOCK"; then
  printf '%s\n' "Podfile.lock must keep OpenCV 2.4.9 resolved." >&2
  exit 1
fi

if ! grep -Fq "COCOAPODS: 1.0.1" "$POD_LOCK"; then
  printf '%s\n' "Podfile.lock must keep the documented CocoaPods 1.0.1 provenance." >&2
  exit 1
fi

if ! grep -Fq "PRODUCT_BUNDLE_IDENTIFIER = com.gpj.BrandCapture;" "$PROJECT"; then
  printf '%s\n' "Xcode project must preserve the BrandCapture bundle identifier." >&2
  exit 1
fi

if ! grep -Fq "IPHONEOS_DEPLOYMENT_TARGET = 8.0;" "$PROJECT"; then
  printf '%s\n' "Target deployment baseline must remain documented." >&2
  exit 1
fi

if ! grep -Fq "GCC_INPUT_FILETYPE = sourcecode.cpp.objcpp;" "$PROJECT"; then
  printf '%s\n' "Target must keep Objective-C++ input file type for OpenCV interop." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

if ! grep -Fq "BrandCapture.xcworkspace" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the CocoaPods workspace entry point." >&2
  exit 1
fi

if ! grep -Fq "OpenCV 2.4.9" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the legacy OpenCV baseline." >&2
  exit 1
fi

if ! grep -Fq "CocoaPods 1.0.1" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document CocoaPods lockfile provenance." >&2
  exit 1
fi

if ! grep -Fq 'This host does not have `xcodebuild` or `pod`' "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document local Apple toolchain limitations." >&2
  exit 1
fi

if ! grep -Fq "CHANGES.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must point to CHANGES.md." >&2
  exit 1
fi

printf '%s\n' "BrandCapture camera baseline checks passed."
