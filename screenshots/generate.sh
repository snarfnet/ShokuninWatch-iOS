#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-ShokuninWatch}"
BUNDLE_ID="${BUNDLE_ID:-com.snarfnet.shokuninwatch.ios}"
DERIVED_DATA="${DERIVED_DATA:-build/DerivedData}"
OUT_DIR="${OUT_DIR:-screenshots/generated}"
CONFIGURATION="${CONFIGURATION:-Debug}"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d "$DERIVED_DATA" ] || [ -z "$(find "$DERIVED_DATA" -name "${SCHEME}.app" -print -quit 2>/dev/null)" ]; then
  if command -v xcodegen >/dev/null 2>&1 && [ ! -d "${SCHEME}.xcodeproj" ]; then
    xcodegen generate
  fi
  xcodebuild build \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO
fi

APP_PATH="$(find "$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator" -name "${SCHEME}.app" -print -quit)"
if [ -z "$APP_PATH" ]; then
  echo "App not found under $DERIVED_DATA" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

runtime_identifier() {
  xcrun simctl list -j runtimes | python3 -c '
import json, sys
data = json.load(sys.stdin)
runtimes = [r for r in data["runtimes"] if r.get("isAvailable") and r.get("platform") == "iOS"]
if not runtimes:
    raise SystemExit("No available iOS runtime")
def key(runtime):
    return tuple(int(p) for p in runtime.get("version", "0").split(".") if p.isdigit())
print(sorted(runtimes, key=key)[-1]["identifier"])
'
}

device_type_identifier() {
  local preferred="$1"
  xcrun simctl list -j devicetypes | PREFERRED_DEVICES="$preferred" python3 -c '
import json, os, sys
preferred = [item.strip() for item in os.environ["PREFERRED_DEVICES"].split(",")]
data = json.load(sys.stdin)
devices = data["devicetypes"]
for name in preferred:
    match = next((d for d in devices if d.get("name") == name), None)
    if match:
        print(match["identifier"])
        raise SystemExit
raise SystemExit(f"No preferred simulator type found: {preferred}")
'
}

capture_device() {
  local family="$1"
  local preferred="$2"
  local runtime="$3"
  local device_type
  local device_id

  device_type="$(device_type_identifier "$preferred")"
  device_id="$(xcrun simctl create "ShokuninWatch ${family}" "$device_type" "$runtime")"

  cleanup() {
    xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true
    xcrun simctl delete "$device_id" >/dev/null 2>&1 || true
  }
  trap cleanup RETURN

  xcrun simctl boot "$device_id"
  xcrun simctl bootstatus "$device_id" -b
  xcrun simctl install "$device_id" "$APP_PATH"

  local locales=("ja_JP" "en_US")
  local tabs=("angle" "level" "converter")
  local indexes=("1" "2" "3")

  for locale in "${locales[@]}"; do
    for i in "${!tabs[@]}"; do
      local tab="${tabs[$i]}"
      local index="${indexes[$i]}"
      local suffix="ja"
      if [ "$locale" = "en_US" ]; then
        suffix="en"
      fi

      xcrun simctl terminate "$device_id" "$BUNDLE_ID" >/dev/null 2>&1 || true
      xcrun simctl launch "$device_id" "$BUNDLE_ID" \
        -screenshots \
        -AppleLanguages "($locale)" \
        -AppleLocale "$locale" \
        -screenshotTab "$tab" >/dev/null
      sleep 4
      xcrun simctl io "$device_id" screenshot "$OUT_DIR/${family}_${suffix}_${index}_${tab}.png"
    done
  done
}

RUNTIME="$(runtime_identifier)"
capture_device "iphone_6_7" "iPhone 15 Pro Max,iPhone 14 Pro Max,iPhone 16 Plus,iPhone 15 Plus" "$RUNTIME"
capture_device "iphone_6_1" "iPhone 15 Pro,iPhone 14 Pro,iPhone 13 Pro,iPhone 15" "$RUNTIME"
capture_device "ipad_12_9" "iPad Pro 13-inch (M4),iPad Pro (12.9-inch) (6th generation),iPad Pro (12.9-inch) (5th generation)" "$RUNTIME"

echo "Screenshots written to $OUT_DIR"
