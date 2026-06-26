# BrandCapture Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so camera, reference, OpenCV, geometry, and overlay evidence
cannot be transferred to a different detector implementation.

## Evidence Rules

- Use a synthetic reference image and controlled scene that contain no people,
  addresses, account data, customer assets, or sensitive surroundings.
- Record the Xcode version, iOS version, simulator or device class, camera mode,
  reference fixture, result, and evidence identifier.
- Do not include device identifiers, camera captures, room imagery, brand or
  customer data, unrelated notifications, signing details, or raw logs.
- Store durable evidence outside git. Link only a sanitized run, redacted
  screenshot, or short non-image log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Build and Fixture Prerequisites

- Build `BrandCapture.xcworkspace` from the same exact commit recorded below, preserving OpenCV 2.4.9 and the locked CocoaPods graph.
- Use the bundled `BrandCapture/clipper.jpg` only as a controlled synthetic reference or replace it through a separately reviewed asset-and-code change.
- A simulator can provide build, launch, storyboard, and control-state evidence only; simulator-only results cannot pass camera, permission, live-frame, overlay, orientation, or sustained-capture rows.
- Use a physical iOS device for camera rows and keep people, addresses, customer assets, account data, and private surroundings out of the scene.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Xcode / iOS | `not run` |
| Device or simulator | `not run` |
| Camera mode / orientation | `not run` |
| Synthetic reference fixture | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Camera permission denied | First-prompt denial returns to idle after foregrounding without starting capture. | `not run` | `not run` |
| Camera permission granted | One Start tap survives the first system prompt and starts the preview only after the app becomes active. | `not run` | `not run` |
| Background during permission prompt | Entering the background cancels the attempt; foregrounding and a late grant do not auto-start capture. | `not run` | `not run` |
| Stale permission callback | A callback from an older prompt cannot claim or start a newer authorization attempt. | `not run` | `not run` |
| Reference setup | A valid synthetic reference publishes image, keypoints, and descriptors atomically. | `not run` | `not run` |
| Invalid reference setup | Missing image, empty keypoints, or empty descriptors leaves no partial detector state. | `not run` | `not run` |
| No scene keypoints | Empty live-frame features return no detection or overlay. | `not run` | `not run` |
| Exact descriptor match | Zero-distance matches remain eligible for homography validation. | `not run` | `not run` |
| Non-finite match distance | NaN or infinite matcher distances fail closed before threshold and homography input. | `not run` | `not run` |
| Degenerate quadrilateral | Collapsed, repeated, non-finite, or too-small corners produce no overlay. | `not run` | `not run` |
| Non-convex quadrilateral | Concave or self-crossing projected corners are rejected before drawing. | `not run` | `not run` |
| Valid overlay | A valid synthetic target produces one stable convex overlay aligned with the preview. | `not run` | `not run` |
| Capture controls | Start, Stop, and toolbar state track detector and camera ownership without conflicting actions. | `not run` | `not run` |
| Orientation change | Rotation preserves preview alignment or safely suppresses stale overlay geometry. | `not run` | `not run` |
| Low light and motion blur | Weak frames fail closed without stale overlays, crashes, or runaway processing. | `not run` | `not run` |
| Background and foreground | Active capture stops on inactivation; foregrounding never restarts a background-cancelled attempt. | `not run` | `not run` |
| Sustained capture | A bounded smoke interval remains responsive without stale overlays or unbounded memory growth. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale detector, camera, reference, frame, or overlay state. | `not run` | `not run` |

## Current Status

No Xcode build, iOS simulator, physical camera, OpenCV framework runtime, or
live overlay scenario was executed for this checklist. Treat every Xcode, OpenCV, camera, overlay, and device row as unexecuted
until evidence is attached to the exact commit.
