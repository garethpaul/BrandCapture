#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT="$ROOT_DIR/BrandCapture.xcodeproj/project.pbxproj"
VIEW_HEADER="$ROOT_DIR/BrandCapture/ViewController.h"
VIEW_CONTROLLER="$ROOT_DIR/BrandCapture/ViewController.mm"
MAIN_STORYBOARD="$ROOT_DIR/BrandCapture/Base.lproj/Main.storyboard"
FEATURES="$ROOT_DIR/BrandCapture/features.mm"
FEATURES_HEADER="$ROOT_DIR/BrandCapture/features.hpp"
INFO_PLIST="$ROOT_DIR/BrandCapture/Info.plist"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"
SCENE_KEYPOINT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-brandcapture-scene-keypoint-guard.md"
CAMERA_PERMISSION_PLAN="$ROOT_DIR/docs/plans/2026-06-09-brandcapture-camera-permission-copy.md"
PREVIEW_OUTLET_PLAN="$ROOT_DIR/docs/plans/2026-06-09-brandcapture-preview-outlet-guard.md"
IMAGE_PIXEL_DIMENSION_PLAN="$ROOT_DIR/docs/plans/2026-06-09-brandcapture-image-pixel-dimensions.md"
MAIN_CPP_TARGET_PLAN="$ROOT_DIR/docs/plans/2026-06-09-brandcapture-maincpp-target-prune.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
CAMERA_INACTIVE_PLAN="$ROOT_DIR/docs/plans/2026-06-10-brandcapture-camera-inactive-lifecycle.md"
FRAME_EXCEPTION_PLAN="$ROOT_DIR/docs/plans/2026-06-12-brandcapture-frame-exception-containment.md"

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
  "docs/plans/2026-06-09-brandcapture-storyboard-capture-outlets.md" \
  "docs/plans/2026-06-09-brandcapture-gray-conversion-colorspace.md" \
  "docs/plans/2026-06-09-brandcapture-scene-keypoint-guard.md" \
  "docs/plans/2026-06-09-brandcapture-camera-permission-copy.md" \
  "docs/plans/2026-06-09-brandcapture-preview-outlet-guard.md" \
  "docs/plans/2026-06-09-brandcapture-image-pixel-dimensions.md" \
  "docs/plans/2026-06-09-brandcapture-maincpp-target-prune.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-brandcapture-camera-inactive-lifecycle.md" \
  "docs/plans/2026-06-12-brandcapture-frame-exception-containment.md" \
  ".github/workflows/check.yml" \
  "BrandCapture.xcworkspace/contents.xcworkspacedata" \
  "BrandCapture.xcodeproj/project.pbxproj" \
  "BrandCapture/Base.lproj/Main.storyboard" \
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

if grep -Fq "main.cpp in Sources" "$PROJECT"; then
  printf '%s\n' "Desktop OpenCV sample main.cpp must not be compiled into the iOS target." >&2
  exit 1
fi

if ! grep -Fq "main.cpp */ = {isa = PBXFileReference" "$PROJECT"; then
  printf '%s\n' "Desktop OpenCV sample main.cpp should remain referenced for historical review." >&2
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

if ! grep -Fq "UIApplicationWillResignActiveNotification" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must stop camera capture when the application resigns active." >&2
  exit 1
fi

if [ "$(grep -Fc "name:UIApplicationWillResignActiveNotification" "$VIEW_CONTROLLER")" -ne 2 ]; then
  printf '%s\n' "ViewController must register and remove the same application-inactive notification." >&2
  exit 1
fi

if ! grep -Fq "selector:@selector(applicationWillResignActive:)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must register an application-inactive capture callback." >&2
  exit 1
fi

if ! grep -Fq -- "- (void)applicationWillResignActive:(NSNotification *)notification" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must isolate application-inactive handling in a lifecycle callback." >&2
  exit 1
fi

if ! grep -A5 -F -- "- (void)applicationWillResignActive:(NSNotification *)notification" "$VIEW_CONTROLLER" | grep -Fq "[self stopCaptureIfNeeded];"; then
  printf '%s\n' "Application-inactive handling must reuse centralized camera shutdown." >&2
  exit 1
fi

if ! grep -Fq "removeObserver:self" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must remove its application lifecycle observer during teardown." >&2
  exit 1
fi

if ! grep -Fq "updateCaptureControls" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must centralize capture button state." >&2
  exit 1
fi

if ! grep -Fq 'outlet property="startCaptureButton"' "$MAIN_STORYBOARD"; then
  printf '%s\n' "Storyboard must connect the Start capture button outlet." >&2
  exit 1
fi

if ! grep -Fq 'outlet property="stopCaptureButton"' "$MAIN_STORYBOARD"; then
  printf '%s\n' "Storyboard must connect the Stop capture button outlet." >&2
  exit 1
fi

if ! grep -Fq 'outlet property="toolbar"' "$MAIN_STORYBOARD"; then
  printf '%s\n' "Storyboard must connect the toolbar outlet." >&2
  exit 1
fi

if ! grep -Fq 'outlet property="imageView"' "$MAIN_STORYBOARD"; then
  printf '%s\n' "Storyboard must connect the camera preview image view outlet." >&2
  exit 1
fi

if ! grep -Fq "if (self.imageView == nil)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must guard missing camera preview outlet before camera setup." >&2
  exit 1
fi

if ! grep -Fq "initWithParentView:self.imageView" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must initialize CvVideoCamera from the guarded preview outlet." >&2
  exit 1
fi

if ! grep -Fq "startCaptureButton.enabled = isDetectorReady && !isCapturing;" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Start button must be disabled while capture is active." >&2
  exit 1
fi

if ! grep -Fq "stopCaptureButton.enabled = isDetectorReady && isCapturing;" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Stop button must stay disabled until capture is active." >&2
  exit 1
fi

if grep -Fq "stopCaptureButton.enabled = isDetectorReady;" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Stop button must not be enabled before capture starts." >&2
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

if ! grep -Fq "catch (const cv::Exception&)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must contain OpenCV frame-processing exceptions." >&2
  exit 1
fi

if grep -Fq "catch (...)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must not hide non-OpenCV frame-processing failures." >&2
  exit 1
fi

if ! grep -Fq "cv::line(image, corners[3], corners[0]" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must keep all four overlay edges inside frame processing." >&2
  exit 1
fi

process_line=$(grep -Fn -- "- (void)processImage:(cv::Mat&)image" "$VIEW_CONTROLLER" | cut -d: -f1)
try_line=$(grep -Fn "    try" "$VIEW_CONTROLLER" | cut -d: -f1)
detect_line=$(grep -Fn "cv::vector<cv::Point2f> corners = detect(image);" "$VIEW_CONTROLLER" | cut -d: -f1)
overlay_line=$(grep -Fn "cv::line(image, corners[3], corners[0]" "$VIEW_CONTROLLER" | cut -d: -f1)
catch_line=$(grep -Fn "catch (const cv::Exception&)" "$VIEW_CONTROLLER" | cut -d: -f1)
next_method_line=$(grep -Fn -- "- (void)didReceiveMemoryWarning" "$VIEW_CONTROLLER" | cut -d: -f1)

if [ "$process_line" -ge "$try_line" ] || [ "$try_line" -ge "$detect_line" ] || \
   [ "$detect_line" -ge "$overlay_line" ] || [ "$overlay_line" -ge "$catch_line" ] || \
   [ "$catch_line" -ge "$next_method_line" ]; then
  printf '%s\n' "OpenCV detection and overlay drawing must remain inside the processImage exception boundary." >&2
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

if ! grep -Fq "if (keypoints_scene.empty())" "$FEATURES"; then
  printf '%s\n' "features.mm must stop detection before descriptor extraction when no scene keypoints are found." >&2
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

image_guard_count=$(grep -F "if (image == nil || image.CGImage == nil)" "$VIEW_CONTROLLER" | wc -l | tr -d ' ')
if [ "$image_guard_count" -lt 2 ]; then
  printf '%s\n' "UIImage conversion helpers must guard nil images and missing CGImage state." >&2
  exit 1
fi

context_guard_count=$(grep -F "if (contextRef == NULL)" "$VIEW_CONTROLLER" | wc -l | tr -d ' ')
if [ "$context_guard_count" -lt 2 ]; then
  printf '%s\n' "UIImage conversion helpers must guard failed bitmap contexts." >&2
  exit 1
fi

if ! grep -Fq "CGColorSpaceCreateDeviceGray()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Grayscale UIImage conversion must use an explicit device-gray color space." >&2
  exit 1
fi

if ! grep -Fq "kCGImageAlphaNone);          // Bitmap info flags" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Grayscale UIImage conversion must use one-channel bitmap info." >&2
  exit 1
fi

if ! grep -Fq "CGColorSpaceRelease(colorSpace);" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Image conversion helpers must release created Core Graphics color spaces." >&2
  exit 1
fi

if ! grep -Fq "CGImageGetWidth(image.CGImage)" "$VIEW_CONTROLLER" ||
  ! grep -Fq "CGImageGetHeight(image.CGImage)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "UIImage conversion helpers must use CGImage pixel dimensions, not point dimensions." >&2
  exit 1
fi

if grep -Fq "image.size.width" "$VIEW_CONTROLLER" ||
  grep -Fq "image.size.height" "$VIEW_CONTROLLER"; then
  printf '%s\n' "UIImage conversion helpers must not derive OpenCV buffer sizes from point-based UIImage.size." >&2
  exit 1
fi

if ! grep -Fq "if (cvMat.empty() || cvMat.data == NULL" "$VIEW_CONTROLLER"; then
  printf '%s\n' "CVMat to UIImage conversion must guard empty Mat data." >&2
  exit 1
fi

if ! grep -Fq "if (provider == NULL)" "$VIEW_CONTROLLER" ||
  ! grep -Fq "if (imageRef == NULL)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "CVMat to UIImage conversion must guard failed Core Graphics objects." >&2
  exit 1
fi

if ! grep -Fq "NSCameraUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Camera permission usage description must be present." >&2
  exit 1
fi

if ! grep -Fq "BrandCapture uses the camera when you start capture to detect the bundled target image on device." "$INFO_PLIST"; then
  printf '%s\n' "Camera permission text must describe user-started local target-image detection." >&2
  exit 1
fi

if grep -Fq "NSMicrophoneUsageDescription" "$INFO_PLIST" || grep -Fq "NSLocationWhenInUseUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "BrandCapture must not declare unused microphone or location permission text." >&2
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

if ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the GitHub Actions baseline." >&2
  exit 1
fi

if ! grep -Fq "Stop remains disabled until capture is active" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document capture control state." >&2
  exit 1
fi

if ! grep -Fq "storyboard outlets are wired" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document capture control outlet wiring." >&2
  exit 1
fi

if ! grep -Fq "preview image outlet is validated before camera setup" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the camera preview outlet guard." >&2
  exit 1
fi

if ! grep -Fq "grayscale conversion uses an explicit device-gray color space" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document grayscale image conversion ownership." >&2
  exit 1
fi

if ! grep -Fq "skips descriptor extraction when no scene keypoints are" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the empty scene-keypoint detection guard." >&2
  exit 1
fi

if ! grep -Fq "camera permission text describes user-started local target-image detection" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the camera permission copy baseline." >&2
  exit 1
fi

if ! grep -Fq "UIImage conversions use CGImage pixel dimensions" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document pixel-dimension image conversion." >&2
  exit 1
fi

if ! grep -Fq "desktop OpenCV sample stays out of the iOS target sources" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the desktop main.cpp target exclusion." >&2
  exit 1
fi

if ! grep -Fq "camera callback contains OpenCV frame-processing exceptions" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document camera frame exception containment." >&2
  exit 1
fi

if ! grep -Fq "Camera capture stops when the application resigns active" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the inactive camera lifecycle guard." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile must remain available as the root verification entry point." >&2
  exit 1
fi

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$ROOT_DIR/Makefile" || \
   ! grep -Fq '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the baseline relative to its own repository root." >&2
  exit 1
fi

if ! grep -Fq '"$(ROOT)BrandCapture.xcworkspace"' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must pass a repository-rooted workspace path to xcodebuild." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-09-brandcapture-storyboard-capture-outlets.md"; then
  printf '%s\n' "Storyboard capture outlet plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-brandcapture-storyboard-capture-outlets.md"; then
  printf '%s\n' "Storyboard capture outlet plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-09-brandcapture-gray-conversion-colorspace.md"; then
  printf '%s\n' "Grayscale conversion colorspace plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-brandcapture-gray-conversion-colorspace.md"; then
  printf '%s\n' "Grayscale conversion colorspace plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$SCENE_KEYPOINT_PLAN"; then
  printf '%s\n' "Scene keypoint guard plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$SCENE_KEYPOINT_PLAN"; then
  printf '%s\n' "Scene keypoint guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CAMERA_PERMISSION_PLAN"; then
  printf '%s\n' "Camera permission copy plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$CAMERA_PERMISSION_PLAN"; then
  printf '%s\n' "Camera permission copy plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PREVIEW_OUTLET_PLAN"; then
  printf '%s\n' "Camera preview outlet guard plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$PREVIEW_OUTLET_PLAN"; then
  printf '%s\n' "Camera preview outlet guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$IMAGE_PIXEL_DIMENSION_PLAN"; then
  printf '%s\n' "Image pixel dimension plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$IMAGE_PIXEL_DIMENSION_PLAN"; then
  printf '%s\n' "Image pixel dimension plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$MAIN_CPP_TARGET_PLAN"; then
  printf '%s\n' "main.cpp target prune plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$MAIN_CPP_TARGET_PLAN"; then
  printf '%s\n' "main.cpp target prune plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW" || \
   ! grep -Fq "run: make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions check workflow must run the make check baseline." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$CI_WORKFLOW" || ! grep -Fq "contents: read" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions check workflow must keep repository access read-only." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" || ! grep -Fq "timeout-minutes: 5" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions check workflow must support bounded manual verification." >&2
  exit 1
fi

if ! grep -Fq "runs-on: ubuntu-24.04" "$CI_WORKFLOW" || ! grep -Fq "cancel-in-progress: true" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must use a stable runner and cancel superseded checks." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "BrandCapture CI baseline plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CAMERA_INACTIVE_PLAN" || ! grep -Fq "make check" "$CAMERA_INACTIVE_PLAN"; then
  printf '%s\n' "BrandCapture camera inactive plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$FRAME_EXCEPTION_PLAN" || ! grep -Fq "make check" "$FRAME_EXCEPTION_PLAN"; then
  printf '%s\n' "BrandCapture frame exception plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "BrandCapture camera baseline checks passed."
