#!/usr/bin/env bash
set -euo pipefail

# THREADBARE_* was the old name for these variables: each stands in for its new name.
for v in $(compgen -e | grep '^THREADBARE_' || true); do n="QUOKKACODE_${v#THREADBARE_}"; [ -n "${!n+x}" ] || export "$n=${!v}"; done
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${QUOKKACODE_APP_DIR:-$HOME/Applications/QuokkaCode.app}"

QUOKKACODE_BUILD_CONFIGURATION=release bash "$SCRIPT_DIR/build-app.sh"
echo ""
echo "Quokka Code is installed at $APP_DIR"
echo "Launch it with: quokkacode"
