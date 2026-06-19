---
title: Checkout Credential Boundary
date: 2026-06-12
status: completed
execution: code
---

# Checkout Credential Boundary

## Summary

Prevent the canonical static Check job from retaining its GitHub token after
checkout while preserving the Objective-C++ camera application and existing
CodeQL coverage.

## Requirements

- Disable credential persistence on the only checkout step.
- Enforce checkout count, immutable pin, exact read-only permissions, one
  required command, no bypasses, documentation, and completed evidence.
- Preserve workflow triggers, Ubuntu 24.04, `make check`, default CodeQL,
  camera/OpenCV sources, Pods, project files, and behavior.
- Pass repository/external-working-directory gates and hostile mutations.

## Scope And Verification

Only the Check workflow, static contracts, guidance, and evidence change. Full
Xcode/camera verification remains dependent on a compatible macOS host.

## Work Completed

- Disabled credential persistence on the only checkout step.
- Added exact contracts for checkout count/pin, read-only permissions, command
  count, bypass absence, documentation, and completed evidence.
- Preserved default CodeQL and every camera, OpenCV, Pods, and Xcode file.

## Verification Completed

- The untouched baseline passed from the repository and an external working directory.
- `make check` passed after implementation with the documented unavailable
  Xcode limitation.
- Focused hostile mutations rejected credential, action pin, permission,
  command, documentation, and incomplete-plan drift; all hostile mutations rejected.
- YAML parsing, shell syntax, `git diff --check`, and secret scanning passed.

## Hosted Verification

Exact-head Check and default CodeQL evidence will be recorded after push.
Tracker reconciliation remains pending until both are terminal green.
