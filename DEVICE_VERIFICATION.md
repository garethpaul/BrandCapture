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
| Camera permission denied | Denial leaves capture disabled and the app usable without collecting frames. | `not run` | `not run` |
| Camera permission granted | User-started capture opens the preview only while the app is active. | `not run` | `not run` |
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
| Background and foreground | Inactivation stops capture and foregrounding requires an owned active capture state. | `not run` | `not run` |
| Sustained capture | A bounded smoke interval remains responsive without stale overlays or unbounded memory growth. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale detector, camera, reference, frame, or overlay state. | `not run` | `not run` |

## Current Status

No Xcode build, iOS simulator, physical camera, OpenCV framework runtime, or
live overlay scenario was executed for this checklist. Treat every Xcode, OpenCV, camera, overlay, and device row as unexecuted
until evidence is attached to the exact commit.
