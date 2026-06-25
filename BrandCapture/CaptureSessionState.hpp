#ifndef BrandCapture_CaptureSessionState_hpp
#define BrandCapture_CaptureSessionState_hpp

namespace brandcapture {

enum class CameraAuthorization
{
    Authorized,
    Denied,
    Restricted,
    NotDetermined
};

enum class CapturePhase
{
    Idle,
    Authorizing,
    AuthorizingPromptInactive,
    AuthorizingGrantedInactive,
    Starting,
    Active
};

struct CaptureControls
{
    bool startEnabled;
    bool stopEnabled;
};

struct CaptureTransition
{
    CaptureTransition()
        : generation(0),
          requestAuthorization(false),
          startSession(false),
          stopSession(false),
          refreshControls(false)
    {
    }

    unsigned long generation;
    bool requestAuthorization;
    bool startSession;
    bool stopSession;
    bool refreshControls;
};

class CaptureSessionState
{
public:
    CaptureSessionState()
        : generation_(0), phase_(CapturePhase::Idle)
    {
    }

    unsigned long generation() const
    {
        return generation_;
    }

    CapturePhase phase() const
    {
        return phase_;
    }

    CaptureControls controls(bool detectorReady) const
    {
        CaptureControls controls = { false, false };
        if (!detectorReady)
        {
            return controls;
        }

        controls.startEnabled = phase_ == CapturePhase::Idle;
        controls.stopEnabled = phase_ == CapturePhase::Active;
        return controls;
    }

    CaptureTransition beginCapture(CameraAuthorization authorization)
    {
        CaptureTransition transition;
        if (phase_ != CapturePhase::Idle)
        {
            transition.generation = generation_;
            return transition;
        }

        advanceGeneration();
        transition.generation = generation_;
        transition.refreshControls = true;

        if (authorization == CameraAuthorization::Authorized)
        {
            phase_ = CapturePhase::Starting;
            transition.startSession = true;
        }
        else if (authorization == CameraAuthorization::NotDetermined)
        {
            phase_ = CapturePhase::Authorizing;
            transition.requestAuthorization = true;
        }

        return transition;
    }

    CaptureTransition resolveAuthorization(unsigned long generation,
                                           bool granted)
    {
        CaptureTransition transition;
        transition.generation = generation_;
        bool authorizing = phase_ == CapturePhase::Authorizing ||
                           phase_ == CapturePhase::AuthorizingPromptInactive;
        if (generation != generation_ || !authorizing)
        {
            return transition;
        }

        transition.refreshControls = true;
        if (granted)
        {
            if (phase_ == CapturePhase::AuthorizingPromptInactive)
            {
                phase_ = CapturePhase::AuthorizingGrantedInactive;
                return transition;
            }

            phase_ = CapturePhase::Starting;
            transition.startSession = true;
            transition.generation = generation_;
            return transition;
        }

        phase_ = CapturePhase::Idle;
        advanceGeneration();
        transition.generation = generation_;
        return transition;
    }

    CaptureTransition applicationWillResignActive()
    {
        CaptureTransition transition;
        transition.generation = generation_;
        if (phase_ == CapturePhase::Authorizing)
        {
            phase_ = CapturePhase::AuthorizingPromptInactive;
            return transition;
        }
        if (phase_ == CapturePhase::AuthorizingPromptInactive ||
            phase_ == CapturePhase::AuthorizingGrantedInactive)
        {
            return transition;
        }

        return stopForLifecycle();
    }

    CaptureTransition applicationDidEnterBackground()
    {
        return stopForLifecycle();
    }

    CaptureTransition applicationDidBecomeActive()
    {
        CaptureTransition transition;
        transition.generation = generation_;
        if (phase_ == CapturePhase::AuthorizingPromptInactive)
        {
            phase_ = CapturePhase::Authorizing;
        }
        else if (phase_ == CapturePhase::AuthorizingGrantedInactive)
        {
            phase_ = CapturePhase::Starting;
            transition.startSession = true;
            transition.refreshControls = true;
        }
        return transition;
    }

    CaptureTransition sessionDidStart(unsigned long generation)
    {
        CaptureTransition transition;
        transition.generation = generation_;
        if (generation != generation_ || phase_ != CapturePhase::Starting)
        {
            return transition;
        }

        phase_ = CapturePhase::Active;
        transition.refreshControls = true;
        return transition;
    }

    CaptureTransition sessionStartupFailed(unsigned long generation)
    {
        return terminalTransition(generation, true, CapturePhase::Starting);
    }

    CaptureTransition sessionInterrupted(unsigned long generation)
    {
        return terminalTransition(generation, true);
    }

    CaptureTransition sessionRuntimeError(unsigned long generation)
    {
        return terminalTransition(generation, true);
    }

    CaptureTransition sessionDidStop(unsigned long generation)
    {
        return terminalTransition(generation, false);
    }

    CaptureTransition stopForLifecycle()
    {
        CaptureTransition transition;
        bool ownsSession = phase_ == CapturePhase::Starting ||
                           phase_ == CapturePhase::Active;
        phase_ = CapturePhase::Idle;
        advanceGeneration();
        transition.generation = generation_;
        transition.stopSession = ownsSession;
        transition.refreshControls = true;
        return transition;
    }

private:
    void advanceGeneration()
    {
        ++generation_;
        if (generation_ == 0)
        {
            ++generation_;
        }
    }

    CaptureTransition terminalTransition(unsigned long generation,
                                         bool stopSession)
    {
        CaptureTransition transition;
        transition.generation = generation_;
        if (generation != generation_ || phase_ == CapturePhase::Idle)
        {
            return transition;
        }

        phase_ = CapturePhase::Idle;
        advanceGeneration();
        transition.generation = generation_;
        transition.stopSession = stopSession;
        transition.refreshControls = true;
        return transition;
    }

    CaptureTransition terminalTransition(unsigned long generation,
                                         bool stopSession,
                                         CapturePhase requiredPhase)
    {
        if (phase_ != requiredPhase)
        {
            CaptureTransition transition;
            transition.generation = generation_;
            return transition;
        }
        return terminalTransition(generation, stopSession);
    }

    unsigned long generation_;
    CapturePhase phase_;
};

}

#endif
