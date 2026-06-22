#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CXX=${CXX:-c++}

if ! command -v "$CXX" >/dev/null 2>&1; then
  printf '%s\n' "C++ compiler not found: $CXX" >&2
  exit 1
fi

BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/brandcapture-camera-mutations.XXXXXX")
cleanup() {
  rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

reject_state_mutation() {
  name=$1
  mutation=$2
  mutation_dir="$BUILD_DIR/$name"
  mkdir -p "$mutation_dir"
  cp "$ROOT_DIR/BrandCapture/CaptureSessionState.hpp" "$mutation_dir/"
  perl -0pi -e "$mutation" "$mutation_dir/CaptureSessionState.hpp"
  "$CXX" -std=c++11 -Wall -Wextra -Wno-unused-parameter -pedantic \
    -I"$mutation_dir" \
    "$ROOT_DIR/Tests/CaptureSessionStateTests.cpp" \
    -o "$mutation_dir/tests"
  if "$mutation_dir/tests" >"$mutation_dir/output.log" 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    exit 1
  fi
  printf '%s\n' "Rejected state mutation: $name"
}

reject_integration_mutation() {
  name=$1
  mutation=$2
  mutation_dir="$BUILD_DIR/$name"
  mkdir -p "$mutation_dir"
  cp "$ROOT_DIR/BrandCapture/ViewController.h" "$mutation_dir/ViewController.h"
  cp "$ROOT_DIR/BrandCapture/ViewController.mm" "$mutation_dir/ViewController.mm"
  perl -0pi -e "$mutation" "$mutation_dir/ViewController.mm"
  if VIEW_CONTROLLER_HEADER="$mutation_dir/ViewController.h" \
     VIEW_CONTROLLER_SOURCE="$mutation_dir/ViewController.mm" \
     "$ROOT_DIR/scripts/test-camera-authorization-integration.sh" \
       >"$mutation_dir/output.log" 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    exit 1
  fi
  printf '%s\n' "Rejected integration mutation: $name"
}

reject_state_mutation stale-generation \
  's/generation != generation_ \|\| phase_ != CapturePhase::Starting/phase_ != CapturePhase::Starting/'
reject_state_mutation optimistic-start \
  's/phase_ = CapturePhase::Starting;\n            transition\.startSession = true;/phase_ = CapturePhase::Active;\n            transition.startSession = true;/'
reject_state_mutation denied-start \
  's/authorization == CameraAuthorization::Authorized/authorization != CameraAuthorization::NotDetermined/'
reject_state_mutation no-lifecycle-invalidation \
  's/(CaptureTransition stopForLifecycle\(\).*?phase_ = CapturePhase::Idle;)\n        advanceGeneration\(\);/$1/s'
reject_state_mutation prompt-resign-cancels-intent \
  's/(if \(phase_ == CapturePhase::Authorizing\)\n        \{).*?return transition;\n        \}/$1\n            return stopForLifecycle();\n        }/s'
reject_state_mutation prompt-grant-starts-while-inactive \
  's/phase_ = CapturePhase::AuthorizingGrantedInactive;\n                return transition;/phase_ = CapturePhase::Starting;\n                transition.startSession = true;\n                return transition;/'
reject_state_mutation background-preserves-authorization \
  's/(CaptureTransition applicationDidEnterBackground\(\)\n    \{)\n        return stopForLifecycle\(\);/$1\n        CaptureTransition transition;\n        transition.generation = generation_;\n        return transition;/'
reject_state_mutation foreground-loses-grant \
  's/transition\.startSession = true;\n            transition\.refreshControls = true;/transition.refreshControls = true;/'
reject_state_mutation stale-prompt-generation \
  's/if \(generation != generation_ \|\| !authorizing\)/if (!authorizing)/'
reject_state_mutation no-interruption-cleanup \
  's/(CaptureTransition sessionInterrupted\(unsigned long generation\).*?terminalTransition\(generation, )true/$1false/s'
reject_integration_mutation no-authorization-gate \
  's/authorizationStatusForMediaType:AVMediaTypeVideo/authorizationStatusForMediaType:AVMediaTypeAudio/'
reject_integration_mutation trusts-opencv-running \
  's/AVCaptureSession \*session = self\.videoCamera\.captureSession;/BOOL proof = self.videoCamera.running;\n    (void)proof;\n    AVCaptureSession *session = self.videoCamera.captureSession;/'
reject_integration_mutation ignores-all-resign-active \
  's/captureState\.applicationWillResignActive\(\)/brandcapture::CaptureTransition()/g'
reject_integration_mutation omits-background-cancellation \
  's/captureState\.applicationDidEnterBackground\(\)/brandcapture::CaptureTransition()/g'
reject_integration_mutation foreground-does-not-start \
  's/(- \(void\)applicationDidBecomeActive:\(NSNotification \*\)notification\n\{.*?)(if \(transition\.startSession\))/$1if (false)/s'

printf '%s\n' "Camera authorization mutation checks passed"
