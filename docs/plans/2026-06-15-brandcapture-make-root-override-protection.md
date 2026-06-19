# BrandCapture Make Root Override Protection

## Status: Completed

## Context

The Makefile derives `ROOT` from its own path with a regular assignment. A
caller can therefore use `make ROOT=/tmp check` to redirect the trusted checker
and Xcode workspace path outside the repository.

## Priority

High verification integrity. Public Make targets must always execute reviewed
repository files regardless of caller-supplied variables.

## Requirements

- Protect the repository-derived Make root from command-line overrides.
- Preserve repository and external-working-directory behavior.
- Preserve the static checker and conditional unsigned simulator build.
- Add a fail-closed contract for exactly one protected root declaration.
- Prove hostile `ROOT=/tmp` dry runs retain repository paths.

## Scope Boundaries

- Do not change camera, OpenCV, matching, homography, projected-corner,
  storyboard, dependency, workflow, or project behavior.
- Do not claim Xcode, simulator, camera, or physical-device validation from
  Linux.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Protect the Make root declaration.
2. Extend the checker and maintained build/security documentation.
3. Record completed repository, external-directory, hostile-override, and
   mutation evidence.

## Verification

- focused shell and baseline validation
- repository and external-directory `make check`
- hostile `ROOT=/tmp` dry-run path audit
- hostile protected-root, documentation, and completed-plan mutations
- plist/workspace XML, artifact, credential-pattern, and exact-diff audits

## Verification Results

- Focused shell and baseline validation passed.
- The repository and external-directory `make check` passed; Linux truthfully
  used the static-only path because `xcodebuild` is unavailable.
- A hostile `ROOT=/tmp` dry run retained repository checker and workspace paths.
- Three hostile BrandCapture Make root mutations were rejected across protected
  assignment, maintained documentation, and completed-plan evidence.
- Plist/workspace XML, artifact, credential-pattern, conflict-marker, and
  exact-diff audits passed.

## Remaining Risks

- Objective-C++ compilation, simulator camera input, and live OpenCV frame
  processing require macOS/Xcode and suitable hardware or fixtures.
