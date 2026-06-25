# BrandCapture Camera Authorization Repair Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Keep BrandCapture controls truthful across camera authorization, startup, interruption, failure, stop, and stale asynchronous callbacks.

**Architecture:** Add a small app-owned portable state machine with `idle`, authorization-prompt, `starting`, and `active` phases plus a monotonically increasing generation. `ViewController` translates AVFoundation authorization, paired application lifecycle, and capture-session callbacks into generation-tagged transitions, performs every UI/state transition on the main thread, and treats only `AVCaptureSessionDidStartRunningNotification` as startup proof. A prompt-time inactive state can resume only on `UIApplicationDidBecomeActiveNotification`; `UIApplicationDidEnterBackgroundNotification` cancels it. OpenCV's `running` flag is never used as proof.

**Tech Stack:** Objective-C++, AVFoundation, vendored OpenCV 2.4.9, header-only portable C++, POSIX shell tests.

---

### Task 1: Portable State Machine

**Files:**
- Create: `Tests/CaptureSessionStateTests.cpp`
- Create: `scripts/test-capture-session-state.sh`
- Create: `BrandCapture/CaptureSessionState.hpp`
- Modify: `Makefile`

**Steps:**
1. Add deterministic tests for denied, restricted, delayed grant/denial, permission-prompt foreground return, genuine background cancellation, authorized startup success/failure, interruption, runtime error, session stop, lifecycle stop ordering, and stale callbacks.
2. Run `scripts/test-capture-session-state.sh` and capture the missing-header RED result.
3. Implement the minimum header-only transition model.
4. Run the focused state tests and existing portable tests to GREEN.

### Task 2: Controller Integration Contract

**Files:**
- Create: `scripts/test-camera-authorization-integration.sh`
- Modify: `Makefile`
- Modify: `BrandCapture/ViewController.h`
- Modify: `BrandCapture/ViewController.mm`
- Modify: `scripts/check-baseline.sh`

**Steps:**
1. Add a source-level integration test requiring authorization gating, generation capture, main-thread callback routing, paired foreground/background lifecycle handling, session-start proof, terminal session notifications, and state-first lifecycle stop ordering.
2. Run the integration test against the baseline and capture RED.
3. Add the portable state to the controller, authorization request path, per-attempt notification observers, and terminal reconciliation.
4. Keep controls derived from state and never from `CvVideoCamera.running`.
5. Run focused integration and portable tests to GREEN.

### Task 3: Validation and Report

**Files:**
- Create locally: `report.md`

**Steps:**
1. Run `make lint`, `make test`, shell syntax checks, plist/XML validation, and `make check`.
2. Run focused source/test mutations and hostile prompt, background, stale-generation, and terminal transition sequences.
3. Verify the expected current-Xcode `libarclite` link limitation remains visible.
4. Commit repository changes locally, write the exact parent/head/tree and evidence report, and leave publication disabled.
