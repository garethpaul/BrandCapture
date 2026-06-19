#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CXX=${CXX:-c++}

if ! command -v "$CXX" >/dev/null 2>&1; then
  printf '%s\n' "C++ compiler not found: $CXX" >&2
  exit 1
fi

BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/brandcapture-image-layout-tests.XXXXXX")
cleanup() {
  rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

"$CXX" -std=c++11 -Wall -Wextra -pedantic \
  -I"$ROOT_DIR/BrandCapture" \
  "$ROOT_DIR/Tests/ImageMatrixLayoutTests.cpp" \
  -o "$BUILD_DIR/image-matrix-layout-tests"
"$BUILD_DIR/image-matrix-layout-tests"
