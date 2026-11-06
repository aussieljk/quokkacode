#!/usr/bin/env bash
# Quits the Quokka Code app. The runner (and every agent) keeps going.
set -euo pipefail

# THREADBARE_* was the old name for these variables: each stands in for its new name.
for v in $(compgen -e | grep '^THREADBARE_' || true); do n="QUOKKACODE_${v#THREADBARE_}"; [ -n "${!n+x}" ] || export "$n=${!v}"; done
APP_DIR="${QUOKKACODE_APP_DIR:-$HOME/Applications/QuokkaCode.app}"
# Match the staged app's binary path only, so nothing else named QuokkaCode
# (a perf run from .build, say) is touched.
pkill -f "^$APP_DIR/Contents/MacOS/QuokkaCode" 2>/dev/null || true
