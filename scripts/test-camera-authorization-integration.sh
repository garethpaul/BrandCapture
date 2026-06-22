#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
HEADER=${VIEW_CONTROLLER_HEADER:-"$ROOT_DIR/BrandCapture/ViewController.h"}
SOURCE=${VIEW_CONTROLLER_SOURCE:-"$ROOT_DIR/BrandCapture/ViewController.mm"}

require_source() {
  marker=$1
  message=$2
  if ! grep -Fq "$marker" "$SOURCE"; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

require_source '#include "CaptureSessionState.hpp"' \
  "ViewController must use the app-owned capture session state machine."
require_source 'authorizationStatusForMediaType:AVMediaTypeVideo' \
  "ViewController must read camera authorization before startup."
require_source 'requestAccessForMediaType:AVMediaTypeVideo' \
  "ViewController must request access only through AVFoundation."
require_source 'dispatch_async(dispatch_get_main_queue()' \
  "Authorization callbacks must return to the main thread."
require_source 'AVCaptureSessionDidStartRunningNotification' \
  "Active capture must require a session-start notification."
require_source 'AVCaptureSessionDidStopRunningNotification' \
  "Capture state must observe external session stops."
require_source 'AVCaptureSessionWasInterruptedNotification' \
  "Capture state must observe session interruptions."
require_source 'AVCaptureSessionRuntimeErrorNotification' \
  "Capture state must observe runtime errors."
require_source 'sessionDidStart(generation)' \
  "Session-start callbacks must carry their capture generation."
require_source 'sessionStartupFailed(generation)' \
  "Failed OpenCV setup must reconcile app-owned state."
require_source 'captureSessionLoaded' \
  "Startup failure detection must inspect session creation without treating it as success."
require_source 'captureState.controls(isDetectorReady)' \
  "Capture controls must derive from app-owned state."
require_source 'UIApplicationDidBecomeActiveNotification' \
  "Permission-prompt capture intent must resume only after the app becomes active."
require_source 'UIApplicationDidEnterBackgroundNotification' \
  "Authorization intent must be cancelled when the app genuinely backgrounds."
require_source 'captureState.applicationWillResignActive()' \
  "Will-resign-active handling must distinguish the permission prompt from lifecycle cancellation."
require_source 'captureState.applicationDidBecomeActive()' \
  "Did-become-active handling must resume a granted permission prompt."
require_source 'captureState.applicationDidEnterBackground()' \
  "Did-enter-background handling must invalidate authorization intent."

if grep -Fq 'videoCamera.running' "$SOURCE"; then
  printf '%s\n' "OpenCV running must not be used as startup proof." >&2
  exit 1
fi

if grep -Fq 'isCapturing' "$HEADER" "$SOURCE"; then
  printf '%s\n' "Legacy optimistic isCapturing state must be removed." >&2
  exit 1
fi

if [ "$(grep -Fc 'name:UIApplicationWillResignActiveNotification' "$SOURCE")" -ne 2 ] || \
   [ "$(grep -Fc 'name:UIApplicationDidBecomeActiveNotification' "$SOURCE")" -ne 2 ] || \
   [ "$(grep -Fc 'name:UIApplicationDidEnterBackgroundNotification' "$SOURCE")" -ne 2 ]; then
  printf '%s\n' "Controller must register and remove each paired application lifecycle observer." >&2
  exit 1
fi

did_become_active_method=$(awk '
  /^- \(void\)applicationDidBecomeActive:.*notification$/ { capture = 1 }
  capture && /^- \(void\)applicationDidEnterBackground:.*notification$/ { exit }
  capture { print }
' "$SOURCE")

if ! printf '%s\n' "$did_become_active_method" | grep -Fq 'transition.startSession' || \
   ! printf '%s\n' "$did_become_active_method" | grep -Fq '[self startCaptureSessionForGeneration:transition.generation];'; then
  printf '%s\n' "Foreground return must resume only the state-approved authorization attempt." >&2
  exit 1
fi

did_enter_background_method=$(awk '
  /^- \(void\)applicationDidEnterBackground:.*notification$/ { capture = 1 }
  capture && /^- \(void\)stopCaptureIfNeeded$/ { exit }
  capture { print }
' "$SOURCE")

if ! printf '%s\n' "$did_enter_background_method" | grep -Fq 'captureState.applicationDidEnterBackground()'; then
  printf '%s\n' "Genuine backgrounding must invalidate the app-owned authorization generation." >&2
  exit 1
fi

stop_method=$(awk '
  /^- \(void\)stopCaptureIfNeeded$/ { capture = 1 }
  capture && /^- \(void\)updateCaptureControls$/ { exit }
  capture { print }
' "$SOURCE")

state_stop_line=$(printf '%s\n' "$stop_method" | grep -nF 'captureState.stopForLifecycle()' | cut -d: -f1)
camera_stop_line=$(printf '%s\n' "$stop_method" | grep -nF '[self.videoCamera stop];' | cut -d: -f1)
if [ -z "$state_stop_line" ] || [ -z "$camera_stop_line" ] || \
  [ "$state_stop_line" -ge "$camera_stop_line" ]; then
  printf '%s\n' "Lifecycle stop must invalidate app state before stopping OpenCV." >&2
  exit 1
fi

printf '%s\n' "Camera authorization integration checks passed"
