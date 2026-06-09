.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild

lint:
	scripts/check-baseline.sh

test: lint

build: lint
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		"$(XCODEBUILD)" -workspace BrandCapture.xcworkspace -scheme BrandCapture -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "xcodebuild not found; static BrandCapture checks completed."; \
	fi

verify: lint test build

check: verify
