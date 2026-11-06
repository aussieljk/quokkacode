#!/bin/zsh
# Screenshots of the app on sample data (FakeBackend) in the simulator, into
# <dir> (default /tmp/tb-shots): the inbox, a few threads, New thread and the
# pair screen. On this checkout's own simulator (scripts/sim.sh, which says why
# and how SIM_NAME picks another), left as it was found: shut down unless it was
# already up. Pro Max sizes are the App Store's 6.9" (1320 x 2868);
# appstore-screenshots.mjs uploads them.
#
#   ios/scripts/sim-shots.sh [dir] [--dark]
#   SIM_NAME="QuokkaCode App Store" ios/scripts/sim-shots.sh ios/appstore/screenshots
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=${1:-/tmp/tb-shots}
mkdir -p "$OUT"
SIM=$(scripts/sim.sh)
if ! xcrun simctl list devices booted | grep -qF "($SIM)"; then
  trap 'xcrun simctl shutdown "$SIM" 2>/dev/null || true' EXIT
fi
# Before the build, so being refused doesn't come after minutes of compiling.
scripts/sim.sh boot >/dev/null
DD=/tmp/quokkacode-dd-$SIM
xcodebuild -project QuokkaCode.xcodeproj -scheme QuokkaCode -configuration Debug -destination "id=$SIM" \
  -derivedDataPath "$DD" build | grep -E " error:|BUILD (SUCCEEDED|FAILED)"
xcrun simctl ui "$SIM" appearance "$([[ "${2:-}" == --dark ]] && echo dark || echo light)"
xcrun simctl status_bar "$SIM" override --time 9:41 --batteryLevel 100 --batteryState charged --cellularBars 4
xcrun simctl uninstall "$SIM" com.mikecann.threadbear 2>/dev/null || true  # clears permission prompts from earlier runs
xcrun simctl install "$SIM" "$DD/Build/Products/Debug-iphonesimulator/QuokkaCode.app"
# shot <name> [launch args...]: on the sample threads, unless the first arg is --unpaired.
shot() {
  local name=$1; shift
  local args=(-QuokkaCodeFake)
  [[ "${1:-}" == --unpaired ]] && { args=(); shift; }
  xcrun simctl launch --terminate-running-process "$SIM" com.mikecann.threadbear "${args[@]}" "$@" >/dev/null
  sleep 3
  xcrun simctl io "$SIM" screenshot "$OUT/$name.png" >/dev/null 2>&1
  echo "$OUT/$name.png"
}
shot inbox
shot search -QuokkaCodeSearch settings
shot approval -QuokkaCodeOpen a1
shot question -QuokkaCodeOpen a2
shot reply -QuokkaCodeOpen a3
shot running -QuokkaCodeOpen a5
shot pictures -QuokkaCodePictures -QuokkaCodeOpen pics
shot new-thread -QuokkaCodeCompose "Add a dark mode to the garden planner, matching the system setting"
shot pair --unpaired
