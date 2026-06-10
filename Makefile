.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test: lint

build: lint
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		"$(XCODEBUILD)" -workspace "$(ROOT)BrandCapture.xcworkspace" -scheme BrandCapture -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "xcodebuild not found; static BrandCapture checks completed."; \
	fi

verify: lint test build

check: verify
