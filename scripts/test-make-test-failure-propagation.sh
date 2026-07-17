#!/usr/bin/env sh
set -eu

# Asserts that `make test` surfaces a failing behavior test from EVERY position
# in its recipe, not just the last one.
#
# Make runs a recipe through `sh -c` without `set -e`, so a `;`-separated list
# exits with the status of only its LAST command. A recipe that chains several
# test runners with `;` therefore reports success while earlier runners fail:
# their assertion output is printed and their exit status is discarded.
#
# This test plants a real behavioral defect behind each runner in turn, runs the
# repository's own Makefile against the mutated copy, and requires both a
# non-zero exit status AND the runner's own diagnostic. Asserting the diagnostic
# (not merely the exit code) keeps a compile error or a broken fixture from
# masquerading as a caught defect.

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CXX=${CXX:-c++}

if ! command -v "$CXX" >/dev/null 2>&1; then
  printf '%s\n' "C++ compiler not found: $CXX" >&2
  exit 1
fi

if ! command -v make >/dev/null 2>&1; then
  printf '%s\n' "make not found; cannot verify gate failure propagation." >&2
  exit 1
fi

BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/brandcapture-gate-propagation.XXXXXX")
cleanup() {
  rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

# A copy of everything `make test` reads, minus image assets.
WORK="$BUILD_DIR/repo"
mkdir -p "$WORK/BrandCapture" "$WORK/Tests" "$WORK/scripts"
cp "$ROOT_DIR/Makefile" "$WORK/Makefile"
cp "$ROOT_DIR/scripts/"*.sh "$WORK/scripts/"
cp "$ROOT_DIR/Tests/"*.cpp "$WORK/Tests/"
for source in "$ROOT_DIR/BrandCapture/"*.h "$ROOT_DIR/BrandCapture/"*.hpp \
  "$ROOT_DIR/BrandCapture/"*.m "$ROOT_DIR/BrandCapture/"*.mm; do
  cp "$source" "$WORK/BrandCapture/"
done

run_make_test() {
  log=$1
  if CXX="$CXX" make -C "$WORK" test >"$log" 2>&1; then
    return 0
  fi
  return 1
}

# A red baseline would make every probe below meaningless: `make test` must pass
# on the unmutated copy before a non-zero exit can be attributed to a plant.
if ! run_make_test "$BUILD_DIR/baseline.log"; then
  printf '%s\n' "Unmutated copy of the repository fails 'make test'; cannot attribute failures to planted defects." >&2
  cat "$BUILD_DIR/baseline.log" >&2
  exit 1
fi

require_propagates() {
  name=$1
  file=$2
  original=$3
  mutated=$4
  diagnostic=$5

  target="$WORK/BrandCapture/$file"
  cp "$ROOT_DIR/BrandCapture/$file" "$target"

  if ! grep -Fq -e "$original" "$target"; then
    printf '%s\n' "Cannot plant '$name': expected source text is absent from $file: $original" >&2
    exit 1
  fi

  # Replace the exact line without relying on sed metacharacter quoting.
  ORIGINAL_TEXT="$original" MUTATED_TEXT="$mutated" perl -pi -e '
    BEGIN { $from = $ENV{ORIGINAL_TEXT}; $to = $ENV{MUTATED_TEXT}; }
    s/\Q$from\E/$to/;
  ' "$target"

  if ! grep -Fq -e "$mutated" "$target"; then
    printf '%s\n' "Cannot plant '$name': mutation did not apply to $file." >&2
    exit 1
  fi

  log="$BUILD_DIR/$name.log"
  if run_make_test "$log"; then
    printf '%s\n' "Gate failure did not propagate: 'make test' reported success with a planted defect behind '$name'." >&2
    printf '%s\n' "A test runner chained with ';' in the Makefile recipe has its exit status discarded." >&2
    cat "$log" >&2
    exit 1
  fi

  if ! grep -Fq -e "$diagnostic" "$log"; then
    printf '%s\n' "'make test' failed for '$name' but never printed the expected assertion diagnostic: $diagnostic" >&2
    printf '%s\n' "The non-zero exit may come from a compile error rather than a caught defect." >&2
    cat "$log" >&2
    exit 1
  fi

  printf '%s\n' "Gate propagates failure from: $name"

  # Restore before the next probe so each plant is measured in isolation.
  cp "$ROOT_DIR/BrandCapture/$file" "$target"
}

require_propagates capture-session-state CaptureSessionState.hpp \
  'controls.stopEnabled = phase_ == CapturePhase::Active;' \
  'controls.stopEnabled = phase_ != CapturePhase::Active;' \
  'FAIL: idle state disables Stop'

require_propagates projected-corners ProjectedCorners.hpp \
  'const std::size_t expectedCornerCount = 4;' \
  'const std::size_t expectedCornerCount = 5;' \
  'clockwise square: expected 1 but was 0'

require_propagates image-matrix-layout ImageMatrixLayout.hpp \
  '(channelCount != 1 && channelCount != 4) ||' \
  '(channelCount != 1 && channelCount != 3) ||' \
  'four channel: expected 1 but was 0'

printf '%s\n' "Make test failure propagation checks passed"
