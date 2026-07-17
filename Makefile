.PHONY: build check gate-propagation-test lint mutation-test test verify

XCODEBUILD ?= xcodebuild
CXX ?= c++
override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	@if command -v "$(CXX)" >/dev/null 2>&1; then \
		CXX="$(CXX)" "$(ROOT)scripts/test-capture-session-state.sh" && \
		CXX="$(CXX)" "$(ROOT)scripts/test-projected-corners.sh" && \
		CXX="$(CXX)" "$(ROOT)scripts/test-image-matrix-layout.sh"; \
	else \
		echo "C++ compiler not found; skipping portable C++ behavior tests."; \
	fi
	"$(ROOT)scripts/test-camera-authorization-integration.sh"

mutation-test:
	CXX="$(CXX)" "$(ROOT)scripts/test-camera-authorization-mutations.sh"

gate-propagation-test:
	CXX="$(CXX)" "$(ROOT)scripts/test-make-test-failure-propagation.sh"

build: lint
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		"$(XCODEBUILD)" -workspace "$(ROOT)BrandCapture.xcworkspace" -scheme BrandCapture -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "xcodebuild not found; static BrandCapture checks completed."; \
	fi

verify: lint test mutation-test gate-propagation-test build

check: verify
