#!/usr/bin/env bash
# Runs the app against the mock runner, with a temp data folder so nothing
# touches the real runner. Extra arguments go to the mock runner
# (for example --filler 16).
#   QUOKKACODE_BIN=path/to/QuokkaCode  use a specific binary (default: the staged app)
set -euo pipefail

# THREADBARE_* was the old name for these variables: each stands in for its new name.
for v in $(compgen -e | grep '^THREADBARE_' || true); do n="QUOKKACODE_${v#THREADBARE_}"; [ -n "${!n+x}" ] || export "$n=${!v}"; done
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${QUOKKACODE_APP_DIR:-$HOME/Applications/QuokkaCode.app}"
BIN="${QUOKKACODE_BIN:-$APP_DIR/Contents/MacOS/QuokkaCode}"
DATA_DIR="$(mktemp -d "${TMPDIR:-/tmp}/quokkacode-mock.XXXXXX")"

if [[ ! -x "$BIN" ]]; then
  echo "No app at $BIN. Run ./build-app.sh first or set QUOKKACODE_BIN." >&2
  exit 1
fi
if [[ ! -d "$TOOLS_DIR/mock-runner/node_modules" ]]; then
  (cd "$TOOLS_DIR/mock-runner" && npm install --silent)
fi

node "$TOOLS_DIR/mock-runner/server.mjs" --data-dir "$DATA_DIR" "$@" &
MOCK_PID=$!
cleanup() {
  kill "$MOCK_PID" 2>/dev/null || true
  rm -rf "$DATA_DIR"
}
trap cleanup EXIT

for _ in $(seq 1 100); do
  [[ -f "$DATA_DIR/runner.json" ]] && break
  sleep 0.05
done

"$BIN" --data-dir "$DATA_DIR"
