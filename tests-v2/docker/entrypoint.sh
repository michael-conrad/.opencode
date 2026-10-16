#!/bin/bash
# Entrypoint for the tests-v2 test-agent container (.opencode#2582, SC-2).
# Starts Xvfb on a virtual display, exports DISPLAY, then execs the command.
#
# Display-collision recovery (.opencode#2618, R-18 harness-behavior class):
# under `--network host` the X abstract-socket namespace is shared with the
# host — an existing Xvfb on the default display (e.g. host :99) makes the
# entrypoint die before the command runs, which surfaces downstream as empty
# run output. The abstract socket cannot be probed from the filesystem
# namespace, so the entrypoint ATTEMPTS the display and walks upward on
# failure instead of dying; an explicit TEST_XVFB_DISPLAY still pins the
# display as before.
set -e

DISPLAY_NUM="${TEST_XVFB_DISPLAY:-99}"

XVFB_LOG=/tmp/xvfb.log

start_xvfb() {
    export DISPLAY=":${DISPLAY_NUM}"
    Xvfb ":${DISPLAY_NUM}" -screen 0 1920x1080x24 -nolisten tcp >"$XVFB_LOG" 2>&1 &
    local xvfb_pid=$!
    # Wait for the display socket before handing over to the command.
    for _ in $(seq 1 50); do
        if [ -S "/tmp/.X11-unix/X${DISPLAY_NUM}" ]; then
            return 0
        fi
        if ! kill -0 "$xvfb_pid" 2>/dev/null; then
            return 1
        fi
        sleep 0.2
    done
    return 0
}

if [ -n "${TEST_XVFB_DISPLAY:-}" ]; then
    # Pinned display: fail loudly, as before.
    start_xvfb || { echo "FATAL: Xvfb failed to start on :${DISPLAY_NUM}" >&2; cat "$XVFB_LOG" >&2; exit 1; }
else
    # Auto-selected display: walk upward past occupied displays — under
    # --network host the collision manifests only as an Xvfb startup failure.
    _tries=0
    while ! start_xvfb; do
        _tries=$((_tries + 1))
        if [ "$_tries" -ge 50 ]; then
            echo "FATAL: no free X display found (searched :99..:${DISPLAY_NUM})" >&2
            cat "$XVFB_LOG" >&2
            exit 1
        fi
        DISPLAY_NUM=$((DISPLAY_NUM + 1))
    done
fi

if [ $# -eq 0 ]; then
    set -- bash
fi
exec "$@"
