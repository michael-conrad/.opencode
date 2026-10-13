#!/bin/bash
# Entrypoint for the tests-v2 test-agent container (.opencode#2582, SC-2).
# Starts Xvfb on a virtual display, exports DISPLAY, then execs the command.
set -e

DISPLAY_NUM="${TEST_XVFB_DISPLAY:-99}"
export DISPLAY=":${DISPLAY_NUM}"

XVFB_LOG=/tmp/xvfb.log
Xvfb ":${DISPLAY_NUM}" -screen 0 1920x1080x24 -nolisten tcp >"$XVFB_LOG" 2>&1 &
XVFB_PID=$!

# Wait for the display socket before handing over to the command.
for _ in $(seq 1 50); do
    if [ -S "/tmp/.X11-unix/X${DISPLAY_NUM}" ]; then
        break
    fi
    if ! kill -0 "$XVFB_PID" 2>/dev/null; then
        echo "FATAL: Xvfb failed to start" >&2
        cat "$XVFB_LOG" >&2
        exit 1
    fi
    sleep 0.2
done

if [ $# -eq 0 ]; then
    set -- bash
fi
exec "$@"
