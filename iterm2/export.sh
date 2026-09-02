#!/usr/bin/env bash
# Save the current iTerm2 settings back into this repo.
# Run after changing anything in iTerm2 → Preferences, then commit the result.
set -e

DEST="$(cd "$(dirname "$0")" && pwd)/com.googlecode.iterm2.plist"

# iTerm2 only flushes its prefs to disk on quit, but `defaults export` reads
# through cfprefsd, so a running iTerm2 is fine here (unlike on import).
defaults export com.googlecode.iterm2 "$DEST"

# Drop keys that describe this Mac rather than the settings: window positions
# (wrong on a different display), the install's UUID, crash-report state.
python3 - "$DEST" <<'PY'
import plistlib, sys

path = sys.argv[1]
with open(path, 'rb') as f:
    prefs = plistlib.load(f)

def machine_local(key):
    return (key.startswith('NSWindow Frame ')
            or key == 'NoSyncInstallationId'
            or key.startswith('UKCrashReporter')
            or key.startswith('NSNav'))

removed = [k for k in prefs if machine_local(k)]
for key in removed:
    del prefs[key]

# XML, sorted, so git diffs stay readable and stable run to run.
with open(path, 'wb') as f:
    plistlib.dump(prefs, f, sort_keys=True)

print(f"    Exported {len(prefs)} keys, dropped {len(removed)} machine-specific")
PY

REPO="$(cd "$(dirname "$DEST")/.." && pwd)"
echo "==> Saved to $DEST"
echo "    Review with: git -C \"$REPO\" diff"
