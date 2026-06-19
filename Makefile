.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild
CXX ?= c++
override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	@if command -v "$(CXX)" >/dev/null 2>&1; then \
		CXX="$(CXX)" "$(ROOT)scripts/test-projected-corners.sh"; \
	else \
		echo "C++ compiler not found; skipping projected corner behavior tests."; \
	fi

build: lint
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		"$(XCODEBUILD)" -workspace "$(ROOT)BrandCapture.xcworkspace" -scheme BrandCapture -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "xcodebuild not found; static BrandCapture checks completed."; \
	fi

verify: lint test build

check: verify
