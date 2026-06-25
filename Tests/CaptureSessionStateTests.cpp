#include "CaptureSessionState.hpp"

#include <cstdlib>
#include <iostream>

namespace {

int failures = 0;

void expect(bool condition, const char *message)
{
    if (!condition)
    {
        std::cerr << "FAIL: " << message << std::endl;
        ++failures;
    }
}

void expectIdle(const brandcapture::CaptureSessionState& state,
                const char *context)
{
    expect(state.phase() == brandcapture::CapturePhase::Idle, context);
    brandcapture::CaptureControls controls = state.controls(true);
    expect(controls.startEnabled, "idle state enables Start when detector is ready");
    expect(!controls.stopEnabled, "idle state disables Stop");
}

void testDeniedAndRestrictedRemainIdle()
{
    brandcapture::CaptureSessionState denied;
    brandcapture::CaptureTransition deniedTransition =
        denied.beginCapture(brandcapture::CameraAuthorization::Denied);
    expectIdle(denied, "denied authorization remains idle");
    expect(!deniedTransition.requestAuthorization, "denied authorization is not requested again");
    expect(!deniedTransition.startSession, "denied authorization does not start a session");

    brandcapture::CaptureSessionState restricted;
    brandcapture::CaptureTransition restrictedTransition =
        restricted.beginCapture(brandcapture::CameraAuthorization::Restricted);
    expectIdle(restricted, "restricted authorization remains idle");
    expect(!restrictedTransition.requestAuthorization, "restricted authorization is not requested");
    expect(!restrictedTransition.startSession, "restricted authorization does not start a session");
}

void testNotDeterminedDelayedGrantAndDenial()
{
    brandcapture::CaptureSessionState granted;
    brandcapture::CaptureTransition request =
        granted.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    expect(granted.phase() == brandcapture::CapturePhase::Authorizing,
           "not-determined authorization enters authorizing phase");
    expect(request.requestAuthorization, "not-determined authorization requests access");
    expect(!request.startSession, "session waits for authorization callback");

    brandcapture::CaptureTransition grant =
        granted.resolveAuthorization(request.generation, true);
    expect(granted.phase() == brandcapture::CapturePhase::Starting,
           "delayed grant enters starting phase");
    expect(grant.startSession, "delayed grant starts the capture session");

    brandcapture::CaptureSessionState denied;
    brandcapture::CaptureTransition deniedRequest =
        denied.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    brandcapture::CaptureTransition denial =
        denied.resolveAuthorization(deniedRequest.generation, false);
    expectIdle(denied, "delayed denial returns to idle");
    expect(!denial.startSession, "delayed denial never starts capture");
}

void testPermissionPromptGrantResumesWithoutSecondTap()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition request =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);

    brandcapture::CaptureTransition resign =
        state.applicationWillResignActive();
    expect(state.phase() ==
               brandcapture::CapturePhase::AuthorizingPromptInactive,
           "permission prompt deactivation preserves authorization intent");
    expect(!resign.stopSession,
           "permission prompt deactivation does not perform lifecycle cleanup");

    brandcapture::CaptureTransition grant =
        state.resolveAuthorization(request.generation, true);
    expect(state.phase() ==
               brandcapture::CapturePhase::AuthorizingGrantedInactive,
           "grant received under the prompt waits for foreground return");
    expect(!grant.startSession,
           "grant received while inactive does not start the camera");

    brandcapture::CaptureTransition active =
        state.applicationDidBecomeActive();
    expect(state.phase() == brandcapture::CapturePhase::Starting,
           "returning active resumes the original Start intent");
    expect(active.startSession,
           "returning active starts capture without a second tap");
    expect(active.generation == request.generation,
           "permission prompt resumption preserves the attempt generation");
}

void testPermissionPromptDenialReturnsIdle()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition request =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    state.applicationWillResignActive();

    brandcapture::CaptureTransition denial =
        state.resolveAuthorization(request.generation, false);
    expectIdle(state, "permission denial under the prompt returns idle");
    expect(!denial.startSession,
           "permission denial under the prompt never starts capture");

    brandcapture::CaptureTransition active =
        state.applicationDidBecomeActive();
    expectIdle(state, "foreground return after denial remains idle");
    expect(!active.startSession,
           "foreground return after denial does not auto-start capture");
}

void testBackgroundDuringAuthorizationCancelsIntent()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition request =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    state.applicationWillResignActive();

    brandcapture::CaptureTransition background =
        state.applicationDidEnterBackground();
    expectIdle(state, "genuine backgrounding cancels authorization intent");
    expect(state.generation() > request.generation,
           "genuine backgrounding invalidates the prompt generation");
    expect(!background.stopSession,
           "authorization cancellation has no camera session to stop");

    brandcapture::CaptureTransition active =
        state.applicationDidBecomeActive();
    brandcapture::CaptureTransition lateGrant =
        state.resolveAuthorization(request.generation, true);
    expectIdle(state, "foreground return after background does not auto-start");
    expect(!active.startSession && !lateGrant.startSession,
           "background cancellation rejects both return and late grant");
}

void testStalePromptCallbackCannotClaimNewerAttempt()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition oldRequest =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    state.applicationWillResignActive();
    state.applicationDidEnterBackground();
    state.applicationDidBecomeActive();

    brandcapture::CaptureTransition newerRequest =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    brandcapture::CaptureTransition staleGrant =
        state.resolveAuthorization(oldRequest.generation, true);
    expect(state.phase() == brandcapture::CapturePhase::Authorizing,
           "stale prompt callback leaves the newer prompt authorizing");
    expect(!staleGrant.startSession,
           "stale prompt callback cannot start a second session");
    expect(newerRequest.generation != oldRequest.generation,
           "newer attempt owns a distinct generation");

    brandcapture::CaptureTransition currentGrant =
        state.resolveAuthorization(newerRequest.generation, true);
    expect(currentGrant.startSession,
           "current prompt callback can start its own attempt");
}

void testAuthorizedStartupRequiresSessionProof()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition start =
        state.beginCapture(brandcapture::CameraAuthorization::Authorized);
    expect(state.phase() == brandcapture::CapturePhase::Starting,
           "authorized start remains pending until session proof");
    expect(start.startSession, "authorized start asks controller to start session");
    brandcapture::CaptureControls pendingControls = state.controls(true);
    expect(!pendingControls.startEnabled && !pendingControls.stopEnabled,
           "pending startup does not claim active capture");

    brandcapture::CaptureTransition active =
        state.sessionDidStart(start.generation);
    expect(state.phase() == brandcapture::CapturePhase::Active,
           "session-start notification proves active capture");
    expect(active.refreshControls, "session start refreshes controls");
    brandcapture::CaptureControls activeControls = state.controls(true);
    expect(!activeControls.startEnabled && activeControls.stopEnabled,
           "active capture disables Start and enables Stop");
}

void testAuthorizedStartupFailureStopsAndReturnsIdle()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition start =
        state.beginCapture(brandcapture::CameraAuthorization::Authorized);
    unsigned long generationBeforeFailure = state.generation();
    brandcapture::CaptureTransition failure =
        state.sessionStartupFailed(start.generation);
    expectIdle(state, "startup failure returns to idle");
    expect(failure.stopSession, "startup failure requests OpenCV cleanup");
    expect(state.generation() > generationBeforeFailure,
           "startup failure invalidates late startup callbacks");

    brandcapture::CaptureTransition lateStart =
        state.sessionDidStart(start.generation);
    expectIdle(state, "late startup proof cannot reactivate a failed session");
    expect(!lateStart.refreshControls,
           "late startup proof is ignored after startup failure");
}

void testTerminalSessionEventsReconcileState()
{
    brandcapture::CaptureSessionState interrupted;
    brandcapture::CaptureTransition interruptedStart =
        interrupted.beginCapture(brandcapture::CameraAuthorization::Authorized);
    interrupted.sessionDidStart(interruptedStart.generation);
    brandcapture::CaptureTransition interruption =
        interrupted.sessionInterrupted(interruptedStart.generation);
    expectIdle(interrupted, "interruption returns capture to idle");
    expect(interruption.stopSession, "interruption requests session cleanup");

    brandcapture::CaptureSessionState errored;
    brandcapture::CaptureTransition errorStart =
        errored.beginCapture(brandcapture::CameraAuthorization::Authorized);
    errored.sessionDidStart(errorStart.generation);
    brandcapture::CaptureTransition runtimeError =
        errored.sessionRuntimeError(errorStart.generation);
    expectIdle(errored, "runtime error returns capture to idle");
    expect(runtimeError.stopSession, "runtime error requests session cleanup");

    brandcapture::CaptureSessionState stopped;
    brandcapture::CaptureTransition stoppedStart =
        stopped.beginCapture(brandcapture::CameraAuthorization::Authorized);
    stopped.sessionDidStart(stoppedStart.generation);
    brandcapture::CaptureTransition didStop =
        stopped.sessionDidStop(stoppedStart.generation);
    expectIdle(stopped, "session stop returns capture to idle");
    expect(!didStop.stopSession, "session-stop notification does not recursively stop");
}

void testLifecycleStopInvalidatesBeforeExternalStop()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition start =
        state.beginCapture(brandcapture::CameraAuthorization::Authorized);
    state.sessionDidStart(start.generation);
    unsigned long activeGeneration = state.generation();

    brandcapture::CaptureTransition lifecycleStop = state.stopForLifecycle();
    expectIdle(state, "lifecycle stop publishes idle before external cleanup");
    expect(state.generation() > activeGeneration,
           "lifecycle stop invalidates callbacks before external cleanup");
    expect(lifecycleStop.stopSession, "lifecycle stop asks controller to stop camera");

    brandcapture::CaptureTransition synchronousOldStop =
        state.sessionDidStop(activeGeneration);
    expect(!synchronousOldStop.refreshControls,
           "synchronous old stop callback is ignored after invalidation");
}

void testStaleCallbacksCannotReactivateNewerSession()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureTransition oldAuthorization =
        state.beginCapture(brandcapture::CameraAuthorization::NotDetermined);
    state.stopForLifecycle();

    brandcapture::CaptureTransition newStart =
        state.beginCapture(brandcapture::CameraAuthorization::Authorized);
    brandcapture::CaptureTransition staleGrant =
        state.resolveAuthorization(oldAuthorization.generation, true);
    brandcapture::CaptureTransition staleStarted =
        state.sessionDidStart(oldAuthorization.generation);
    expect(!staleGrant.startSession, "stale authorization grant cannot start capture");
    expect(!staleStarted.refreshControls, "stale session start cannot refresh controls");
    expect(state.phase() == brandcapture::CapturePhase::Starting,
           "stale callbacks leave newer session pending");

    state.sessionDidStart(newStart.generation);
    expect(state.phase() == brandcapture::CapturePhase::Active,
           "current generation can become active");
}

void testDetectorReadinessStillGatesControls()
{
    brandcapture::CaptureSessionState state;
    brandcapture::CaptureControls controls = state.controls(false);
    expect(!controls.startEnabled && !controls.stopEnabled,
           "failed detector setup keeps both controls disabled");
}

}

int main()
{
    testDeniedAndRestrictedRemainIdle();
    testNotDeterminedDelayedGrantAndDenial();
    testPermissionPromptGrantResumesWithoutSecondTap();
    testPermissionPromptDenialReturnsIdle();
    testBackgroundDuringAuthorizationCancelsIntent();
    testStalePromptCallbackCannotClaimNewerAttempt();
    testAuthorizedStartupRequiresSessionProof();
    testAuthorizedStartupFailureStopsAndReturnsIdle();
    testTerminalSessionEventsReconcileState();
    testLifecycleStopInvalidatesBeforeExternalStop();
    testStaleCallbacksCannotReactivateNewerSession();
    testDetectorReadinessStillGatesControls();

    if (failures != 0)
    {
        std::cerr << failures << " capture session state assertion(s) failed" << std::endl;
        return EXIT_FAILURE;
    }

    std::cout << "Capture session state tests passed" << std::endl;
    return EXIT_SUCCESS;
}
