## BrandCapture

An iOS App that automatically detects "brand" images.

<img src="BrandCapture/screenshot.png" />

## Project Shape

- Open the CocoaPods workspace: `BrandCapture.xcworkspace`
- Main app target: `BrandCapture`
- OpenCV dependency: `OpenCV 2.4.9` from `Podfile.lock`
- Target image: `BrandCapture/clipper.jpg`
- Objective-C++ camera controller: `BrandCapture/ViewController.mm`
- Objective-C++ OpenCV feature matcher: `BrandCapture/features.mm`

## Verify

Run the SDK-free baseline check:

```sh
scripts/check-baseline.sh
```

When Xcode is available, inspect and build through the workspace:

```sh
xcodebuild -list -workspace BrandCapture.xcworkspace
xcodebuild -workspace BrandCapture.xcworkspace -scheme BrandCapture -sdk iphonesimulator build
```

## Privacy And Runtime Notes

The app processes camera frames locally and requires
`NSCameraUsageDescription`. The current baseline keeps OpenCV frame diagnostics
out of stdout, avoids drawing detection overlays until the target image setup
succeeds, and keeps the camera controller and feature matcher compiled as
Objective-C++.

Future work should modernize OpenCV and CocoaPods, add simulator/device camera
verification, and make target-image replacement steps explicit.
