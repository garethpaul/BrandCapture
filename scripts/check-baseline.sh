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
ZERO_DISTANCE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-brandcapture-zero-distance-matches.md"
REFERENCE_SETUP_PLAN="$ROOT_DIR/docs/plans/2026-06-13-brandcapture-reference-setup.md"
DEGENERATE_CORNERS_PLAN="$ROOT_DIR/docs/plans/2026-06-13-brandcapture-degenerate-corners.md"
FINITE_MATCH_DISTANCE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-brandcapture-finite-match-distance.md"
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-boundary.md"

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
  "docs/plans/2026-06-13-brandcapture-zero-distance-matches.md" \
  "docs/plans/2026-06-13-brandcapture-reference-setup.md" \
  "docs/plans/2026-06-13-brandcapture-degenerate-corners.md" \
  "docs/plans/2026-06-12-checkout-credential-boundary.md" \
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

unique_line_number() {
  pattern=$1
  description=$2
  matches=$(grep -Fn -- "$pattern" "$VIEW_CONTROLLER" || true)
  match_count=$(printf '%s\n' "$matches" | awk 'NF { count++ } END { print count + 0 }')

  if [ "$match_count" -ne 1 ]; then
    printf '%s\n' "ViewController must contain exactly one $description marker." >&2
    exit 1
  fi

  printf '%s\n' "$matches" | cut -d: -f1
}

process_line=$(unique_line_number "- (void)processImage:(cv::Mat&)image" "processImage")
try_line=$(unique_line_number "    try" "frame-processing try")
detect_line=$(unique_line_number "cv::vector<cv::Point2f> corners = detect(image);" "frame detection")
overlay_line=$(unique_line_number "cv::line(image, corners[3], corners[0]" "final overlay edge")
catch_line=$(unique_line_number "catch (const cv::Exception&)" "OpenCV catch")
next_method_line=$(unique_line_number "- (void)didReceiveMemoryWarning" "post-processing method")

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

setup_body=$(sed -n '/^bool setup(NSString\* filename)/,/^}/p' "$FEATURES")
for setup_contract in \
  "clearObjectState();" \
  "try {" \
  "Mat candidateObject = imread" \
  "std::vector<KeyPoint> candidateKeypoints;" \
  "detector.detect(candidateObject, candidateKeypoints);" \
  "Mat candidateDescriptors;" \
  "extractor.compute(candidateObject, candidateKeypoints, candidateDescriptors);" \
  "if (candidateDescriptors.empty())" \
  "img_object = candidateObject;" \
  "keypoints_object = candidateKeypoints;" \
  "descriptors_object = candidateDescriptors;" \
  "catch (const cv::Exception&)"; do
  if ! printf '%s\n' "$setup_body" | grep -Fq "$setup_contract"; then
    printf '%s\n' "Reference setup must preserve its atomic OpenCV contract: $setup_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "static void clearObjectState()" "$FEATURES" || \
   ! grep -Fq "img_object.release();" "$FEATURES" || \
   ! grep -Fq "keypoints_object.clear();" "$FEATURES" || \
   ! grep -Fq "descriptors_object.release();" "$FEATURES"; then
  printf '%s\n' "Reference setup must centralize published detector-state clearing." >&2
  exit 1
fi

if printf '%s\n' "$setup_body" | grep -Fq "detector.detect( img_object, keypoints_object )" || \
   printf '%s\n' "$setup_body" | grep -Fq "extractor.compute( img_object, keypoints_object, descriptors_object )"; then
  printf '%s\n' "Reference setup must not mutate published detector state before validation." >&2
  exit 1
fi

setup_clear_line=$(printf '%s\n' "$setup_body" | grep -nF "clearObjectState();" | head -n 1 | cut -d: -f1)
setup_filename_guard_line=$(printf '%s\n' "$setup_body" | grep -nF "if (filename == nil)" | cut -d: -f1)
setup_try_line=$(printf '%s\n' "$setup_body" | grep -nF "try {" | cut -d: -f1)
setup_descriptor_guard_line=$(printf '%s\n' "$setup_body" | grep -nF "if (candidateDescriptors.empty())" | cut -d: -f1)
setup_publish_image_line=$(printf '%s\n' "$setup_body" | grep -nF "img_object = candidateObject;" | cut -d: -f1)
setup_publish_keypoints_line=$(printf '%s\n' "$setup_body" | grep -nF "keypoints_object = candidateKeypoints;" | cut -d: -f1)
setup_publish_descriptors_line=$(printf '%s\n' "$setup_body" | grep -nF "descriptors_object = candidateDescriptors;" | cut -d: -f1)
setup_success_line=$(printf '%s\n' "$setup_body" | grep -nF "return true;" | cut -d: -f1)
setup_catch_line=$(printf '%s\n' "$setup_body" | grep -nF "catch (const cv::Exception&)" | cut -d: -f1)

for setup_line in "$setup_clear_line" "$setup_filename_guard_line" "$setup_try_line" \
  "$setup_descriptor_guard_line" "$setup_publish_image_line" "$setup_publish_keypoints_line" \
  "$setup_publish_descriptors_line" "$setup_success_line" "$setup_catch_line"; do
  if [ -z "$setup_line" ]; then
    printf '%s\n' "Reference setup ordering markers must remain unique and present." >&2
    exit 1
  fi
done

if [ "$setup_clear_line" -ge "$setup_filename_guard_line" ] || \
   [ "$setup_filename_guard_line" -ge "$setup_try_line" ] || \
   [ "$setup_try_line" -ge "$setup_descriptor_guard_line" ] || \
   [ "$setup_descriptor_guard_line" -ge "$setup_publish_image_line" ] || \
   [ "$setup_publish_image_line" -ge "$setup_publish_keypoints_line" ] || \
   [ "$setup_publish_keypoints_line" -ge "$setup_publish_descriptors_line" ] || \
   [ "$setup_publish_descriptors_line" -ge "$setup_success_line" ] || \
   [ "$setup_success_line" -ge "$setup_catch_line" ]; then
  printf '%s\n' "Reference setup must clear, stage, validate, publish, and catch in fail-closed order." >&2
  exit 1
fi

if ! grep -Fq "stages reference image," "$ROOT_DIR/README.md" || \
   ! grep -Fq "keypoint, and descriptor state locally" "$ROOT_DIR/README.md" || \
   ! grep -Fq "2026-06-13-brandcapture-reference-setup.md" "$ROOT_DIR/README.md" || \
   ! grep -Fq "atomic reference-detector setup" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "Cleared stale reference state and staged OpenCV setup locally" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Atomic reference setup documentation and plan links must remain checked in." >&2
  exit 1
fi

for setup_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make check" \
  "isolated hostile mutations were rejected" \
  "no xcodebuild, OpenCV execution, simulator camera"; do
  if ! grep -Fq "$setup_plan_contract" "$REFERENCE_SETUP_PLAN"; then
    printf '%s\n' "Atomic reference setup plan must record completed verification: $setup_plan_contract" >&2
    exit 1
  fi
done

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

finite_distance_guard='if (!std::isfinite(dist))'
minimum_distance_update='if( dist < min_dist ) min_dist = dist;'
if [ "$(grep -Fc "$finite_distance_guard" "$FEATURES")" -ne 1 ] ||
  [ "$(grep -Fc "$minimum_distance_update" "$FEATURES")" -ne 1 ]; then
  printf '%s\n' "features.mm must retain one finite-distance guard and minimum-distance update." >&2
  exit 1
fi

finite_distance_guard_line=$(grep -nF "$finite_distance_guard" "$FEATURES" | cut -d: -f1)
minimum_distance_update_line=$(grep -nF "$minimum_distance_update" "$FEATURES" | cut -d: -f1)
if [ -z "$finite_distance_guard_line" ] || [ -z "$minimum_distance_update_line" ] ||
  [ "$finite_distance_guard_line" -ge "$minimum_distance_update_line" ] ||
  ! sed -n "${finite_distance_guard_line},$((finite_distance_guard_line + 3))p" "$FEATURES" |
    grep -Fq "return emptyCorners();"; then
  printf '%s\n' "features.mm must reject non-finite match distances before threshold calculation." >&2
  exit 1
fi

inclusive_match_boundary='if( matches[i].distance <= kGoodMatchDistanceMultiplier*min_dist )'
if [ "$(grep -Fc 'static const double kGoodMatchDistanceMultiplier = 3.0;' "$FEATURES")" -ne 1 ] || \
   [ "$(grep -Fc "$inclusive_match_boundary" "$FEATURES")" -ne 1 ] || \
   grep -Fq 'matches[i].distance < kGoodMatchDistanceMultiplier*min_dist' "$FEATURES"; then
  printf '%s\n' "features.mm must retain descriptor matches at the inclusive three-times-minimum threshold." >&2
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

if [ "$(grep -Fc 'static const double kMinimumProjectedArea = 1.0;' "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc 'double areaTwice = 0.0;' "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc 'size_t next = (i + 1) % corners.size();' "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc 'areaTwice += static_cast<double>(corners[i].x) * corners[next].y -' "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc 'static_cast<double>(corners[next].x) * corners[i].y;' "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc 'return std::fabs(areaTwice) >= 2.0 * kMinimumProjectedArea;' "$FEATURES")" -ne 1 ]; then
  printf '%s\n' "features.mm must reject projected quadrilaterals below one square pixel." >&2
  exit 1
fi

transform_marker="perspectiveTransform( obj_corners, scene_corners, H);"
geometry_guard_marker="if (!hasValidCorners(scene_corners))"
corner_return_marker="return scene_corners;"
if [ "$(grep -Fc "$transform_marker" "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc "$geometry_guard_marker" "$FEATURES")" -ne 1 ] || \
  [ "$(grep -Fc "$corner_return_marker" "$FEATURES")" -ne 1 ]; then
  printf '%s\n' "Projected-corner ordering markers must remain unique and present." >&2
  exit 1
fi

transform_line=$(grep -nF "$transform_marker" "$FEATURES" | cut -d: -f1)
geometry_guard_line=$(grep -nF "$geometry_guard_marker" "$FEATURES" | cut -d: -f1)
corner_return_line=$(grep -nF "$corner_return_marker" "$FEATURES" | cut -d: -f1)
if [ -z "$transform_line" ] || [ -z "$geometry_guard_line" ] || [ -z "$corner_return_line" ] || \
  [ "$transform_line" -ge "$geometry_guard_line" ] || [ "$geometry_guard_line" -ge "$corner_return_line" ]; then
  printf '%s\n' "detect() must validate projected geometry before returning corners." >&2
  exit 1
fi

if [ "$(grep -Fc 'if (!hasValidCorners(corners))' "$VIEW_CONTROLLER")" -ne 1 ]; then
  printf '%s\n' "ViewController must retain corner validation before overlay drawing." >&2
  exit 1
fi

if ! grep -Fq "one-square-pixel projected-area guard" "$ROOT_DIR/README.md" || \
  ! grep -Fq "non-degenerate projected geometry" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "degenerate projected quadrilaterals" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq "R1. Four finite projected corners" "$DEGENERATE_CORNERS_PLAN"; then
  printf '%s\n' "Projected-corner geometry documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for geometry_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make verify" \
  "isolated hostile source mutations were rejected" \
  "no xcodebuild, OpenCV execution, simulator camera"; do
  if ! grep -Fq "$geometry_plan_contract" "$DEGENERATE_CORNERS_PLAN"; then
    printf '%s\n' "Degenerate-corner plan must record completed verification: $geometry_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "exact descriptor matches" "$ROOT_DIR/README.md" || \
   ! grep -Fq "inclusive descriptor-match threshold" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "zero-distance descriptor matches" "$ROOT_DIR/CHANGES.md" || \
   ! grep -Fq "R1. A descriptor whose distance equals the computed threshold" "$ZERO_DISTANCE_PLAN"; then
  printf '%s\n' "Exact-match boundary documentation and plan contracts must remain checked in." >&2
  exit 1
fi

if ! grep -Fq "non-finite matcher distances" "$ROOT_DIR/README.md" || \
  ! grep -Fq "finite matcher distances" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "non-finite descriptor-match distances" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq 'R1. `detect()` must fail closed when any matcher distance is not finite.' "$FINITE_MATCH_DISTANCE_PLAN"; then
  printf '%s\n' "Finite match-distance documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for finite_distance_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make verify" \
  "isolated hostile mutations were rejected" \
  "no xcodebuild, OpenCV execution, simulator camera"; do
  if ! grep -Fq "$finite_distance_plan_contract" "$FINITE_MATCH_DISTANCE_PLAN"; then
    printf '%s\n' "Finite match-distance plan must record completed verification: $finite_distance_plan_contract" >&2
    exit 1
  fi
done

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

if [ "$(grep -Fc 'uses: actions/checkout@' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Fc 'persist-credentials: false' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$CI_WORKFLOW" | grep -Ev '@[0-9a-f]{40}([[:space:]]+#.*)?$' >/dev/null; then
  printf '%s\n' "The only checkout step must be immutable and must not persist credentials." >&2
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

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Ec '^[[:space:]]+contents:[[:space:]]*read[[:space:]]*$' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -Eq 'write-all|:[[:space:]]*write|continue-on-error:[[:space:]]*true|if:[[:space:]]*false' "$CI_WORKFLOW" || \
   [ "$(grep -Ec '^[[:space:]]*(-[[:space:]]+)?run:' "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "Check workflow must keep exact read-only permissions and one required command." >&2
  exit 1
fi

if [ ! -f "$CHECKOUT_CREDENTIAL_PLAN" ] || \
   ! grep -Fq "status: completed" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "make check" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "external working directory" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout credential plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "does not persist checkout credentials" "$ROOT_DIR/README.md" || \
   ! grep -Fq "non-persisted checkout token" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "non-persisted checkout credentials" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "checkout credential persistence" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Repository guidance must document the checkout credential boundary." >&2
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
