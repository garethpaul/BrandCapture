.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild
CXX ?= c++
override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	@if command -v "$(CXX)" >/dev/null 2>&1; then \
		CXX="$(CXX)" "$(ROOT)scripts/test-projected-corners.sh"; \
		CXX="$(CXX)" "$(ROOT)scripts/test-image-matrix-layout.sh"; \
	else \
		echo "C++ compiler not found; skipping portable C++ behavior tests."; \
	fi

build: lint
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		"$(XCODEBUILD)" -workspace "$(ROOT)BrandCapture.xcworkspace" -scheme BrandCapture -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "xcodebuild not found; static BrandCapture checks completed."; \
	fi

verify: lint test build

check: verify
