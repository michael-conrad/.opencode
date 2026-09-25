#!/bin/bash
# Behavioral test helper functions for artifact-only generator scripts.
# Source this file in behavioral test scripts.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
#
# These helpers generate model-run artifacts only — they do NOT evaluate.
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# All paths are relative to the project root, discovered by walking up from
# the helper's own location until a directory containing .opencode/ is found.
# This works identically in isolated test repos and the live repo.
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  MANDATORY: BASH TOOL TIMEOUT MUST BE >= 600 SECONDS (timeout: 600000ms)   ║
# ║                                                                              ║
# ║  DO NOT omit the bash tool `timeout` parameter — NEVER use default 120s.     ║
# ║  This script spawns `opencode run` which can take 5+ minutes. Default       ║
# ║  bash tool timeout (120s) WILL kill this script mid-execution, leaving        ║
# ║  orphaned processes, orphaned test homes, corrupted lock files, and zombie    ║
# ║  opencode processes.                                                          ║
# ║                                                                              ║
# ║  Always pass `timeout: 600000` (600 seconds, milliseconds) to the bash tool  ║
# ║  when invoking any script in tests-v2/behaviors/.                            ║
# ║                                                                              ║
# ║  FORBIDDEN: The `timeout` command (GNU timeout) MUST NOT appear in any      ║
# ║  test script. The bash tool `timeout` parameter is the ONLY kill signal.     ║
# ║  GNU timeout does NOT forward SIGTERM to its children — orphaned opencode    ║
# ║  processes hold the flock lock and hang all subsequent test runs.            ║
# ║                                                                              ║
# ║  On SSE read timeout or transient model error: resume the session via         ║
# ║  `opencode run --continue` (resume last session) or                           ║
# ║  `opencode run --session <id>` (resume a specific session) — NEVER kill and   ║
# ║  restart.                                                                     ║
# ║                                                                              ║
# ║  Violation = orphaned processes = hang = manual kill -9 required.            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../default-model.sh"
BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests-v2/with-test-home}"
BEHAVIOR_FIXTURE_ISSUES="${BEHAVIOR_FIXTURE_ISSUES:-1}"
BEHAVIOR_HARNESS_VERSION="${BEHAVIOR_HARNESS_VERSION:-1}"
# .opencode#2456 SC-9 (plan-03 Item 9): undetermined-cycle ceiling default.
UNDETERMINED_CYCLE_CEILING="${UNDETERMINED_CYCLE_CEILING:-3}"

# Discover project root by walking up from helpers location
BEHAVIOR_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

__find_project_root() {
    local dir="$1"
    while [ ! -d "$dir/.opencode" ]; do
        dir="$(dirname "$dir")"
        if [ "$dir" = "/" ]; then
            echo "FATAL: Could not find project root (no .opencode/ directory found)" >&2
            exit 1
        fi
    done
    echo "$dir"
}

PARENT_REPO_DIR="$(__find_project_root "$BEHAVIOR_HELPERS_DIR")"

# --- Live-root mutation guard ---

# SC-2: Detect when a git-mutating target resolves to the live repo and BLOCK with
# a clear diagnostic before mutating. The live repo is $PARENT_REPO_DIR (the repo
# containing .opencode/), also reachable as $PROJECT_DIR / $project_root. A target
# that resolves to any of these paths is the live repo and MUST NOT be mutated.
# A legitimate isolated target (e.g. $TEST_PROJECT / $attempt_workdir inside the
# test home) is NOT the live repo and passes through unblocked.
__assert_not_live_root() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "BLOCKED: git-mutating target is empty — refusing to operate on an unresolved path" >&2
        return 1
    fi
    local resolved
    resolved="$(cd "$target" 2>/dev/null && pwd || echo "$target")"
    local live_root
    live_root="$(cd "$PARENT_REPO_DIR" 2>/dev/null && pwd || echo "$PARENT_REPO_DIR")"
    if [ "$resolved" = "$live_root" ]; then
        echo "BLOCKED: git-mutating target '$target' resolves to the live repo ($live_root) — refusing to mutate the live project root" >&2
        return 1
    fi
    return 0
}

# --- GitBucket container provisioning ---

GITBUCKET_PID_FILE=""
GITBUCKET_PORT_FILE=""
GITBUCKET_DATA_DIR=""

__ensure_gitbucket() {
    # Provisions JDK, downloads GitBucket JAR, starts GitBucket, generates token.
    # Idempotent: skips provisioning if already running.
    local project_root="$PARENT_REPO_DIR"
    local tools_dir="$project_root/.tools"
    local jdk_dir="$tools_dir/jdk"
    local gb_dir="$tools_dir/gitbucket"
    local gb_war="$gb_dir/gitbucket.war"
    local data_dir="$project_root/tmp/gitbucket-data"
    local pid_file="$project_root/tmp/.gitbucket.pid"
    local port_file="$project_root/tmp/.gitbucket.port"

    GITBUCKET_PID_FILE="$pid_file"
    GITBUCKET_PORT_FILE="$port_file"
    GITBUCKET_DATA_DIR="$data_dir"

    # Check if already running
    if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        local port
        port=$(cat "$port_file" 2>/dev/null || echo "")
        if [ -n "$port" ]; then
            export GITBUCKET_PORT="$port"
            export GB_HOST="http://localhost:$port"
            export GB_REPO="root/test-repo"
            export GB_PROTOCOL="http"
            # Re-authenticate gb CLI against the running instance so the full
            # GB_* set (including GB_TOKEN) is available on the idempotent path.
            # The token is read from the account page; fall back to root:root if
            # token generation fails so gb auth login still succeeds.
            local token=""
            local cookie_jar
            cookie_jar=$(mktemp)
            curl -s -c "$cookie_jar" -X POST "http://localhost:$port/signin" \
                -H "Content-Type: application/x-www-form-urlencoded" \
                --data-urlencode "userName=root" \
                --data-urlencode "password=root" \
                --data-urlencode "hash=" -o /dev/null 2>/dev/null || true
            curl -s -b "$cookie_jar" -X POST "http://localhost:$port/root/_personalToken" \
                -H "Content-Type: application/x-www-form-urlencoded" \
                --data-urlencode "note=test-token" -o /dev/null 2>/dev/null || true
            token=$(curl -s -b "$cookie_jar" "http://localhost:$port/root/_application" 2>/dev/null | grep -oE '[0-9a-f]{40}' | head -1 || true)
            rm -f "$cookie_jar"
            if [ -z "$token" ]; then
                export GB_TOKEN="root"
            else
                export GB_TOKEN="$token"
            fi
            gb auth login -H "$GB_HOST" -t "$GB_TOKEN" --protocol "$GB_PROTOCOL" >/dev/null 2>&1 || true
            return 0
        fi
    fi

    # SC-1: Provision JDK
    mkdir -p "$jdk_dir"
    if [ ! -f "$jdk_dir/.provisioned" ]; then
        echo "  [gitbucket] provisioning JDK..." >&2
        local jdk_url
        jdk_url=$(curl -sL "https://api.adoptium.net/v3/assets/version/%5B21%2C22%29?os=linux&architecture=x64&image_type=jre&project=jdk&page_size=1" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['binaries'][0]['package']['link'])" 2>/dev/null || true)
        if [ -z "$jdk_url" ]; then
            echo "  [gitbucket] FATAL: could not resolve JDK download URL" >&2
            return 1
        fi
        local jdk_archive="$jdk_dir/jdk.tar.gz"
        curl -sL -o "$jdk_archive" "$jdk_url" 2>/dev/null || {
            echo "  [gitbucket] FATAL: JDK download failed" >&2
            return 1
        }
        tar -xzf "$jdk_archive" -C "$jdk_dir" --strip-components=1 2>/dev/null || {
            echo "  [gitbucket] FATAL: JDK extraction failed" >&2
            return 1
        }
        rm -f "$jdk_archive"
        touch "$jdk_dir/.provisioned"
        echo "  [gitbucket] JDK provisioned at $jdk_dir" >&2
    fi
    local java_cmd="$jdk_dir/bin/java"
    if [ ! -x "$java_cmd" ]; then
        # Try alternate extraction layout (some archives use jdk-*/ subdir)
        java_cmd=$(find "$jdk_dir" -name 'java' -type f 2>/dev/null | head -1)
    fi
    if [ -z "$java_cmd" ] || [ ! -x "$java_cmd" ]; then
        echo "  [gitbucket] FATAL: java binary not found in $jdk_dir" >&2
        return 1
    fi

    # SC-2: Download GitBucket JAR
    mkdir -p "$gb_dir"
    if [ ! -f "$gb_war" ]; then
        echo "  [gitbucket] downloading GitBucket JAR..." >&2
        local release_url
        release_url=$(curl -sL "https://api.github.com/repos/gitbucket/gitbucket/releases/latest" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print([a['browser_download_url'] for a in d['assets'] if a['name'].endswith('.war')][0])" 2>/dev/null || true)
        if [ -z "$release_url" ]; then
            echo "  [gitbucket] FATAL: could not resolve GitBucket release URL" >&2
            return 1
        fi
        curl -sL -o "$gb_war" "$release_url" 2>/dev/null || {
            echo "  [gitbucket] FATAL: GitBucket download failed" >&2
            return 1
        }
        echo "  [gitbucket] GitBucket JAR downloaded to $gb_war" >&2
    fi

    # SC-3: Start GitBucket on auto-assigned port
    mkdir -p "$data_dir"
    echo "  [gitbucket] starting GitBucket..." >&2
    "$java_cmd" -jar "$gb_war" --port=0 --gitbucket.home="$data_dir" &
    local gb_pid=$!
    echo "$gb_pid" > "$pid_file"

    # Wait for GitBucket to start and discover the auto-assigned port
    local port=""
    local wait_seconds=0
    while [ $wait_seconds -lt 30 ]; do
        # Discover port from process listening on 127.0.0.1 or *
        port=$(ss -tlnp 2>/dev/null | grep "$gb_pid" | awk '{print $4}' | grep -oP '\d+$' | head -1 || true)
        if [ -n "$port" ]; then
            break
        fi
        sleep 1
        wait_seconds=$((wait_seconds + 1))
    done

    if [ -z "$port" ]; then
        echo "  [gitbucket] FATAL: GitBucket did not write port file within 30s" >&2
        kill "$gb_pid" 2>/dev/null || true
        return 1
    fi
    echo "$port" > "$port_file"
    export GITBUCKET_PORT="$port"
    export GB_HOST="http://localhost:$port"
    # SC19: export the test-env constants GB_REPO and GB_PROTOCOL for the provisioned
    # test instance, alongside GB_HOST/GITBUCKET_PORT/GB_TOKEN, so the full GB_* suite
    # reaches the isolated executor. These are the harness's test-env constants.
    export GB_REPO="root/test-repo"
    export GB_PROTOCOL="http"
    echo "  [gitbucket] started on port $port (PID $gb_pid)" >&2

    # Wait for HTTP readiness
    local ready=0
    wait_seconds=0
    while [ $wait_seconds -lt 30 ]; do
        if curl -s "http://localhost:$port/" >/dev/null 2>&1; then
            ready=1
            break
        fi
        sleep 1
        wait_seconds=$((wait_seconds + 1))
    done
    if [ "$ready" -ne 1 ]; then
        echo "  [gitbucket] FATAL: GitBucket not ready after 30s" >&2
        kill "$gb_pid" 2>/dev/null || true
        return 1
    fi

    # SC-4: Generate admin token.
    # GitBucket 4.46.1 exposes NO REST token endpoint — POST /api/v3/tokens
    # returns {"message":"Not Found"} — so the token must be generated through
    # the web form: sign in as root/root to obtain a session cookie, then POST
    # /:userName/_personalToken and read the generated token back from the
    # account page. A real token is required because `gb auth login` rejects
    # the raw password with HTTP 401.
    local token=""
    local cookie_jar
    cookie_jar=$(mktemp)
    # Sign in to obtain a session cookie (GitBucket default admin: root/root).
    curl -s -c "$cookie_jar" -X POST "http://localhost:$port/signin" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "userName=root" \
        --data-urlencode "password=root" \
        --data-urlencode "hash=" -o /dev/null 2>/dev/null || true
    # Generate a personal access token via the web form.
    curl -s -b "$cookie_jar" -X POST "http://localhost:$port/root/_personalToken" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "note=test-token" -o /dev/null 2>/dev/null || true
    # Read the generated token back from the account page.
    token=$(curl -s -b "$cookie_jar" "http://localhost:$port/root/_application" 2>/dev/null | grep -oE '[0-9a-f]{40}' | head -1 || true)
    rm -f "$cookie_jar"
    if [ -z "$token" ]; then
        echo "  [gitbucket] WARNING: could not generate admin token — using default root:root" >&2
        export GB_TOKEN="root"
    else
        export GB_TOKEN="$token"
        echo "  [gitbucket] admin token generated" >&2
    fi

    # SC-1: Authenticate the gb CLI against the provisioned instance so that
    # `gb auth status` succeeds and `gb repo view` is authorized. Without this
    # login the CLI reports not-authenticated even though the instance is up.
    gb auth login -H "$GB_HOST" -t "$GB_TOKEN" --protocol "$GB_PROTOCOL" >/dev/null 2>&1 || {
        echo "  [gitbucket] WARNING: gb auth login failed" >&2
    }

    # SC-5: Create test repo via API (no gb config needed — curl with basic auth)
    curl -s -u root:root -X POST "http://localhost:$port/api/v3/user/repos" \
        -H "Content-Type: application/json" \
        -d '{"name":"test-repo"}' >/dev/null 2>&1 || true
    echo "  [gitbucket] test repo created via API" >&2

    # SC-3: remote-wiring is deliberately NOT performed here. This function is a
    # pure provisioner (JDK, GitBucket, token, test repo) — it performs NO git-mutating
    # operation. The GitBucket origin is wired by behavior_run() against the validated
    # isolated attempt_workdir AFTER that isolated repo is established (helpers.sh
    # lines 645-654). Keeping remote-wiring out of __ensure_gitbucket() ensures the
    # block cannot run before an isolated target exists and cannot hit the live repo.
}

__reset_gitbucket() {
    # SC-6: Kill process, delete data dir, re-start fresh
    local pid_file="${GITBUCKET_PID_FILE:-$PARENT_REPO_DIR/tmp/.gitbucket.pid}"
    local data_dir="${GITBUCKET_DATA_DIR:-$PARENT_REPO_DIR/tmp/gitbucket-data}"

    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || true)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "  [gitbucket] killing PID $pid..." >&2
            kill "$pid" 2>/dev/null || true
            sleep 2
            # Force kill if still alive
            kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi

    if [ -d "$data_dir" ]; then
        echo "  [gitbucket] removing data dir..." >&2
        rm -rf "$data_dir"
    fi

    rm -f "${GITBUCKET_PORT_FILE:-$PARENT_REPO_DIR/tmp/.gitbucket.port}"
    unset GITBUCKET_PORT

    # Re-start fresh
    __ensure_gitbucket
}

__kill_gitbucket() {
    # Kill GitBucket process without restarting (for --clean-all)
    local pid_file="${GITBUCKET_PID_FILE:-$PARENT_REPO_DIR/tmp/.gitbucket.pid}"
    local data_dir="${GITBUCKET_DATA_DIR:-$PARENT_REPO_DIR/tmp/gitbucket-data}"
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || true)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            sleep 1
            kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
    rm -f "$PARENT_REPO_DIR/tmp/.gitbucket.port"
    # SC9: remove the GitBucket data dir so --clean-all leaves no provisioned state.
    rm -rf "$GITBUCKET_DATA_DIR"
    # SC9: remove behavior-isolated workdirs, which may hold the multi-submodule
    # fixture clones (test-submodule-1, test-submodule-2) provisioned by Phase 3.
    if [ -d "$PARENT_REPO_DIR/tmp/behavior-isolated" ]; then
        rm -rf "$PARENT_REPO_DIR/tmp/behavior-isolated"*
    fi
    unset GITBUCKET_PORT
}

# --- End GitBucket container provisioning ---

# Prepend .tools/opencode/ to PATH so the standalone binary is found before /snap/bin/opencode.
# The snap binary hardcodes SNAP_USER_DATA=~/snap/opencode/ and ignores XDG env vars,
# making it impossible to isolate test runs from production state.
if [ -x "$PARENT_REPO_DIR/.tools/opencode/opencode" ]; then
    export PATH="$PARENT_REPO_DIR/.tools/opencode:$PATH"
fi

OPENCODE_CMD=("opencode")
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PARENT_REPO_DIR/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

BEHAVIOR_MAX_RETRIES="${BEHAVIOR_MAX_RETRIES:-2}"
BEHAVIOR_RETRY_DELAY="${BEHAVIOR_RETRY_DELAY:-30}"

__model_slug() {
    local model="$1"
    echo "$model" | tr '/:@' '-'
}

__artifact_dir() {
    local scenario_name="$1"
    local model="$2"
    local phase="${BEHAVIOR_PHASE:-GREEN}"
    local slug
    slug=$(__model_slug "$model")
    local base="$PARENT_REPO_DIR/tmp/behavioral-evidence-${scenario_name}-${phase}-${slug}"
    local dir="$base"
    local suffix=0
    while [ -d "$dir" ]; do
        suffix=$((suffix + 1))
        dir="${base}-${suffix}"
    done
    echo "$dir"
}

__export_sqlite_to_yaml() {
    local yaml_output_file="$1"
    local stdout_file="${2:-}"
    local stderr_file="${3:-}"
    local db_found=0
    local db_path=""

    # Search stderr first — TEST_HOME= is with-test-home's OWN emission to
    # stderr (§10.3), while stdout may contain agent-echoed TEST_HOME markers
    # from scenario evidence (fixture-simulated or quoted file content), which
    # poisoned the stdout-first search and produced source_db: MISSING even
    # when stderr carried the real marker (#2432 SC-13 R-18 harness fold-in).
    # stdout remains a fallback for invocations that emit only there.
    local test_home=""
    if [ -n "$stderr_file" ] && [ -f "$stderr_file" ]; then
        test_home=$(grep '^TEST_HOME=' "$stderr_file" | head -1 | sed 's/^TEST_HOME=//' || true)
    fi
    if [ -z "$test_home" ] && [ -n "$stdout_file" ] && [ -f "$stdout_file" ]; then
        test_home=$(grep '^TEST_HOME=' "$stdout_file" | head -1 | sed 's/^TEST_HOME=//' || true)
    fi
    if [ -n "$test_home" ]; then
        local candidate="$test_home/.local/share/opencode/opencode.db"
        if [ -f "$candidate" ]; then
            db_path="$candidate"
            db_found=1
        fi
    fi

    if [ "$db_found" -eq 0 ]; then
        echo "source_db: MISSING" > "$yaml_output_file"
        return
    fi

    python3 -c "
import json, os, sqlite3, sys

db_path = '$db_path'
output_file = '$yaml_output_file'

try:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(\"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name\")
    tables = [row['name'] for row in cursor.fetchall()]

    result = {
        'source_db': db_path,
        'harness_version': ${BEHAVIOR_HARNESS_VERSION},
        'tables': {}
    }

    for table_name in tables:
        cursor.execute(f'PRAGMA table_info(\"{table_name}\")')
        columns = [row['name'] for row in cursor.fetchall()]
        cursor.execute(f'SELECT * FROM \"{table_name}\"')
        rows = [dict(row) for row in cursor.fetchall()]
        result['tables'][table_name] = {
            'columns': columns,
            'rows': rows
        }

    conn.close()

    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2, default=str)

except Exception as e:
    with open(output_file, 'w') as f:
        json.dump({
            'source_db': db_path,
            'harness_version': ${BEHAVIOR_HARNESS_VERSION},
            'export_error': str(e)
        }, f, indent=2)
" 2>/dev/null || echo "source_db: MISSING" > "$yaml_output_file"
}

# ══════════════════════════════════════════════════════════════════════════════
# Scope G (#2427): Semantic Continuous Monitoring — tests-v2/AGENTS.md §14
# ══════════════════════════════════════════════════════════════════════════════
# Opt-in via BEHAVIOR_SEMANTIC_MONITOR=1. Polls the live session DB of the
# running opencode process at BEHAVIOR_MONITOR_INTERVAL-second intervals and
# semantically evaluates the event stream against the §14 hard-abort signals.
# On abort: kill the run, export session.yaml per §10.5, record the semantic
# diagnosis. Return 0 when the run finished normally, 1 when the monitor
# aborted it. The monitor NEVER evaluates model output quality — it judges
# run PROGRESSION only (artifact-only paradigm preserved; verdicts remain the
# orchestrator's job).
#
# GNU `timeout` is FORBIDDEN here (§5 Bash Tool Timeout Mandate): the kill on
# abort is the monitor's own signal handler, not a timeout wrapper.

BEHAVIOR_MONITOR_INTERVAL="${BEHAVIOR_MONITOR_INTERVAL:-30}"
# .opencode#2441: early-termination + three-signal monitoring declarations.
# Optional per scenario; unset means the corresponding signal is skipped
# gracefully with no change to existing behavior (spec R-2).
BEHAVIOR_EXPECTED_ARTIFACT="${BEHAVIOR_EXPECTED_ARTIFACT:-}"
# Optional content pattern: GREEN fires only when the artifact exists AND
# contains this pattern (existence alone can match a mid-emission skeleton —
# observed .opencode#2430 SC-2 run 14: GREEN fired on the stage-1 skeleton
# before the stage-3 guard emission).
BEHAVIOR_EXPECTED_ARTIFACT_GREP="${BEHAVIOR_EXPECTED_ARTIFACT_GREP:-}"
BEHAVIOR_GOAL_ACTIONS="${BEHAVIOR_GOAL_ACTIONS:-}"
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS="${BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS:-}"
# .opencode#2430 finding: signal 2 (task running >=2 polls) false-fires on
# long-dispatch scenarios whose sub-agent legitimately runs for hours while
# streaming events. Refined predicate: stuck = task running AND zero event
# growth across BEHAVIOR_STUCK_TASK_POLLS consecutive polls (default 2 —
# preserves the §14 frozen-DB semantics; a live sub-agent streams deltas).
BEHAVIOR_STUCK_TASK_POLLS="${BEHAVIOR_STUCK_TASK_POLLS:-2}"
BEHAVIOR_MONITOR_MAX_POLLS="${BEHAVIOR_MONITOR_MAX_POLLS:-30}"
# R-18 fold-in (2432): 20000 killed productive write-transitions on 27B models (trace: 25K cumulative during valid derivation); calibrated to 60000, env-respecting
BEHAVIOR_MONITOR_MAX_REASONING="${BEHAVIOR_MONITOR_MAX_REASONING:-60000}"
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD="${BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD:-3}"
# .opencode#2456 SC-2 (plan-01 Item 2): classification dispatch configuration.
# The monitor dispatches a monitoring classification sub-agent that semantically
# classifies run state in the sub-agent's OWN context (never shell heuristics),
# anchored to the scenario's goal/expected-behavior context (the monitored
# run's prompt). Enum: progressing-directionally / off-track / undetermined.
# Checkpoint policy bounds per-poll cost (§14): a dispatch fires on a poll
# where the event stream changed since the last classification, after a
# minimum poll gap, under a per-attempt dispatch ceiling; a final dispatch is
# guaranteed before MONITOR-COMPLETE (at least one classification per
# monitored run). The classifier runs in its OWN lightweight test home
# (harness standalone binary, env -i isolation) — never the parent shell,
# never the monitored run's session DB. Its session export is persisted to
# the scenario evidence directory as classifier-session.yaml (a separate
# dispatch — never a re-export of the monitored run's session.yaml). All of
# this only executes inside __semantic_monitor (BEHAVIOR_SEMANTIC_MONITOR=1);
# unset → no monitor, no classifier (backward compat).
BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS="${BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS:-3}"
BEHAVIOR_MONITOR_CLASSIFY_MAX="${BEHAVIOR_MONITOR_CLASSIFY_MAX:-3}"
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT="${BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT:-600}"
# .opencode#2456 R-13 amendment (2026-09-23): consecutive dispatch-failure
# ceiling. A classification dispatch that produces no parseable classification
# is a DISPATCH FAILURE event (not a classification); 3 consecutive failures
# halt monitoring with a HARNESS_FAILURE-class notification.
BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING="${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING:-3}"
# .opencode#2456 SC-22 (plan-06, R-21): classification-freshness bound on
# abort suppression. A progressing classification suppresses mechanical
# abort signals ONLY while the verdict is FRESH: the monitor re-classifies
# at least every BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW polls (default 3)
# and on every new abort-signal event BEFORE the suppression decision. A
# stale progressing verdict never suppresses. Alias env
# BEHAVIOR_CLASSIFY_FRESHNESS_POLLS is honored when the primary name is
# unset. Set BEHAVIOR_MONITOR_FRESHNESS_ENFORCE=0 to restore pre-SC-22
# suppression behavior (backward-compat escape hatch).
BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW="${BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW:-${BEHAVIOR_CLASSIFY_FRESHNESS_POLLS:-3}}"
BEHAVIOR_MONITOR_FRESHNESS_ENFORCE="${BEHAVIOR_MONITOR_FRESHNESS_ENFORCE:-1}"

# .opencode#2456 SC-2: dispatch the monitoring classification sub-agent.
# Runs the harness's own standalone opencode binary in a lightweight,
# freshly-provisioned classifier test home (env -i isolation, seeded model
# config in the same shape seed_model_config() writes for behavioral runs) so
# the classification is produced in the sub-agent's OWN context and session
# DB — never in the parent shell, never in the monitored run's session DB,
# never production state (standalone binary only; /snap/bin/opencode and
# `snap run` are forbidden). Classification input = the scenario's mechanically
# verifiable goal condition (SC-2 amendment 2026-09-22: the scenario-declared
# goal artifact + required content pattern + declared goal actions, with the
# per-poll art_status — folded into the digest's goal_condition object; the
# monitored run's prompt prose is NEVER the direction anchor) + run evidence
# excerpts derived ONLY from message parts, reasoning parts,
# and tool calls in the run's live session DB (SC-14 admissible-evidence
# rule; activity counters are never the classification basis). The
# classifier's session DB is exported to
# $BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}.yaml
# (canonical staging path — the post-run and abort artifact blocks copy it
# into the scenario evidence directory as classifier-session.yaml; a
# per-dispatch audit copy lands as ...-poll${poll}.yaml). Echoes
# "<classification>|<failure_mode>": classification is the parsed taxonomy
# value (progressing-directionally|off-track|undetermined) or EMPTY when the
# response carried none; failure_mode ∈ {ok, starved-timeout-kill,
# digest-read-failed, empty-response, unparsed-response} (R-13 amended,
# .opencode#2456 2026-09-23: an empty classification is a DISPATCH FAILURE —
# the caller records the attempt + failure mode in the poll evidence, never
# silently; it is NOT a classification: no halt-class trigger, no
# undetermined-cycle ceiling increment, retried per the checkpoint policy). Bounded: the dispatch is
# killed by the monitor after BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT seconds (the
# monitor's own kill signal handler — GNU `timeout` stays forbidden per §5).
__classify_run_state() {
    local db="$1"
    local art_status="$2"
    local model="$3"
    local scenario_name="$4"
    local attempt="$5"
    local poll="$6"

    local digest
    # SC-2 amendment 2026-09-22: the scenario-declared verifiable goal
    # condition is folded into the digest (goal_condition object) — passed via
    # command-scoped env so the digest subprocess sees the declared values
    # regardless of the caller's export state. art_status (arg 2) is the
    # per-poll mechanically computed artifact status.
    digest=$(__CLS_GOAL_ARTIFACT="${BEHAVIOR_EXPECTED_ARTIFACT:-}" \
        __CLS_GOAL_PATTERN="${BEHAVIOR_EXPECTED_ARTIFACT_GREP:-}" \
        __CLS_GOAL_ART_STATUS="$art_status" \
        python3 - "$db" <<'CLSDIGEST'
import json, os, sqlite3, sys
db = sys.argv[1]
try:
    conn = sqlite3.connect(db)
    c = conn.cursor()
    rows = c.execute("SELECT seq, data FROM event ORDER BY seq").fetchall()
    conn.close()
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(0)
tools = []; texts = []; reasons = []; goal_hits = []
declared = [n.strip() for n in (os.environ.get("BEHAVIOR_GOAL_ACTIONS", "") or "").split(",") if n.strip()]
for seq, data in rows:
    try:
        d = json.loads(data or "{}")
    except Exception:
        continue
    part = d.get("part")
    if not isinstance(part, dict):
        continue
    ptype = part.get("type", "")
    if ptype == "tool":
        st = (part.get("state") or {}).get("status", "?")
        inp = json.dumps((part.get("state") or {}).get("input", {}), sort_keys=True)[:120]
        name = part.get("tool", "?")
        tools.append(f"{name}[{st}] {inp}")
        if st == "completed" and name in declared:
            goal_hits.append(name)
    elif ptype == "text" and str(part.get("text", "")).strip():
        texts.append(str(part.get("text"))[:200])
    elif "reasoning" in ptype and str(part.get("text", "")):
        reasons.append(str(part.get("text"))[-300:])
goal_condition = {
    "goal_artifact": os.environ.get("__CLS_GOAL_ARTIFACT", "") or None,
    "required_content_pattern": os.environ.get("__CLS_GOAL_PATTERN", "") or None,
    "declared_goal_actions": declared,
    "declared_goal_actions_hit": sorted(set(goal_hits)),
    "artifact_status_at_dispatch": os.environ.get("__CLS_GOAL_ART_STATUS", "") or None,
}
print(json.dumps({
    "event_count": len(rows),
    "goal_condition": goal_condition,
    "tool_calls_recent": tools[-12:],
    "message_parts_recent": texts[-3:],
    "reasoning_tails_recent": reasons[-2:],
    "reasoning_parts_total": len(reasons),
}, indent=1))
CLSDIGEST
) || digest='{"error": "digest_read_failed"}'

    # Lightweight classifier test home: fresh XDG-isolated home per dispatch so
    # the classifier session DB is its OWN (separate dispatch — its export can
    # never be byte-identical to the monitored run's session.yaml).
    local cls_home="$PARENT_REPO_DIR/tmp/classifier-home-$(date +%Y%m%d-%H%M%S)-${poll}-$$"
    mkdir -p "$cls_home/.config/opencode" "$cls_home/workdir" "$cls_home/.cache" "$cls_home/.local/share" "$cls_home/.local/state"
    local bare="${model#ollama/}"
    cat > "$cls_home/.config/opencode/opencode.jsonc" <<JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "$model",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "$bare": {}
      }
    }
  },
  "permission": {
    "external_directory": {
      "**": "allow"
    }
  }
}
JSONC
    git -q init "$cls_home/workdir" 2>/dev/null || true

    local cls_prompt
    cls_prompt=$(cat <<CLSPROMPT
You are the monitoring classification sub-agent of an automated behavioral-test harness (tests-v2/AGENTS.md §14 semantic monitoring). Your ONLY job is to semantically classify the monitored run's progress. Do NOT use any tools. Respond with EXACTLY one line and nothing else:

classification: <progressing-directionally|off-track|undetermined>

DIRECTION ANCHOR — the scenario's mechanically verifiable goal condition is the goal_condition object in the digest below (scenario-declared goal artifact + required content pattern + declared goal actions, plus the artifact status mechanically computed at this dispatch). It is the ONLY direction anchor. Classify the run evidence against THAT condition — never against the monitored run's prompt prose (prompt text appearing in the evidence excerpts is context, not the goal; only the declared verifiable condition defines the goal).

Classification definitions (direction-anchored to goal_condition):
- progressing-directionally: the evidence shows work moving toward satisfying the goal_condition. A run ACTIVELY PRODUCING the declared goal artifact — appending/growing the artifact toward the required content pattern (artifact_status=partial/absent is normal mid-production) — IS progressing, even before the required content pattern appears: the required pattern's PRESENCE is the completion condition, NOT a prerequisite for classifying progressing. Also progressing: declared goal actions completing. (R-18 fold-in, .opencode#2456 SC-5: a partial artifact being produced toward the pattern is movement toward the goal, not off-track.)
- off-track: the evidence is NOT directed at satisfying the goal_condition — the run is NOT producing the goal artifact and/or not completing goal actions (repetition, loops, unrelated actions, prescribed busy-work the condition never requires, stalled deliberation). Producing a partial goal artifact is NOT off-track.
- undetermined: the evidence is insufficient to judge direction against the condition, OR the scenario declares no verifiable condition (no goal artifact, no content pattern, no goal actions).

MONITORED RUN EVIDENCE — excerpts derived from the run's message parts, reasoning parts, and tool calls in its session DB, with the scenario's verifiable goal_condition folded in:
${digest}

Respond with only the classification line.
CLSPROMPT
)

    local cls_stdout="$cls_home/stdout.log"
    local cls_stderr="$cls_home/stderr.log"
    echo "TEST_HOME=$cls_home" > "$cls_home/test-home-marker.txt"

    # setsid: cls_pid becomes session/group leader so the bounded-wait kill
    # takes down the full opencode process tree (same pattern as the §14 abort
    # path — wrapper-only kills orphan grandchildren). fd 200 (the behavior_run
    # flock) is closed for the classifier so a killed/killed-out dispatch can
    # never hold the lock past behavior_run (#2432 lock-inheritance lesson).
    local cls_pid=""
    setsid env -i \
        HOME="$cls_home" \
        PATH="$PARENT_REPO_DIR/.tools/opencode:$PATH" \
        XDG_CONFIG_HOME="$cls_home/.config" \
        XDG_CACHE_HOME="$cls_home/.cache" \
        XDG_DATA_HOME="$cls_home/.local/share" \
        XDG_STATE_HOME="$cls_home/.local/state" \
        XDG_RUNTIME_DIR="$cls_home" \
        SNAP_USER_DATA="$cls_home/snap" \
        SNAP_USER_COMMON="$cls_home/snap-common" \
        GIT_CONFIG_NOSYSTEM=1 \
        SHELL="${SHELL:-/bin/bash}" \
        USER=opencode-test-user \
        LOGNAME=opencode-test-user \
        LANG="${LANG:-C.UTF-8}" \
        TERM="${TERM:-dumb}" \
        opencode run "$cls_prompt" --model "$model" \
        > "$cls_stdout" 2> "$cls_stderr" 200>&- &
    cls_pid=$!

    # R-13: starvation tracking — a dispatch killed at the bounded-wait cap
    # produced no parseable classification; the failure mode is reported to
    # the caller (recorded in the poll evidence, never silent).
    local starved=0
    local waited=0
    while kill -0 "$cls_pid" 2>/dev/null && [ "$waited" -lt "$BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT" ]; do
        sleep 5
        waited=$((waited + 5))
    done
    if kill -0 "$cls_pid" 2>/dev/null; then
        starved=1
        kill -TERM -- "-$cls_pid" 2>/dev/null || kill "$cls_pid" 2>/dev/null || true
        sleep 2
        kill -KILL -- "-$cls_pid" 2>/dev/null || kill -9 "$cls_pid" 2>/dev/null || true
    fi
    wait "$cls_pid" 2>/dev/null || true

    # Persist the classifier's OWN session export to the canonical staging
    # path (last dispatch of the attempt wins = final classified state) plus a
    # per-dispatch audit copy. Reuses the harness exporter via a TEST_HOME
    # marker file (the classifier home is known by construction — no stdout/
    # stderr grep of the monitored run's output).
    local staging_yaml="$BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}.yaml"
    mkdir -p "$(dirname "$staging_yaml")"
    __export_sqlite_to_yaml "$staging_yaml" "" "$cls_home/test-home-marker.txt" || true
    cp "$staging_yaml" "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}-poll${poll}.yaml" 2>/dev/null || true

    local classification_value=""
    classification_value=$(grep -oE 'progressing-directionally|off-track|undetermined' "$cls_stdout" 2>/dev/null | head -1 || true)

    # R-13: on a dispatch that produced no parseable classification, preserve
    # the raw classifier stdout/stderr next to the session export — the
    # disposable home would otherwise destroy the raw response evidence the
    # recorded failure mode refers to.
    if [ -z "$classification_value" ]; then
        cp "$cls_stdout" "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-attempt${attempt}-poll${poll}.stdout.log" 2>/dev/null || true
        cp "$cls_stderr" "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-attempt${attempt}-poll${poll}.stderr.log" 2>/dev/null || true
    fi

    # R-13 failure-mode classification for the poll-evidence record.
    local fail_mode="ok"
    if [ -n "$classification_value" ]; then
        fail_mode="ok"
    elif [ "$starved" -eq 1 ]; then
        fail_mode="starved-timeout-kill"
    elif [ "${digest:0:10}" = '{"error": ' ]; then
        fail_mode="digest-read-failed"
    elif [ ! -s "$cls_stdout" ]; then
        fail_mode="empty-response"
    else
        fail_mode="unparsed-response"
    fi

    # Disposable home on a successful export (evidence already staged); keep
    # it on export failure so the classifier DB stays diagnosable.
    if ! grep -q "source_db: MISSING" "$staging_yaml" 2>/dev/null; then
        rm -rf "$cls_home"
    fi

    echo "${classification_value}|${fail_mode}"
}

# .opencode#2456 SC-3: write the durable determination record for a monitored
# run. Called from behavior_run()'s flag-gated post-run block, which both the
# natural-completion and monitor-abort paths flow through, so EVERY monitored
# run gets a record (R-8: written in the scenario evidence directory
# alongside session.yaml and the poll log). The record carries (a) the run's
# final classification — the taxonomy value produced by the SC-2
# classification dispatch (__classify_run_state), parsed from the persisted
# poll log's MONITOR-COMPLETE final_classification field, falling back to the
# last CLASSIFY dispatch value on the abort path — (b) poll-evidence
# references (monitor.log path + polls executed) and (c) run provenance
# (model, exit code). Schema is append-only-ready (R-8): the empty
# false_signal_annotations / orchestrator_decisions lists are the append
# targets for later lifecycle events (.opencode#2456 SC-10 false_signal
# annotations, SC-7 orchestrator decisions) — future fields are allowed by
# appending list items, never by rewriting recorded fields. YAML per the
# LLM-to-LLM data standard (080-code-standards.md). Flag-gated: only invoked
# under BEHAVIOR_SEMANTIC_MONITOR=1 (backward compat).
__write_determination_record() {
    local artifact_dir="$1"
    local poll_log="$2"
    local model="$3"
    local exit_code="$4"
    local scenario_name="$5"
    local attempt="$6"
    local phase="${BEHAVIOR_PHASE:-GREEN}"

    # Final classification: MONITOR-COMPLETE's final_classification field is
    # authoritative on the natural-completion path; on the abort path (no
    # MONITOR-COMPLETE line) fall back to the last CLASSIFY dispatch value.
    # "none"/UNPARSED means no taxonomy value was ever produced — recorded
    # honestly; downstream consumers treat a non-taxonomy classification as
    # undetermined-class.
    local classification=""
    classification=$(grep -oE 'final_classification=[a-z-]+' "$poll_log" 2>/dev/null | tail -1 | cut -d= -f2 || true)
    if [ -z "$classification" ] || [ "$classification" = "none" ]; then
        classification=$(grep -oE '→ (progressing-directionally|off-track|undetermined)' "$poll_log" 2>/dev/null | tail -1 | sed 's/^→ //' || true)
    fi
    [ -n "$classification" ] || classification="none"

    # Polls executed: MONITOR-COMPLETE polls=N (natural completion) or
    # ABORTED ... poll=N (§14 abort path).
    local polls=""
    polls=$(grep -oE 'polls=[0-9]+' "$poll_log" 2>/dev/null | tail -1 | cut -d= -f2 || true)
    if [ -z "$polls" ]; then
        polls=$(grep -oE 'poll=[0-9]+' "$poll_log" 2>/dev/null | tail -1 | cut -d= -f2 || true)
    fi
    [ -n "$polls" ] || polls=0

    # Run path: natural completion carries the MONITOR-COMPLETE marker; its
    # absence means the monitor aborted the run (§14 abort path).
    local run_path="natural-completion"
    if ! grep -q "MONITOR-COMPLETE" "$poll_log" 2>/dev/null; then
        run_path="monitor-abort"
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || true)

    cat > "$artifact_dir/determination.yaml" <<DET.EOF
determination_record:
  schema: determination-record
  schema_version: 1
  scenario_name: ${scenario_name}
  phase: ${phase}
  attempt: ${attempt}
  model: ${model}
  exit_code: ${exit_code}
  run_path: ${run_path}
  classification: ${classification}
  poll_evidence:
    monitor_log: ${artifact_dir}/monitor.log
    polls_executed: ${polls}
    classifier_session: ${artifact_dir}/classifier-session.yaml
  harness_version: ${BEHAVIOR_HARNESS_VERSION}
  recorded_at: ${timestamp}
  # Append-only lifecycle sections — future fields are allowed by appending
  # list items (never by rewriting recorded fields):
  #   false_signal_annotations — .opencode#2456 SC-10 monitor false-signal annotations
  #   orchestrator_decisions   — .opencode#2456 SC-7 recorded orchestrator decisions
  false_signal_annotations: []
  orchestrator_decisions: []
DET.EOF
}

# .opencode#2456 SC-10: false_signal appender. Appends ONE caller-provided
# annotation entry (a YAML list item, first line beginning with "- ") to the
# determination record's false_signal_annotations list under the R-8
# append-only semantics: recorded fields are NEVER rewritten — the
# declared-empty seed ("[]") is replaced only by the act of appending the
# first item; subsequent items are appended in place after the existing
# list block (never after later keys, never by rewriting). Annotations
# appear ONLY when an evaluation path has identified a wrong abort (never
# blanket). Invoked by the scenario's/evaluation phase at
# `__fold_false_signal <evidence-dir> <annotation>`.
__fold_false_signal() {
    local artifact_dir="$1"
    local annotation="$2"
    local det="$artifact_dir/determination.yaml"
    if [ ! -f "$det" ]; then
        det=$(ls "$artifact_dir"/*/determination.yaml 2>/dev/null | head -1 || true)
    fi
    if [ -z "$det" ] || [ ! -f "$det" ]; then
        echo "HARNESS_FAILURE: __fold_false_signal no determination record found under $artifact_dir (SC-10 fold requires a determination record)" >&2
        return 1
    fi
    if [ -z "$annotation" ]; then
        echo "HARNESS_FAILURE: __fold_false_signal called with an EMPTY annotation (SC-10 folds only identified wrong aborts — no blanket/empty folds)" >&2
        return 1
    fi
    local tmpf
    tmpf="$det.fold.$$"
    FOLD_ANNOTATION="$annotation" awk '
        BEGIN { ann = ENVIRON["FOLD_ANNOTATION"] }
        function flush_ann(    n, i, A) {
            n = split(ann, A, "\n")
            for (i = 1; i <= n; i++) print "    " A[i]
        }
        { lines[NR] = $0 }
        END {
            emitted = 0
            for (r = 1; r <= NR; r++) {
                line = lines[r]
                if (!emitted && line == "  false_signal_annotations: []") {
                    print "  false_signal_annotations:"
                    flush_ann()
                    emitted = 1
                    continue
                }
                print line
                if (!emitted && line == "  false_signal_annotations:") {
                    r++
                    while (r <= NR && lines[r] ~ /^    /) { print lines[r]; r++ }
                    flush_ann()
                    emitted = 1
                    r--
                }
            }
            if (!emitted) {
                printf "HARNESS_FAILURE: no false_signal_annotations field in %s (SC-10 appender requires the determination-record schema)\n", FILENAME > "/dev/stderr"
                exit 1
            }
        }
    ' "$det" > "$tmpf" && mv "$tmpf" "$det"
    return $?
}

# .opencode#2456 SC-9 (plan-03 Item 9): undetermined-cycle ceiling — state
# resolution. The cycle-counter state file is persisted ON DISK (survives
# process exit) so the count carries across invocations. Resolution rules:
#   synthetic fixtures (determination.yaml scenario_name ending in
#   "-synthetic"): the state file lives in the scenario's evidence root —
#   the parent directory two levels above the synthetic fixture dir, named
#   by the stripped scenario name (e.g.
#   tmp/2456/artifacts/<scenario>/undetermined-cycle-count).
#   real monitored runs: a fixed harness state file under tmp/ (never inside
#   the repo source tree, never touching production state).
__undetermined_cycle_state_file() {
    local artifact_dir="$1"
    local det="$artifact_dir/determination.yaml"
    if [ ! -f "$det" ]; then
        det=$(ls "$artifact_dir"/*/determination.yaml 2>/dev/null | head -1 || true)
    fi
    local scenario_name=""
    if [ -n "$det" ] && [ -f "$det" ]; then
        scenario_name=$(sed -n 's/^  scenario_name: //p' "$det" 2>/dev/null | head -1 || true)
    fi
    if [ -n "$scenario_name" ] && [[ "$scenario_name" == *-synthetic ]]; then
        # rep = the determination.yaml found; its dirname is the attempt dir,
        # the attempt dir's parent is the shared container — the state file
        # lives in evidence-root (the attempt dir's grandparent) regardless of
        # whether the caller passed the attempt dir or its container.
        local attempt_dir
        attempt_dir=$(dirname "$det")
        echo "$(dirname "$attempt_dir")/../${scenario_name%-synthetic}/undetermined-cycle-count"
    else
        echo "$PARENT_REPO_DIR/tmp/.undetermined-cycle-count"
    fi
}

# .opencode#2456 SC-9: undetermined-cycle counter. Increments the persisted
# counter ONLY when the determination record at <artifact_dir> carries
# classification: undetermined — non-undetermined determinations permit
# continuation and never touch the counter. The increment runs under the
# EXISTING flock discipline (tmp/.behavior-run.lock, flocked exclusive in a
# subshell so the fd is released on exit) — no new locking scheme.
__count_undetermined_cycle() {
    local artifact_dir="$1"
    local det="$artifact_dir/determination.yaml"
    if [ ! -f "$det" ]; then
        det=$(ls "$artifact_dir"/*/determination.yaml 2>/dev/null | head -1 || true)
    fi
    if [ -z "$det" ] || [ ! -f "$det" ]; then
        echo "HARNESS_FAILURE: __count_undetermined_cycle no determination record found under $artifact_dir (SC-9 counter requires a determination record)" >&2
        return 1
    fi
    if ! grep -q '^  classification: undetermined$' "$det"; then
        return 0
    fi
    local state_file
    state_file=$(__undetermined_cycle_state_file "$artifact_dir")
    mkdir -p "$(dirname "$state_file")"
    (
        flock -x -w 30 9 || {
            echo "HARNESS_FAILURE: lock contention acquiring $PARENT_REPO_DIR/tmp/.behavior-run.lock for the undetermined-cycle counter (waited 30s)" >&2
            return 1
        }
        SC9_CUR=$(cat "$state_file" 2>/dev/null || echo 0)
        case "$SC9_CUR" in ''|*[!0-9]*) SC9_CUR=0 ;; esac
        echo $((SC9_CUR + 1)) > "$state_file"
    ) 9>>"$PARENT_REPO_DIR/tmp/.behavior-run.lock"
    return $?
}

# .opencode#2456 SC-9: undetermined-ceiling gate. Returns 0 (continuation
# permitted) while the persisted counter is below the ceiling (default 3,
# UNDETERMINED_CYCLE_CEILING). At/above the ceiling emits a CEILING_REACHED
# mechanical block on stderr (FATAL: ... CEILING_REACHED ... stderr
# convention) and returns non-zero — undetermined retries are blocked. The
# block PERSISTS: the counter/state file survives on disk and the gate
# re-fires on every subsequent invocation until cleared by an explicit
# developer-remediation marker (<state_file>.developer-cleared — its
# presence authorizes the clearance, resets the counter, and permits
# continuation again).
__undetermined_ceiling_check() {
    local artifact_dir="$1"
    local state_file
    state_file=$(__undetermined_cycle_state_file "$artifact_dir")
    if [ -f "${state_file}.developer-cleared" ]; then
        echo 0 > "$state_file"
        return 0
    fi
    local count
    count=$(cat "$state_file" 2>/dev/null || echo 0)
    case "$count" in ''|*[!0-9]*) count=0 ;; esac
    if [ "$count" -ge "$UNDETERMINED_CYCLE_CEILING" ]; then
        echo "FATAL: CEILING_REACHED mechanical block — persisted undetermined-cycle counter at ${count} of ceiling ${UNDETERMINED_CYCLE_CEILING} (state file ${state_file}); undetermined retries are blocked. The block persists until developer-level remediation (create ${state_file}.developer-cleared to authorize the clearance, or remove the state file manually)." >&2
        return 1
    fi
    return 0
}

# .opencode#2456 SC-7: orchestrator decision-record write path. Validates the
# value-set {continue-new-dispatch, terminate-with-root-cause} (terminate
# requires a root cause) and appends exactly one entry to the determination
# record's orchestrator_decisions section (append-only semantics: entries are
# only added, existing fields are never rewritten). The decision is recorded
# AFTER the halt-class notification decision point (SC-6) — the entry this
# path writes is the record the SC-8 gate reads. Callers:
#   __record_orchestrator_decision <artifact_dir> --decision <value> \
#       [--root-cause "<text>"]
# Fails (non-zero) with a HARNESS_FAILURE message on value-set violation,
# missing root cause, or missing determination record — never silently no-ops.
__record_orchestrator_decision() {
    local artifact_dir="$1"
    shift
    local decision=""
    local root_cause=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --decision) decision="${2:-}"; shift 2 ;;
            --root-cause) root_cause="${2:-}"; shift 2 ;;
            *)
                echo "HARNESS_FAILURE: __record_orchestrator_decision invalid argument '$1' (usage: __record_orchestrator_decision <artifact_dir> --decision <continue-new-dispatch|terminate-with-root-cause> [--root-cause \"...\"])" >&2
                return 1
                ;;
        esac
    done
    case "$decision" in
        continue-new-dispatch) ;;
        terminate-with-root-cause)
            if [ -z "$root_cause" ]; then
                echo "HARNESS_FAILURE: decision 'terminate-with-root-cause' requires a root-cause (--root-cause) — SC-7 value-set contract (.opencode#2456: root-cause present when terminate-with-root-cause)" >&2
                return 1
            fi
            ;;
        *)
            echo "HARNESS_FAILURE: invalid decision '${decision}' — allowed value-set is {continue-new-dispatch, terminate-with-root-cause} (.opencode#2456 SC-7)" >&2
            return 1
            ;;
    esac
    local det="$artifact_dir/determination.yaml"
    if [ ! -f "$det" ]; then
        echo "HARNESS_FAILURE: no determination record at $det — SC-3 __write_determination_record must have run first (SC-7 appends to the existing record, never creates it)" >&2
        return 1
    fi
    # .opencode#2456 SC-13: diagnosis-before-retry gate. When the determination
    # record's final classification is non-progressing (off-track or
    # undetermined) AND an identifiable external cause exists in the run
    # evidence (orphaned/left-running run processes, provider quota/error
    # output, harness failure), the recorded decision MUST be
    # terminate-with-root-cause whose root_cause names the diagnosed cause —
    # a continue-new-dispatch on such a record is REJECTED with a validation
    # error naming the missing diagnosis (timer-escalation re-dispatch without
    # diagnosis is prohibited, R-9). The gate rewrites the decision to the
    # diagnosis-derived terminate-with-root-cause and records the diagnosed
    # root cause. Records without an identified cause keep the existing
    # value-set behavior (SC-7 unchanged); the SC-8 gate reads these records
    # unchanged (backward compatible).
    local sc13_class
    sc13_class="$(grep -E '^  classification: ' "$det" | head -1 | sed 's/^  classification: //' || true)"
    case "$sc13_class" in
        off-track|undetermined)
            local sc13_cause=""
            local sc13_diag_orphans=0
            local sc13_diag_provider=0
            local sc13_monitor="$artifact_dir/monitor.log"
            if grep -qiE 'left[ -]running|orphan' "$sc13_monitor" "$det" 2>/dev/null; then
                sc13_diag_orphans=1
            fi
            if grep -qiE 'spending limit|quota|rate.?limit|provider.*error|inference providers' \
                "$artifact_dir/stdout.log" "$artifact_dir/stderr.log" \
                "$artifact_dir/harness-stderr.log" "$sc13_monitor" 2>/dev/null; then
                sc13_diag_provider=1
            fi
            if [ "$sc13_diag_orphans" = "1" ]; then
                sc13_cause="orphaned/left-running run processes after the halt-class notification"
            fi
            if [ "$sc13_diag_provider" = "1" ]; then
                if [ -n "$sc13_cause" ]; then
                    sc13_cause="${sc13_cause}; provider quota/error output in the run evidence"
                else
                    sc13_cause="provider quota/error output in the run evidence"
                fi
            fi
            if [ -n "$sc13_cause" ]; then
                if [ "$decision" = "continue-new-dispatch" ]; then
                    echo "VALIDATION-ERROR: continue-new-dispatch REJECTED on the non-progressing record (classification '${sc13_class}') — the run evidence carries an identifiable external cause (${sc13_cause}) and the decision names no diagnosis; timer-escalation re-dispatch without diagnosis is prohibited (SC-13/R-9, .opencode#2456). Recording the diagnosis-derived terminate-with-root-cause decision instead." >&2
                elif [ -n "$root_cause" ] && ! printf '%s' "$root_cause" | grep -qiE 'orphan|left[ -]running|quota|spending limit|rate.?limit|provider'; then
                    echo "VALIDATION-ERROR: terminate-with-root-cause root_cause does not name the diagnosed external cause (${sc13_cause}) — a generic exit-code restatement is not diagnosis-derived (SC-13, .opencode#2456). Recording the diagnosed root cause instead." >&2
                fi
                decision="terminate-with-root-cause"
                root_cause="diagnosed external cause: ${sc13_cause} (run evidence: monitor.log/stdout.log/stderr.log of ${artifact_dir})"
            fi
            ;;
    esac
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || true)
    local entry="    - decision: ${decision}"
    if [ -n "$root_cause" ]; then
        entry="${entry}
      root_cause: ${root_cause}"
    fi
    entry="${entry}
      recorded_at: ${timestamp}"
    # Append-only: expand an empty orchestrator_decisions list inline on the
    # first entry; insert subsequent entries AFTER the last existing list
    # entry so recorded entries are preserved in insertion order (no rewrite
    # of recorded fields, R-8).
    awk -v block="$entry" '
        NR==FNR {
            if ($0 ~ /^  orchestrator_decisions: \[\][[:space:]]*$/) { key=FNR; empty=1 }
            else if ($0 ~ /^  orchestrator_decisions:/) key=FNR
            if (key && FNR > key) {
                indent = match($0, /[^ ]/) - 1
                if ($0 ~ /^[[:space:]]*$/) { blank=1 } else { blank=0 }
                if (blank) {
                    if (insec) { sect_end=FNR-1; insec=0 }
                }
                else if (indent <= 2) { if (insec) { sect_end=FNR-1 }; insec=0 }
                else { sect_end=FNR; insec=1 }
            }
            flines=FNR
            next
        }
        END { if (insec) sect_end=flines }
        empty && FNR==key {
            print "  orchestrator_decisions:"
            print block
            next
        }
        !empty && sect_end && FNR==sect_end {
            print
            print block
            next
        }
        !empty && !sect_end && FNR==key {
            print
            print block
            next
        }
        { print }
    ' "$det" "$det" > "$det.tmp" 2>/dev/null && mv "$det.tmp" "$det" || {
        rm -f "$det.tmp"
        echo "HARNESS_FAILURE: failed to append orchestrator decision entry to $det — record-rewrite failed (SC-7)" >&2
        return 1
    }
}

# .opencode#2456 SC-4: off-track notification routing (R-2). When the SC-2
# classification dispatch returns off-track, the monitor emits the orchestrator
# notification on stderr — the ORCHESTRATOR_DECISION_REQUIRED-class stderr
# convention (§14 stderr conventions, alongside FATAL:/HARNESS_FAILURE:) — and
# records the notification in the poll log (NOTIFY line, persisted to
# monitor.log per SC-1). Off-track runs NEVER continue silently: every
# off-track classification carries its notification (continuation without
# notification is the R-2 violation SC-4 closes). The halt mechanics (halting
# monitoring before any further dispatch) are SC-6's mechanism and are NOT
# part of this notification path. Flag-gated: reachable only inside
# __semantic_monitor (BEHAVIOR_SEMANTIC_MONITOR=1); unset → no monitor, no
# notification (backward compat).
__notify_offtrack() {
    local poll_id="$1"
    local dispatch_n="$2"
    local art_status_n="$3"
    local poll_log="$4"
    local scenario_name="$5"
    local attempt="$6"
    echo "ORCHESTRATOR_DECISION_REQUIRED: off-track — the SC-2 classification sub-agent classified monitored run '${scenario_name}' attempt ${attempt} OFF-TRACK (classification=off-track, dispatch #${dispatch_n}, poll ${poll_id}, artifact_status=${art_status_n}): the run is not progressing toward the scenario's declared verifiable goal condition. Off-track runs never continue silently (R-2, .opencode#2456 SC-4). Evidence: poll log ${poll_log} (CLASSIFY[poll ${poll_id}] line + run tails), classifier session export ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml. Orchestrator decision required (SC-6 halt+notify / SC-7 decision field)." >&2
    echo "NOTIFY[poll ${poll_id}]: ORCHESTRATOR_DECISION_REQUIRED emitted on stderr — classification=off-track, dispatch #${dispatch_n}/${BEHAVIOR_MONITOR_CLASSIFY_MAX}, artifact=${art_status_n} (R-2: off-track runs never continue silently; evidence pointers in the stderr notification)" >> "$poll_log"
}

# .opencode#2456 R-13 amendment (2026-09-23): pure decision function for one
# classification-dispatch result — the decoupling surface. A dispatch that
# returns a parsed taxonomy value is a CLASSIFICATION; a dispatch that
# returns none is a DISPATCH FAILURE (attempt + failure mode recorded by the
# caller), never a classification: no halt-class trigger of its own, no
# undetermined-cycle ceiling increment, retried per the checkpoint policy.
# Args: current_classification current_halt_class current_dispatch_failures
# dispatch_value. Echoes "<classification>|<halt_class>|<dispatch_failures>|<harness_failure_flag>".
# Dispatch-failure ceiling application (harness_failure_flag=1) is decided
# here; the HARNESS_FAILURE stderr emission (scenario context) stays with
# the caller.
__interpret_classify_dispatch() {
    local cur_cls="$1"
    local cur_halt="$2"
    local cur_fails="$3"
    local d_value="$4"
    local ceiling="${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING:-3}"
    if [ -n "$d_value" ]; then
        # Parsed classification: resets the consecutive dispatch-failure
        # counter and carries the routed halt-class state (SC-6 governs
        # parsed outcomes only — unchanged by the amendment).
        local new_halt=""
        case "$d_value" in
            off-track|undetermined) new_halt="$d_value" ;;
        esac
        echo "$d_value|$new_halt|0|0"
        return 0
    fi
    # Dispatch failure: no classification produced — classification_value is
    # UNCHANGED, halt_class is UNTOUCHED (parameters, not the failure itself,
    # decide halts), the failure counter increments, and the checkpoint
    # policy retries on a later qualifying poll. 3 consecutive failures trip
    # the harness-failure flag (ceiling configurable via env override).
    local new_fails=$((cur_fails + 1))
    local ceil_flag=0
    if [ "$new_fails" -ge "$ceiling" ]; then
        ceil_flag=1
    fi
    echo "$cur_cls|$cur_halt|$new_fails|$ceil_flag"
    return 0
}

# .opencode#2456 SC-6: halt-class notification routing (R-3). When the SC-2
# classification dispatch returns a halt-class trigger state (undetermined /
# excessive-without-classification / direction-deviation — the non-progressing
# outcomes of the classification taxonomy), the monitor emits the orchestrator
# notification on stderr — the ORCHESTRATOR_DECISION_REQUIRED-class stderr
# convention (SC-4's __notify_offtrack pattern, with the halt-class label) —
# and records the notification in the poll log (NOTIFY line, persisted to
# monitor.log per SC-1). The halt-class halt+notify path shares SC-4's
# notification shape; the halt mechanics (stop polling, stop dispatching,
# leave the run state for the orchestrator decision record per SC-7) are
# enforced by the caller. Flag-gated: reachable only inside __semantic_monitor
# (BEHAVIOR_SEMANTIC_MONITOR=1); unset → no monitor, no notification
# (backward compat).
__notify_haltclass() {
    local halt_state="$1"
    local poll_id="$2"
    local dispatch_n="$3"
    local art_status_n="$4"
    local poll_log="$5"
    local scenario_name="$6"
    local attempt="$7"
    local fail_mode_n="${8:-}"
    echo "ORCHESTRATOR_DECISION_REQUIRED: halt-class — the SC-2 classification sub-agent returned halt-class trigger state '${halt_state}' for monitored run '${scenario_name}' attempt ${attempt} (classification=${halt_state}, dispatch #${dispatch_n}, poll ${poll_id}, artifact_status=${art_status_n}${fail_mode_n:+, failure_mode=${fail_mode_n}}): the run state is non-progressing or unverifiable (halt-class trigger states: undetermined / excessive-without-classification / direction-deviation — the non-progressing outcomes of the classification taxonomy, .opencode#2456 SC-6). Monitoring is halted before any further dispatch (R-3); the run state is left for the orchestrator decision record (SC-7). Evidence: poll log ${poll_log} (CLASSIFY[poll ${poll_id}] line + run tails), classifier session export ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml." >&2
    echo "NOTIFY[poll ${poll_id}]: ORCHESTRATOR_DECISION_REQUIRED emitted on stderr — halt-class classification=${halt_state}, dispatch #${dispatch_n}/${BEHAVIOR_MONITOR_CLASSIFY_MAX}, artifact=${art_status_n}${fail_mode_n:+, failure_mode=${fail_mode_n}} (R-3: halt-class states halt monitoring and notify before any further dispatch; evidence pointers in the stderr notification)" >> "$poll_log"
}

__semantic_monitor() {
    # .opencode#2441 hardening: the poll body is best-effort reads under the
    # caller's `set -euo pipefail` — any transient read failure (log file not
    # yet created, SIGPIPE race in the ls|head DB pick, WAL lock) would
    # otherwise silently kill the whole scenario script. Run the entire body
    # in a subshell with set +e; the exit code still distinguishes
    # completed (0) from aborted (1).
    local run_pid="$1"
    local scenario_name="$2"
    local attempt="$3"
    local output_file="$4"
    local err_file="$5"
    local model="$6"
    # No run-prompt parameter (SC-2 amendment 2026-09-22): the classification
    # direction anchor is the scenario-declared verifiable goal condition
    # (BEHAVIOR_EXPECTED_ARTIFACT + BEHAVIOR_EXPECTED_ARTIFACT_GREP +
    # BEHAVIOR_GOAL_ACTIONS, resolved per poll as art_status) — folded into
    # the classifier digest by __classify_run_state. The monitored run's
    # prompt prose is never the anchor.

    (
    set +e

    local poll_log="$BEHAVIOR_LOG_DIR/$scenario_name/monitor-attempt${attempt}.log"
    mkdir -p "$(dirname "$poll_log")"
    : > "$poll_log"

    echo "# Semantic continuous monitoring poll log — scenario=${scenario_name} attempt=${attempt}" >> "$poll_log"
    echo "# Signals per tests-v2/AGENTS.md §14 (identical input >=3x, task() stuck >=2 polls, reasoning >${BEHAVIOR_MONITOR_MAX_REASONING} chars with <=1 new tool call, semantically off-track 2+ polls)" >> "$poll_log"

    local poll=0
    local prev_event_count=0
    local prev_tool_calls=0
    local prev_reasoning_chars=0
    local stuck_task_polls=0
    local offtrack_polls=0
    local frozen_reason_polls=0
    local prev_reason_hash=""
    local hopeless_polls=0
    local reasoning_total=0
    local test_home_dir=""
    local abort_reason=""
    # .opencode#2456 SC-2 classification-dispatch state (checkpoint policy).
    local classified_count=0
    local polls_since_classify=0
    local last_classified_event_count=0
    local classification_value=""
    # .opencode#2456 SC-6 halt-class trigger state (non-empty = halt+notify fired).
    local halt_class=""
    # .opencode#2456 R-13 amendment: consecutive classification-dispatch failure
    # state — a dispatch producing no parseable classification is a DISPATCH
    # FAILURE (not a classification); the counter tracks consecutive failures
    # (parsed-classification dispatch resets it) up to DISPATCH_FAIL_CEILING.
    local dispatch_failures=0
    local harness_failure_halt=0
    # .opencode#2456 SC-15 (plan-06 phase-6 item): poll-cadence floor state —
    # every POLL record is stamped with ts=<epoch> and the maximum
    # consecutive-poll gap is bounded by BEHAVIOR_POLL_CADENCE_MAX (default
    # 300s). A gap exceeding the floor emits a MONITOR-CADENCE-VIOLATION
    # stderr record naming the gap; the sleep loop is cadence-bounded so a
    # tick never overshoots the floor (long operations poll immediately).
    local BEHAVIOR_POLL_CADENCE_MAX="${BEHAVIOR_POLL_CADENCE_MAX:-300}"
    local prev_poll_ts=""
    local cadence_max_gap=0
    local now_ts
    now_ts=$(date +%s)

    while kill -0 "$run_pid" 2>/dev/null; do
        poll=$((poll + 1))
        if [ "$poll" -gt "$BEHAVIOR_MONITOR_MAX_POLLS" ]; then
            # .opencode#2456 SC-5 (progressing-continues, R-2): the max-polls
            # duration-cap termination path applies ONLY to non-progressing
            # states — undetermined / off-track / no-classification / silent.
            # A run whose last SC-2 classification is progressing-directionally
            # SHALL continue polling past the cap regardless of duration (R-2:
            # "Progressing runs SHALL continue polling regardless of duration").
            # The carve-out consults the LAST completed classification (the
            # checkpoint dispatches land before the cap when the event stream
            # is growing; an empty value means never-classified → non-progressing
            # → halted). Flag-gated by the enclosing BEHAVIOR_SEMANTIC_MONITOR=1
            # block — unset → no monitor, no classification, no carve-out
            # (backward compat, plan-02 "no flag changes in this phase").
            if [ "${classification_value:-}" = "progressing-directionally" ]; then
                echo "POLL ${poll}: ts=${ts} max-polls budget exceeded but run classified progressing-directionally (${classification_value}) — progressing runs continue polling regardless of duration (R-2, .opencode#2456 SC-5); continuing to poll" >> "$poll_log"
            else
                echo "POLL ${poll}: ts=${ts} max-polls budget exhausted — run outlived monitor budget, aborting (last classification=${classification_value:-none})" >> "$poll_log"
                abort_reason="max_polls_exhausted"
                break
            fi
        fi
        # .opencode#2456 SC-15: cadence-bounded sleep — poll immediately after
        # long operations (classification dispatches, DB reads) instead of a
        # fixed interval, so no tick overshoots the ≤300s floor. Sleep at most
        # the remaining budget since the previous poll's timestamp.
        local sleep_for="$BEHAVIOR_MONITOR_INTERVAL"
        if [ -n "$prev_poll_ts" ]; then
            now_ts=$(date +%s)
            local elapsed=$((now_ts - prev_poll_ts))
            local remaining=$((BEHAVIOR_POLL_CADENCE_MAX - elapsed))
            if [ "$remaining" -lt "$sleep_for" ]; then
                if [ "$remaining" -lt 0 ]; then
                    remaining=0
                fi
                sleep_for="$remaining"
            fi
        fi
        sleep "$sleep_for"

        # .opencode#2456 SC-15: stamp this poll's epoch and measure the
        # consecutive-poll gap against the floor. A gap exceeding
        # BEHAVIOR_POLL_CADENCE_MAX emits a MONITOR-CADENCE-VIOLATION stderr
        # record naming the gap (the violation record, not the sleep bound,
        # is the enforceable predicate surface).
        now_ts=$(date +%s)
        local gap=""
        if [ -n "$prev_poll_ts" ]; then
            gap=$((now_ts - prev_poll_ts))
            if [ "$gap" -gt "$cadence_max_gap" ]; then
                cadence_max_gap=$gap
            fi
            if [ "$gap" -gt "$BEHAVIOR_POLL_CADENCE_MAX" ]; then
                echo "MONITOR-CADENCE-VIOLATION gap=${gap}s max=${BEHAVIOR_POLL_CADENCE_MAX}s poll=${poll} consecutive-poll gap exceeded the poll-cadence floor (SC-15, .opencode#2456)" >&2
            fi
        fi
        prev_poll_ts=$now_ts
        local ts="$now_ts"

        # Newest test home DB = the current run's live session DB (§14 step 3).
        local db
        db=$(ls -t "$PARENT_REPO_DIR"/tmp/test-home-*/.local/share/opencode/opencode.db 2>/dev/null | head -1)
        if [ -z "$db" ] || [ ! -f "$db" ]; then
            echo "POLL ${poll}: ts=${ts} DB not yet provisioned (test home not created yet)" >> "$poll_log"
            continue
        fi

        # Extract the event stream (.opencode#2441 three-signal read):
        # tool calls with names/statuses, latest text + reasoning CONTENT
        # (not just char counts), identical-input repeats, task() running.
        # Schema (verified live): event.data JSON has {sessionID, part:{id,
        # type:tool|text|reasoning|step-start|step-finish, state:{status,input}}}.
        local stats
        stats=$(python3 - "$db" <<'MONPY'
import json, sqlite3, sys, os
db = sys.argv[1]
try:
    conn = sqlite3.connect(db)
    c = conn.cursor()
    rows = c.execute("SELECT seq, data FROM event ORDER BY seq").fetchall()
    conn.close()
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(0)
tools = {}; last_text = ""; last_reason = ""; reasoning_total = 0
for seq, data in rows:
    try:
        d = json.loads(data or "{}")
    except Exception:
        continue
    part = d.get("part")
    if not isinstance(part, dict):
        continue
    ptype = part.get("type", "")
    if ptype == "tool":
        st = (part.get("state") or {}).get("status", "?")
        tools[part.get("id", f"seq{seq}")] = {
            "tool": part.get("tool", "?"), "status": st,
            # R-18 fold-in (2432): full-input hash — 200-char truncation false-positived on progressive same-path writes (skeleton-first appends share the path prefix)
            "input": json.dumps((part.get("state") or {}).get("input", {}), sort_keys=True),
        }
    elif ptype == "text" and str(part.get("text", "")).strip():
        last_text = str(part.get("text"))[:150]
    elif "reasoning" in ptype and str(part.get("text", "")):
        reasoning_total += len(str(part.get("text", "")))
        last_reason = str(part.get("text"))[-150:]
completed_inputs = [json.dumps({"tool": v["tool"], "input": v["input"]}, sort_keys=True)
                    for v in tools.values() if v["status"] == "completed"]
identical_max = max([completed_inputs.count(x) for x in set(completed_inputs)], default=0)
import hashlib
reason_hash = hashlib.sha256(str(last_reason).encode()).hexdigest()[:16] if last_reason else ""
goal_hit = []
for name in [n.strip() for n in (os.environ.get("BEHAVIOR_GOAL_ACTIONS", "") or "").split(",") if n.strip()]:
    if any(v["tool"] == name and v["status"] == "completed" for v in tools.values()):
        goal_hit.append(name)
print(json.dumps({
    "event_count": len(rows),
    "tool_parts": len(tools),
    "reasoning_total": reasoning_total,
    "completed": sum(1 for v in tools.values() if v["status"] == "completed"),
    "running": [f"{v['tool']}:{v['input'][:60]}" for v in tools.values() if v["status"] == "running"][:1],
    "identical_input_max": identical_max,
    "reason_hash": reason_hash,
    "goal_actions_hit": goal_hit,
    "last_text": last_text,
    "last_reason": last_reason,
}))
MONPY
) || stats='{"error": "read_failed"}'

        # ── .opencode#2441 per-poll report (R-11/R-12): every poll performs a
        # three-signal semantic read and records ACTUAL content, not counters.
        local event_count tool_parts completed running identical_max goal_json last_text last_reason
        event_count=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('event_count', 0))" 2>/dev/null || echo 0)
        tool_parts=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_parts', 0))" 2>/dev/null || echo 0)
        completed=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('completed', 0))" 2>/dev/null || echo 0)
        running=$(echo "$stats" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin).get('running', [])))" 2>/dev/null || echo "[]")
        identical_max=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('identical_input_max', 0))" 2>/dev/null || echo 0)
        goal_json=$(echo "$stats" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin).get('goal_actions_hit', [])))" 2>/dev/null || echo "[]")
        last_text=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('last_text', ''))" 2>/dev/null || echo "")
        last_reason=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('last_reason', ''))" 2>/dev/null || echo "")
        local new_tool_calls=$((completed - prev_tool_calls))

        reasoning_total=$(echo "$stats" | python3 -c "import json,sys; print(json.load(sys.stdin).get('reasoning_total', 0))" 2>/dev/null || echo 0)
        # Resolve the run's test home once (with-test-home emits TEST_HOME=<path> to stderr).
        if [ -z "$test_home_dir" ]; then
            test_home_dir=$(grep '^TEST_HOME=' "$err_file" 2>/dev/null | head -1 | sed 's/^TEST_HOME=//' || true)
        fi

        # Signal (c) (.opencode#2441 R-1): on-disk expected artifact in the run's
        # test home. BEHAVIOR_EXPECTED_ARTIFACT is test-home-relative when it
        # does not start with "/". Also tail the run logs each poll (developer
        # directive: actually check logs + sqlite db when polling).
        local art_status="not_declared"
        if [ -n "$BEHAVIOR_EXPECTED_ARTIFACT" ]; then
            local art_path="$BEHAVIOR_EXPECTED_ARTIFACT"
            case "$art_path" in
                /*) ;;
                *) if [ -n "$test_home_dir" ]; then art_path="$test_home_dir/project/$art_path"; else art_path=""; fi ;;
            esac
            if [ -n "$art_path" ] && [ -f "$art_path" ]; then
                if [ -n "$BEHAVIOR_EXPECTED_ARTIFACT_GREP" ] && ! grep -q "$BEHAVIOR_EXPECTED_ARTIFACT_GREP" "$art_path" 2>/dev/null; then
                    art_status="partial"
                else
                    art_status="present"
                fi
            elif [ -n "$art_path" ]; then
                art_status="absent"
            fi
        fi
        local out_tail=""; local err_tail=""
        out_tail=$(tail -c 200 "$output_file" 2>/dev/null | tr '\n' ' ' | tail -c 120)
        err_tail=$(tail -c 200 "$err_file" 2>/dev/null | tr '\n' ' ' | tail -c 120)
        echo "POLL ${poll}: ts=${ts} ev=${event_count} tools=${tool_parts} completed=${completed} running=${running} ident=${identical_max} artifact=${art_status} goal=${goal_json}" >> "$poll_log"
        echo "  text: ${last_text}" >> "$poll_log"
        echo "  reason-tail: ${last_reason}" >> "$poll_log"
        echo "  stdout-tail: ${out_tail}" >> "$poll_log"
        echo "  stderr-tail: ${err_tail}" >> "$poll_log"

        # ── .opencode#2456 SC-2: classification checkpoint — dispatch the
        # monitoring classification sub-agent per the §14 checkpoint policy
        # (bounded per-poll cost): fire on a poll where the event stream
        # changed since the last classification, after the minimum poll gap,
        # under the per-attempt ceiling. The judgment is produced in the
        # sub-agent's OWN context from message/reasoning/tool-call content
        # against the digest's verifiable goal_condition (SC-14 admissible
        # evidence — never shell counters; never the run prompt prose); the
        # value is recorded here and the off-track classification is ROUTED
        # to the orchestrator notification (SC-4 __notify_offtrack); the
        # halt-class halt+notify routing is SC-6's mechanism (later item).
        if [ "$classified_count" -lt "$BEHAVIOR_MONITOR_CLASSIFY_MAX" ] \
            && [ "$polls_since_classify" -ge "$BEHAVIOR_MONITOR_CLASSIFY_MIN_POLLS" ] \
            && [ "$event_count" -gt "$last_classified_event_count" ]; then
            local dispatch_raw
            dispatch_raw=$(__classify_run_state "$db" "${art_status:-not_declared}" "$model" "$scenario_name" "$attempt" "$poll")
            polls_since_classify=0
            last_classified_event_count=$event_count
            local dispatch_value="${dispatch_raw%%|*}"
            local dispatch_mode="${dispatch_raw#*|}"
            # R-13 amendment: the state decision is the pure function's —
            # parsed outcome = classification (+ routed halt-class state);
            # no-parseable outcome = DISPATCH FAILURE (attempt + mode recorded
            # below), unchanged classification, untouched halt state, retry.
            local dec
            dec=$(__interpret_classify_dispatch "${classification_value:-}" "${halt_class:-}" "$dispatch_failures" "$dispatch_value")
            IFS='|' read -r classification_value halt_class dispatch_failures harness_failure_halt <<< "$dec"
            if [ -n "$dispatch_value" ]; then
                classified_count=$((classified_count + 1))
                echo "CLASSIFY[poll ${poll}]: dispatch #${classified_count}/${BEHAVIOR_MONITOR_CLASSIFY_MAX} → ${classification_value} (classified in sub-agent context; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
                # .opencode#2456 SC-4: an off-track classification is routed to
                # the orchestrator notification — emitted on stderr AND
                # recorded in the poll log (R-2: never silent continuation).
                # .opencode#2456 SC-6: the halt mechanics (halt before any
                # further dispatch) are SC-6's mechanism — direction
                # deviation (off-track) and a parsed undetermined
                # classification are halt-class trigger states; the halt-class
                # state is carried by __interpret_classify_dispatch.
                if [ "$classification_value" = "off-track" ]; then
                    __notify_offtrack "$poll" "$classified_count" "${art_status:-not_declared}" "$poll_log" "$scenario_name" "$attempt"
                fi
            else
                echo "DISPATCH-FAILURE[poll ${poll}]: classification dispatch attempt ${dispatch_failures} failed — mode=${dispatch_mode} (R-13 amended: not a classification — no halt-class trigger, no undetermined-cycle ceiling increment; checkpoint policy retries; consecutive-failure ceiling ${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING}; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
            fi
            if [ "${harness_failure_halt:-0}" -eq 1 ]; then
                echo "HARNESS_FAILURE: monitored run '${scenario_name}' attempt ${attempt} monitoring halted after ${dispatch_failures} consecutive classification-dispatch failures (ceiling ${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING}). Infrastructure surface: classifier-dispatch model inference queue/provisioning (developer-level remediation surface — model availability/queue). The failures are recorded as DISPATCH-FAILURE events in poll log ${poll_log}; the monitored run process is left running for the orchestrator." >&2
                break
            fi
            # .opencode#2456 SC-6: halt-class halt+notify (R-3) — emit the
            # orchestrator notification on stderr and in the poll log, then
            # stop polling and dispatching. The run state is left as-is for
            # the orchestrator decision record (SC-7); the run process is NOT
            # killed and no further classification dispatch fires.
            if [ -n "${halt_class:-}" ]; then
                __notify_haltclass "$halt_class" "$poll" "$classified_count" "${art_status:-not_declared}" "$poll_log" "$scenario_name" "$attempt" "${dispatch_mode:-}"
                break
            fi
        else
            polls_since_classify=$((polls_since_classify + 1))
        fi

        # ── GREEN termination (.opencode#2441 R-3/R-4): expected artifact exists
        # on disk AND >=1 declared goal action present in the event stream.
        if [ "$art_status" = "present" ] && [ "$goal_json" != "[]" ]; then  # partial (exists, content pattern absent) does NOT fire GREEN
            echo "GREEN-SIGNAL: artifact present + goal actions hit ${goal_json} — early termination, evidence complete" >> "$poll_log"
            abort_reason="green_termination"
            break
        fi

        # ── HOPELESS termination (.opencode#2441 R-5/R-6): cited-evidence
        # judgment. Mechanical proxy when declared: N consecutive polls with
        # zero new completed tool calls AND expected artifact absent — the run
        # is making no observable progress toward its deliverable.
        if [ -n "$BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS" ] && [ "$new_tool_calls" -le 0 ] && [ "$poll" -gt 1 ]; then
            hopeless_polls=$((hopeless_polls + 1))
            if [ "$hopeless_polls" -ge "$BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS" ]; then
                echo "HOPELESS-SIGNAL: ${hopeless_polls} consecutive polls with zero new completed tool calls, artifact=${art_status} — cited evidence above (last text/reason/log tails); run cannot reach deliverable" >> "$poll_log"
                abort_reason="hopeless_no_progress"
                break
            fi
        else
            hopeless_polls=0
        fi

        # Signal 1: identical tool input >= threshold
        if [ "$identical_max" -ge "$BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD" ]; then
            echo "ABORT: signal 1 (identical tool input x${identical_max} >= ${BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD})" >> "$poll_log"
            abort_reason="identical_tool_input"
        fi
        # Signal 2 (refined per .opencode#2430): task() running AND zero event
        # growth across BEHAVIOR_STUCK_TASK_POLLS consecutive polls — a live
        # long-dispatch sub-agent streams deltas, so only a frozen DB while a
        # dispatch is pending counts as stuck.
        local event_growth=$((event_count - prev_event_count))
        if [ "$running" != "[]" ] && [ "$event_growth" -le 0 ]; then
            stuck_task_polls=$((stuck_task_polls + 1))
            if [ "$stuck_task_polls" -ge "$BEHAVIOR_STUCK_TASK_POLLS" ]; then
                echo "ABORT: signal 2 (task() running with zero event growth across ${stuck_task_polls} consecutive polls)" >> "$poll_log"
                abort_reason="stuck_task_dispatch"
            fi
        else
            stuck_task_polls=0
        fi
        # Signal 3: reasoning runaway — >max chars with <=1 new tool call
        if [ -z "${abort_reason:-}" ] && [ "$reasoning_total" -gt "$BEHAVIOR_MONITOR_MAX_REASONING" ] && [ "$new_tool_calls" -le 1 ]; then
            echo "ABORT: signal 3 (reasoning ${reasoning_total} chars > ${BEHAVIOR_MONITOR_MAX_REASONING} with ${new_tool_calls} new tool calls)" >> "$poll_log"
            abort_reason="reasoning_runaway"
        fi
        # Signal 4: semantically off-track — no NEW completed tool call
        # across 2+ consecutive polls while reasoning grows.
        if [ -z "${abort_reason:-}" ] && [ "$new_tool_calls" -le 0 ] && [ "$reasoning_total" -gt "$prev_reasoning_chars" ] && [ "$poll" -gt 1 ]; then
            offtrack_polls=$((offtrack_polls + 1))
            if [ "$offtrack_polls" -ge 2 ]; then
                echo "ABORT: signal 4 (no new completed tool call across ${offtrack_polls} consecutive polls while reasoning grows)" >> "$poll_log"
                abort_reason="semantic_offtrack"
            fi
        else
            offtrack_polls=0
        fi

        # Signal 5 (2432 R-18 fold-in): frozen reasoning tail — identical
        # reasoning tail hash with zero new tool calls across >=5 consecutive
        # polls is a deliberation loop; abort early with the loop tail cited.
        if [ -z "${abort_reason:-}" ] && [ -n "${reason_hash:-}" ] && [ "$new_tool_calls" -le 0 ]; then
            if [ "${reason_hash:-}" = "${prev_reason_hash:-}" ]; then
                frozen_reason_polls=$((frozen_reason_polls + 1))
                if [ "$frozen_reason_polls" -ge 5 ]; then
                    echo "ABORT: signal 5 (identical reasoning tail across ${frozen_reason_polls} consecutive polls with 0 new tool calls — deliberation loop; tail: ${last_reason})" >> "$poll_log"
                    abort_reason="reasoning_loop"
                fi
            else
                frozen_reason_polls=0
            fi
        else
            frozen_reason_polls=0
        fi
        prev_reason_hash="${reason_hash:-}"

        prev_tool_calls=$completed
        prev_event_count=$event_count
        prev_reasoning_chars=$reasoning_total

        # .opencode#2456 SC-5 (progressing-continues, R-2): the mechanical
        # stuck/off-track signals (1 identical-input, 2 stuck-task, 3
        # reasoning-runaway, 4 semantic-offtrack, 5 reasoning-loop) are
        # heuristics for detecting NON-progressing runs. When the SC-2
        # classifier has judged the run progressing-directionally, the
        # semantic classification is authoritative over these heuristics:
        # a progressing run continues regardless of duration (R-2), so a
        # mechanical signal that fires against a progressing run is a false
        # positive (e.g. signal 3's CUMULATIVE reasoning total crosses its
        # threshold during a momentary tool-call gap on a slow but steadily
        # writing run). Suppress the mechanical signal and log it — the
        # progressing run keeps polling. Flag-gated by the enclosing
        # BEHAVIOR_SEMANTIC_MONITOR=1 block (backward compat).
        if [ -n "${abort_reason:-}" ] && [ "${classification_value:-}" = "progressing-directionally" ]; then
            # .opencode#2456 SC-22 (R-21): suppression is valid ONLY on a
            # FRESH progressing verdict — re-classified at least every
            # BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW polls AND after
            # every new abort-signal event. A stale verdict must never
            # suppress: re-classify FIRST (immediate dispatch, exempt from
            # the checkpoint gap), then decide on the fresh verdict.
            # Flag-gated (BEHAVIOR_MONITOR_FRESHNESS_ENFORCE=1, default);
            # =0 restores the pre-SC-22 unconditional suppression.
            if [ "${BEHAVIOR_MONITOR_FRESHNESS_ENFORCE:-1}" = "1" ] \
                && [ "$polls_since_classify" -gt "${BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW:-3}" ] \
                && [ "$classified_count" -lt "$BEHAVIOR_MONITOR_CLASSIFY_MAX" ]; then
                echo "POLL ${poll}: ts=${ts} freshness-window re-classification before suppression decision (verdict ${polls_since_classify} polls old > window ${BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW:-3}; R-21, .opencode#2456 SC-22)" >> "$poll_log"
                local fw_dispatch_raw
                fw_dispatch_raw=$(__classify_run_state "$db" "${art_status:-not_declared}" "$model" "$scenario_name" "$attempt" "$poll")
                polls_since_classify=0
                last_classified_event_count=$event_count
                local fw_value="${fw_dispatch_raw%%|*}"
                local fw_mode="${fw_dispatch_raw#*|}"
                local fw_dec
                fw_dec=$(__interpret_classify_dispatch "${classification_value:-}" "${halt_class:-}" "$dispatch_failures" "$fw_value")
                IFS='|' read -r classification_value halt_class dispatch_failures harness_failure_halt <<< "$fw_dec"
                if [ -n "$fw_value" ]; then
                    classified_count=$((classified_count + 1))
                    echo "CLASSIFY[poll ${poll}]: dispatch #${classified_count}/${BEHAVIOR_MONITOR_CLASSIFY_MAX} → ${classification_value} (freshness-window re-classification before suppression; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
                else
                    echo "DISPATCH-FAILURE[poll ${poll}]: freshness re-classification dispatch attempt ${dispatch_failures} failed — mode=${fw_mode} (R-13 amended; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
                fi
                if [ "${harness_failure_halt:-0}" -eq 1 ]; then
                    echo "HARNESS_FAILURE: monitored run '${scenario_name}' attempt ${attempt} monitoring halted after ${dispatch_failures} consecutive classification-dispatch failures (ceiling ${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING}) in the SC-22 freshness gate. Infrastructure surface: classifier-dispatch model inference queue/provisioning. The failures are recorded as DISPATCH-FAILURE events in poll log ${poll_log}; the monitored run process is left running for the orchestrator." >&2
                    break
                fi
                if [ -n "${halt_class:-}" ]; then
                    __notify_haltclass "$halt_class" "$poll" "$classified_count" "${art_status:-not_declared}" "$poll_log" "$scenario_name" "$attempt" "${fw_mode:-}"
                    break
                fi
            fi
            if [ -n "${abort_reason:-}" ] && [ "${classification_value:-}" = "progressing-directionally" ]; then
                echo "POLL ${poll}: ts=${ts} mechanical signal ${abort_reason} suppressed — run classified progressing-directionally (R-2: progressing runs continue regardless of duration, .opencode#2456 SC-5; verdict fresh within window ${BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW:-3}, .opencode#2456 SC-22); continuing to poll" >> "$poll_log"
                abort_reason=""
            fi
        fi

        if [ -n "${abort_reason:-}" ]; then
            break
        fi
    done

    # .opencode#2456 R-13 amendment (2026-09-23): pure decision function for one
# .opencode#2456 R-13 amendment (2026-09-23): dispatch-failure ceiling exit
    # — monitoring was halted after BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING
    # consecutive unparseable dispatches. Checked BEFORE the halt-class exit:
    # this is an infrastructure halt (HARNESS_FAILURE class), not a
    # classification halt. The run process is left running (its natural
    # completion is awaited by behavior_run's post-monitor wait).
    if [ "${harness_failure_halt:-0}" -eq 1 ]; then
        echo "MONITOR-HALTED polls=${poll} halt_reason=dispatch_failure_ceiling consecutive_failures=${dispatch_failures} ceiling=${BEHAVIOR_MONITOR_DISPATCH_FAIL_CEILING} last_classification=${classification_value:-none} monitoring halted after consecutive dispatch failures (R-13 amended, .opencode#2456 HARNESS_FAILURE halt); run left running for the orchestrator" >> "$poll_log"
        exit 0
    fi

    # .opencode#2456 SC-6: halt-class exit — monitoring was halted on a
    # halt-class classification (R-3) BEFORE any further dispatch. The run
    # process is left running (its natural completion is awaited by
    # behavior_run's post-monitor wait) and its state is left for the
    # orchestrator decision record (SC-7). No kill, no session export here
    # (the natural-completion path in behavior_run produces the artifacts),
    # and NO MONITOR-COMPLETE line — the monitor did not complete; it halted.
    if [ -n "${halt_class:-}" ]; then
        echo "MONITOR-HALTED polls=${poll} halt_class=${halt_class} last_classification=${classification_value:-none} monitoring halted before any further dispatch (R-3, .opencode#2456 SC-6); run left running for the orchestrator decision record (SC-7)" >> "$poll_log"
        exit 0
    fi

    if [ -n "${abort_reason:-}" ]; then
        # §14 abort path: kill the run, export session.yaml per §10.5, record diagnosis.
        # .opencode#2432 SC-10 finding: run_pid is the `bash with-test-home`
        # wrapper — killing only the wrapper orphans the inner `opencode run`
        # grandchild, which inherits the flock fd and deadlocks the next
        # behavior_run with HARNESS_FAILURE lock contention. The run is
        # launched under setsid, so run_pid is a session/group leader: kill
        # the whole process group to take down wrapper + opencode children.
        kill -TERM -- "-$run_pid" 2>/dev/null || kill "$run_pid" 2>/dev/null || true
        sleep 2
        kill -KILL -- "-$run_pid" 2>/dev/null || kill -9 "$run_pid" 2>/dev/null || true
        echo "ABORTED run_pid=${run_pid} reason=${abort_reason} poll=${poll}" >> "$poll_log"

        local artifact_dir
        artifact_dir=$(__artifact_dir "$scenario_name" "${model:-monitor}")
        mkdir -p "$artifact_dir"
        __export_sqlite_to_yaml "$artifact_dir/session.yaml" "$output_file" "$err_file" || true
        cp "$poll_log" "$artifact_dir/monitor.log" 2>/dev/null || true
        # .opencode#2456 SC-2: the classification sub-agent's own session
        # export rides alongside session.yaml on the abort path too.
        cp "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}.yaml" "$artifact_dir/classifier-session.yaml" 2>/dev/null || true

        cat > "$artifact_dir/semantic-diagnosis.yaml" <<DIAGEOF
diagnosis: monitor-abort
abort_reason: ${abort_reason}
polls_executed: ${poll}
poll_log: ${poll_log}
session_db: ${db:-unknown}
session_yaml: ${artifact_dir}/session.yaml
mandate: tests-v2/AGENTS.md §14 (semantic continuous monitoring, #2427 scope G)
note: Run aborted mid-execution by the semantic monitor; session.yaml exported per §10.5; poll log records the per-poll event-stream evidence and the firing signal.
DIAGEOF

        echo "  [harness] SEMANTIC MONITOR ABORT: ${abort_reason} after ${poll} polls (diagnosis: ${artifact_dir}/semantic-diagnosis.yaml)" >&2
        exit 1
    fi

    # .opencode#2456 SC-2: dispatch guarantee — at least one classification
    # per monitored run before MONITOR-COMPLETE. When no checkpoint fired
    # (short run, stalled event stream), classify the final session state now.
    if [ "$classified_count" -eq 0 ]; then
        local final_db
        final_db=$(ls -t "$PARENT_REPO_DIR"/tmp/test-home-*/.local/share/opencode/opencode.db 2>/dev/null | head -1)
        if [ -n "$final_db" ] && [ -f "$final_db" ]; then
            local final_raw
            final_raw=$(__classify_run_state "$final_db" "${art_status:-not_declared}" "$model" "$scenario_name" "$attempt" "${poll:-0}")
            classified_count=1
            local final_value="${final_raw%%|*}"
            local final_mode="${final_raw#*|}"
            if [ -n "$final_value" ]; then
                classification_value="$final_value"
                echo "CLASSIFY[final]: guarantee dispatch → ${classification_value} (classified in sub-agent context; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
                # .opencode#2456 SC-4: the guarantee dispatch routes an
                # off-track final classification to the orchestrator
                # notification too (R-2: never silent continuation).
                if [ "$classification_value" = "off-track" ]; then
                    __notify_offtrack "final-guarantee" "$classified_count" "${art_status:-not_declared}" "$poll_log" "$scenario_name" "$attempt"
                fi
            else
                # R-13 amendment (2026-09-23): the guarantee dispatch's failure
                # is a DISPATCH FAILURE event — attempt + failure mode recorded
                # in the poll evidence, never silent — NOT an undetermined
                # classification. The monitored run has already finished, so no
                # further checkpoint retry is possible; the final classification
                # stays honestly unset (the last parsed value or none).
                echo "DISPATCH-FAILURE[final]: guarantee classification dispatch failed — mode=${final_mode} (R-13 amended: not a classification — final_classification remains ${classification_value:-none}; export: ${BEHAVIOR_LOG_DIR}/${scenario_name}/classifier-session-attempt${attempt}.yaml)" >> "$poll_log"
            fi
        else
            echo "CLASSIFY[final]: guarantee dispatch SKIPPED — no session DB found for the monitored run" >> "$poll_log"
        fi
    fi

    echo "MONITOR-COMPLETE polls=${poll} run finished without abort signal classifications=${classified_count} final_classification=${classification_value:-none}" >> "$poll_log"
    exit 0
    )
}

behavior_run() {
    local scenario_name="$1"
    local message="$2"
    local model="${3:-$DEFAULT_TEST_MODEL}"
    local workdir="${4:-}"
    local agent="${5:-}"
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    local submodule_remote_url=""
    if [ -f "$PARENT_REPO_DIR/.gitmodules" ]; then
        submodule_remote_url=$(git -C "$PARENT_REPO_DIR" config --get submodule..opencode.url 2>/dev/null || true)
    fi
    if [ -z "$submodule_remote_url" ]; then
        submodule_remote_url="https://github.com/michael-conrad/.opencode.git"
    fi
    submodule_remote_url=$(echo "$submodule_remote_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')

    local submodule_commit="${BEHAVIOR_SUBMODULE_COMMIT:-}"
    # Default to trunk tip (remote default branch). Only pin to a specific commit
    # when BEHAVIOR_SUBMODULE_COMMIT is explicitly set. Using local HEAD is wrong —
    # it may be a feature branch or uncommitted state not yet pushed to remote.
    if [ -z "$submodule_commit" ]; then
        submodule_commit=""  # let clone use remote default branch
    fi

    # SC-3 (.opencode#2434): pre-flight git-state gate — MUST fire before the
    # lock-file open and flock acquisition below and before any model dispatch.
    # Predicate (single definition, mirrors tests-v2/AGENTS.md §4): the submodule
    # working tree is clean (git status --porcelain empty) AND the effective
    # submodule commit — the BEHAVIOR_SUBMODULE_COMMIT pin when set, the local
    # HEAD otherwise (R-4: pin honored, never bypassed) — is contained in a
    # remote ref after a fresh git fetch (R-13: live state read at run time, no
    # cached SHAs). On failure: FATAL message naming the commit+push+fetch
    # remediation, return 1 before the lock file is opened. All behavioral
    # scripts inherit this gate via behavior_run() (R-11) — invocation unchanged.
    local __preflight_repo="$PARENT_REPO_DIR/.opencode"
    local __preflight_dirty=0
    if [ -n "$(git -C "$__preflight_repo" status --porcelain 2>/dev/null || true)" ]; then
        __preflight_dirty=1
    fi
    local __preflight_effective="$submodule_commit"
    if [ -z "$__preflight_effective" ]; then
        __preflight_effective=$(git -C "$__preflight_repo" rev-parse HEAD 2>/dev/null || true)
    fi
    local __preflight_contained=0
    if [ -n "$__preflight_effective" ] && git -C "$__preflight_repo" fetch -q origin 2>/dev/null; then
        if git -C "$__preflight_repo" branch -r --contains "$__preflight_effective" 2>/dev/null | grep -q .; then
            __preflight_contained=1
        fi
    fi
    if [ "$__preflight_dirty" -ne 0 ] || [ "$__preflight_contained" -ne 1 ]; then
        local __preflight_dirty_txt="yes"
        local __preflight_contained_txt="yes"
        if [ "$__preflight_dirty" -ne 0 ]; then
            __preflight_dirty_txt="NO (uncommitted/untracked changes present)"
        fi
        if [ "$__preflight_contained" -ne 1 ]; then
            __preflight_contained_txt="NO"
        fi
        echo "FATAL: pre-flight git-state gate failed for .opencode submodule (SC-3, .opencode#2434)" >&2
        echo "  submodule working tree clean: $__preflight_dirty_txt" >&2
        echo "  effective commit: ${__preflight_effective:-<unknown>}${submodule_commit:+ (pinned via BEHAVIOR_SUBMODULE_COMMIT)}" >&2
        echo "  contained in a remote ref after fresh git fetch: $__preflight_contained_txt" >&2
        echo "  Remediation: git commit the submodule working-tree changes, git push the effective commit to its remote branch, then re-run — a fresh git fetch verifies remote containment. Do not run behavioral tests against uncommitted or unpushed submodule state." >&2
        return 1
    fi

    local attempt=0
    local output_file="$log_dir/stdout.log"
    local err_file="$log_dir/stderr.log"

    LOCK_FILE="$PARENT_REPO_DIR/tmp/.behavior-run.lock"
    mkdir -p "$(dirname "$LOCK_FILE")"
    exec 200>"$LOCK_FILE"
    flock -x -w 30 200 || {
        echo "HARNESS_FAILURE: lock contention — another test is running (waited 30s)" >&2
        return 1
    }

    # SC4: Remote-strategy mutual exclusion — BEHAVIOR_NEEDS_REMOTE and
    # BEHAVIOR_SET_BARE_REMOTE are mutually exclusive remote strategies. Setting both
    # simultaneously would wire an ambiguous origin; reject the configuration before
    # either the GitBucket provisioning or bare-remote wiring block runs.
    if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ] && [ "${BEHAVIOR_SET_BARE_REMOTE:-0}" = "1" ]; then
        echo "HARNESS_FAILURE: mutual-exclusion violation — BEHAVIOR_NEEDS_REMOTE and BEHAVIOR_SET_BARE_REMOTE are mutually exclusive (both set)" >&2
        return 1
    fi

    # SC-8: Provision GitBucket if test needs remote API
    if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ]; then
        echo "  [harness] BEHAVIOR_NEEDS_REMOTE=1 — provisioning GitBucket..." >&2
        __ensure_gitbucket || {
            echo "HARNESS_FAILURE: GitBucket provisioning failed" >&2
            return 1
        }
    fi

    while [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        attempt=$((attempt + 1))
        echo "  [attempt $attempt/$BEHAVIOR_MAX_RETRIES]"

        # SC-34: In shared-home mode, reuse the persistent shared project so the
        # second (audit) test builds incrementally on the state created by the first
        # (spec-creation) test. The shared home lives at tmp/test-home-shared.
        local attempt_workdir
        local shared_project="$PARENT_REPO_DIR/tmp/test-home-shared/project"
        if [ "${BEHAVIOR_SHARED_HOME:-0}" = "1" ] && [ -d "$shared_project" ]; then
            attempt_workdir="$shared_project"
            echo "  [harness] reusing shared test home project $shared_project (incremental)" >&2
        else
            # Create a fresh workdir per attempt — with-test-home moves it into the test home.
            attempt_workdir=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
            git init -q "$attempt_workdir"
            git -C "$attempt_workdir" config user.email "test@test.dev"
            git -C "$attempt_workdir" config user.name "Test"
        fi

        # In shared-home reuse, the .opencode clone already exists — skip cloning.
        if [ ! -d "$attempt_workdir/.opencode/.git" ]; then
            git clone -q "$submodule_remote_url" "$attempt_workdir/.opencode" 2>/dev/null || {
                echo "FATAL: git clone failed for .opencode from $submodule_remote_url" >&2
                exit 1
            }
        fi

        # Pin to local submodule commit so test agent sees feature branch changes.
        # Mirrors the pattern in with-test-home --setup (lines 153-159).
        # BEHAVIOR_SUBMODULE_COMMIT override still works via the guard below.
        if [ -z "$submodule_commit" ]; then
            local local_submodule_commit
            local_submodule_commit=$(git -C "$PARENT_REPO_DIR/.opencode" rev-parse HEAD 2>/dev/null || true)
            if [ -n "$local_submodule_commit" ]; then
                submodule_commit="$local_submodule_commit"
            fi
        fi

        if [ -n "$submodule_commit" ]; then
            git -C "$attempt_workdir/.opencode" checkout -q "$submodule_commit" 2>/dev/null || {
                echo "FATAL: could not checkout submodule commit $submodule_commit" >&2
                exit 1
            }
        fi

        if [ ! -f "$attempt_workdir/.gitmodules" ] || ! grep -q '.opencode' "$attempt_workdir/.gitmodules" 2>/dev/null; then
            git -C "$attempt_workdir" submodule add -q "$submodule_remote_url" .opencode 2>/dev/null || true
        fi

        git -C "$attempt_workdir" add -A 2>/dev/null || true
        git -C "$attempt_workdir" commit -q --allow-empty -m "init" 2>/dev/null || true

        mkdir -p "$attempt_workdir/.issues"

        if [ "${BEHAVIOR_FIXTURE_ISSUES:-1}" = "1" ]; then
            FIXTURE_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-fixture-issues.sh"
            if [ -f "$FIXTURE_SETUP" ]; then
                source "$FIXTURE_SETUP"
                setup_fixture_issues "$attempt_workdir"
            fi
        fi

        STORY_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-story-fixtures.sh"
        if [ -f "$STORY_SETUP" ]; then
            source "$STORY_SETUP"
            setup_story_fixtures "$attempt_workdir"
        fi

        # Per-scenario fixture setup: source fixtures/setup/<scenario-name>.sh if it exists.
        # Test scripts create these files to set up repo state (branches, remotes, etc.)
        # before the model runs. The file is sourced with $attempt_workdir as the workdir.
        SCENARIO_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup/${scenario_name}.sh"
        if [ -f "$SCENARIO_SETUP" ]; then
            source "$SCENARIO_SETUP" "$attempt_workdir"
            echo "  [harness] per-scenario fixtures applied: ${scenario_name}.sh"
        fi

        # SC1: Multi-submodule fixture provisioning — opt-in via
        # BEHAVIOR_NEEDS_MULTI_SUBMODULES=1. Provisions test-submodule-1 and
        # test-submodule-2 as local git repos (from fixture templates under
        # behaviors/fixtures/submodules, falling back to an empty commit) inside
        # the attempt workdir so remote-sensitive tests have sibling submodules to
        # discover. Kept strictly inside the guard — the flag-off path provisions
        # only the single .opencode clone, preserving the default provisioning.
        if [ "${BEHAVIOR_NEEDS_MULTI_SUBMODULES:-0}" = "1" ]; then
            # SC-4: Provision test-submodule-1 and test-submodule-2 as REACHABLE remotes
            # referencing the real test repos. test-submodule-1
            # (git@github.com:michael-conrad/test-submodule-1.git, default branch `dev`,
            # has commits) is cloned so origin/dev is a genuine reachable ref; test-submodule-2
            # (git@github.com:michael-conrad/test-submodule-2.git, empty) is initialized and
            # wired to the real empty remote as origin. This lets the SC-1/SC-2/SC-3
            # reachability checks run `git merge-base --is-ancestor` against a genuine
            # reachable origin/$DEFAULT_BRANCH. Kept strictly inside the guard — the flag-off
            # path provisions only the single .opencode clone, preserving the default provisioning.
            local test_submodule_1_url="git@github.com:michael-conrad/test-submodule-1.git"
            local test_submodule_2_url="git@github.com:michael-conrad/test-submodule-2.git"
            local submodule_dir_1="$attempt_workdir/test-submodule-1"
            local submodule_dir_2="$attempt_workdir/test-submodule-2"
            # test-submodule-1: clone the real repo so origin/dev is a genuine reachable ref.
            git clone -q "$test_submodule_1_url" "$submodule_dir_1" 2>/dev/null || {
                git init -q "$submodule_dir_1" 2>/dev/null || true
                git -C "$submodule_dir_1" remote add origin "$test_submodule_1_url" 2>/dev/null || true
            }
            git -C "$submodule_dir_1" config user.email "test@test.dev" 2>/dev/null || true
            git -C "$submodule_dir_1" config user.name "Test" 2>/dev/null || true
            # test-submodule-2: init + wire the real empty remote as origin.
            git init -q "$submodule_dir_2" 2>/dev/null || true
            git -C "$submodule_dir_2" remote add origin "$test_submodule_2_url" 2>/dev/null || true
            git -C "$submodule_dir_2" config user.email "test@test.dev" 2>/dev/null || true
            git -C "$submodule_dir_2" config user.name "Test" 2>/dev/null || true
            echo "  [harness] multi-submodule fixtures provisioned as reachable remotes (test-submodule-1, test-submodule-2)" >&2
        fi

        if [ "${BEHAVIOR_SET_BARE_REMOTE:-0}" = "1" ]; then
            local bare_repo="$attempt_workdir/../origin.git"
            git init --bare "$bare_repo" 2>/dev/null || true
            git -C "$attempt_workdir" remote add origin "$bare_repo" 2>/dev/null || true
            echo "  [harness] bare remote set up at $bare_repo"
        fi

        if [ "${BEHAVIOR_SETUP_STALE_WORKTREE:-0}" = "1" ]; then
            (cd "$attempt_workdir" && ./.opencode/tools/local-issues create --number "$(basename "$attempt_workdir")#1" --title "stale-test" 2>/dev/null) || true
            rm -rf "$attempt_workdir/.issues"
            echo "  [harness] stale worktree state set up (issue created, .issues/ deleted)"
        fi

        # Wire GitBucket remote on the attempt workdir if GitBucket is provisioned
        if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ] && [ -n "${GITBUCKET_PORT:-}" ]; then
            local gb_port="${GITBUCKET_PORT}"
            local gb_token="${GB_TOKEN:-root}"
            # SC-2: guard the git-mutating target — abort if it resolves to the live repo.
            __assert_not_live_root "$attempt_workdir" || return 1
            git -C "$attempt_workdir" remote add origin "http://root:${gb_token}@localhost:${gb_port}/git/root/test-repo.git" 2>/dev/null || true
            git -C "$attempt_workdir" push -u origin main 2>/dev/null || true
            echo "  [harness] GitBucket remote wired on attempt workdir (port $gb_port)" >&2
        fi

        # Scope G (#2427): semantic continuous monitoring — opt-in via
        # BEHAVIOR_SEMANTIC_MONITOR=1. The opencode run is launched in background;
        # a poll loop reads the live session DB (newest tmp/test-home-*/) at
        # BEHAVIOR_MONITOR_INTERVAL seconds and evaluates the event stream against
        # the hard-abort signals in tests-v2/AGENTS.md §14. On signal: kill the
        # run, export session.yaml per §10.5, record the semantic diagnosis, and
        # break out of the retry loop (no blind re-run after an off-track abort).
        if [ "${BEHAVIOR_SEMANTIC_MONITOR:-0}" = "1" ]; then
            # setsid: run_pid becomes session/group leader so the §14 abort
            # path can kill the full wrapper+opencode process group (see the
            # abort-path comment in __semantic_monitor — wrapper-only kill
            # orphans the opencode grandchild and deadlocks the flock).
            TEST_WORKDIR="$attempt_workdir" \
            setsid bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" "${OPENCODE_CMD[@]}" run "$message" --model "$model" --log-level INFO --print-logs ${agent:+--agent "$agent"} \
                > "$output_file" 2> "$err_file" \
                &
            local run_pid=$!
            # Param 6 (.opencode#2456 SC-2): the run's model (Default-Model
            # Mandate R-20 — the classifier uses the same harness default, no
            # substitution). The classification direction anchor is the
            # scenario's mechanically verifiable goal condition
            # (BEHAVIOR_EXPECTED_ARTIFACT + BEHAVIOR_EXPECTED_ARTIFACT_GREP +
            # BEHAVIOR_GOAL_ACTIONS, resolved per poll as art_status) — folded
            # into the classifier digest; the run prompt is never passed as
            # the anchor (SC-2 amendment 2026-09-22, FALSE_PREMISE remediation).
            __semantic_monitor "$run_pid" "$scenario_name" "$attempt" "$output_file" "$err_file" "$model"
            local monitor_result=$?
            wait "$run_pid" 2>/dev/null || true
            if [ "$monitor_result" -eq 0 ]; then
                break
            fi
            # Monitor aborted the run (off-track/loop) — record and stop retrying:
            # a resumed/retried off-track run repeats the identical stall (§14).
            echo "  [harness] semantic monitor aborted attempt $attempt (off-track/loop state) — no blind retry" >&2
            break
        fi

        TEST_WORKDIR="$attempt_workdir" \
        bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" "${OPENCODE_CMD[@]}" run "$message" --model "$model" --log-level INFO --print-logs ${agent:+--agent "$agent"} \
            > "$output_file" 2> "$err_file" \
            || true

        local output
        output=$(cat "$output_file" 2>/dev/null || true)
        local word_count
        word_count=$(echo "$output" | wc -w | tr -d ' ')
        if [ -n "$output" ] && [ "${word_count:-0}" -gt 0 ]; then
            break
        fi

        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi

        if [ -z "$output" ] || [ "${word_count:-0}" -eq 0 ]; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (empty output)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi
    done

    local output
    output=$(cat "$output_file" 2>/dev/null || true)
    local word_count
    word_count=$(echo "$output" | wc -w | tr -d ' ')
    local exit_code=0
    if [ -z "$output" ] || [ "${word_count:-0}" -eq 0 ]; then
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)"
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)" >> "$output_file"
            exit_code=1
        else
            echo "HARNESS_FAILURE: behavior_run produced empty output after all retries"
            echo "  BEHAVIOR_MODEL=$model"
            echo "  stdout: empty, stderr word count: $(wc -w < "$err_file" 2>/dev/null || echo 0)"
            echo "HARNESS_FAILURE: empty output" >> "$output_file"
            exit_code=1
        fi
    elif [ "${word_count:-0}" -le 3 ]; then
        echo "  NOTE: behavior_run produced short output (${word_count} words)."
        echo "  BEHAVIOR_MODEL=$model"
    fi

    sleep 1

    BEHAVIOR_STDOUT="$log_dir/stdout.log"
    BEHAVIOR_STDERR="$log_dir/stderr.log"
    export BEHAVIOR_DISPATCH_FAILED="${BEHAVIOR_DISPATCH_FAILED:-0}"

    local artifact_dir
    artifact_dir=$(__artifact_dir "$scenario_name" "$model")
    mkdir -p "$artifact_dir"

    cp "$output_file" "$artifact_dir/stdout.log" 2>/dev/null || true
    cp "$err_file" "$artifact_dir/stderr.log" 2>/dev/null || true

    echo "$exit_code" > "$artifact_dir/exit_code"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    local phase="${BEHAVIOR_PHASE:-GREEN}"
    cat > "$artifact_dir/manifest.yaml" <<MANIFESTEOF
scenario_name: ${scenario_name}
phase: ${phase}
model: ${model}
timestamp: ${timestamp}
exit_code: ${exit_code}
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

    __export_sqlite_to_yaml "$artifact_dir/session.yaml" "$output_file" "$err_file"

    # .opencode#2456 SC-23 (R-22): post-run session-isolation assertion — the
    # fresh-session isolation predicate is enforced mechanically on EVERY
    # monitored run's session export (the §2 PRIMARY evaluation source):
    # exactly one session id, zero prior-session messages / foreign task
    # instructions in the run's context. A violation means the run reused a
    # prior attempt's test home/session DB — the run's evidence is not
    # self-contained. Flag-gated (BEHAVIOR_SESSION_ISOLATION_ENFORCE=1,
    # default): =0 restores pre-SC-23 behavior (no check, no verdict file).
    if [ "${BEHAVIOR_SESSION_ISOLATION_ENFORCE:-1}" = "1" ] && [ -s "$artifact_dir/session.yaml" ]; then
        __assert_session_isolation "$artifact_dir/session.yaml" "$artifact_dir/session-isolation.yaml" || {
            echo "HARNESS_FAILURE: session-isolation violation in monitored run '${scenario_name}' (attempt ${attempt}) — the run's session export carries prior-session content (reused test home/session DB prohibited per R-22); verdict: $artifact_dir/session-isolation.yaml" >&2
            return 1
        }
    fi

    # .opencode#2456 SC-1: poll-evidence persistence — the §14 semantic
    # monitor's poll log is persisted to the scenario evidence directory
    # (alongside session.yaml) for EVERY monitored run, natural completion
    # AND abort paths alike (both flow through this post-run block). The
    # monitor's internal abort-path copy lands in a pre-walk sibling dir;
    # this copy into the final artifact_dir is the authoritative
    # alongside-session.yaml location. Flag-gated: BEHAVIOR_SEMANTIC_MONITOR
    # unset → no change (backward compat).
    if [ "${BEHAVIOR_SEMANTIC_MONITOR:-0}" = "1" ]; then
        cp "$BEHAVIOR_LOG_DIR/$scenario_name/monitor-attempt${attempt}.log" "$artifact_dir/monitor.log" 2>/dev/null || true
        # .opencode#2456 SC-2: the classification sub-agent's own session
        # export — persisted during polling to the staging path (a
        # monitor-internal natural-path mkdir would collide with this block's
        # __artifact_dir suffix walk, same reason as monitor.log above); the
        # authoritative alongside-session.yaml copy lands here. The last
        # classification of the attempt wins (final classified state).
        cp "$BEHAVIOR_LOG_DIR/$scenario_name/classifier-session-attempt${attempt}.yaml" "$artifact_dir/classifier-session.yaml" 2>/dev/null || true
        # .opencode#2456 SC-3: durable determination record — written for
        # EVERY monitored run (natural completion AND abort paths both flow
        # through this post-run block), carrying the final classification
        # (SC-2 taxonomy value), poll-evidence references (monitor.log path
        # + poll count), and run provenance (model, exit code). Append-only
        # schema (R-8): false_signal annotations (SC-10) and orchestrator
        # decisions (SC-7) append to the record's list sections in later
        # phases. Flag-gated by the enclosing BEHAVIOR_SEMANTIC_MONITOR
        # block — unset → no record, no change (backward compat).
        __write_determination_record "$artifact_dir" \
            "$BEHAVIOR_LOG_DIR/$scenario_name/monitor-attempt${attempt}.log" \
            "$model" "$exit_code" "$scenario_name" "$attempt"
        # .opencode#2456 SC-9: undetermined-cycle counter — increments only
        # on undetermined determinations (self-checked); the ceiling gate
        # produces the persistent CEILING_REACHED mechanical block. The gate
        # is checked BEFORE the next retry dispatch: with the budget spent,
        # no further undetermined retry is attempted. The block/state file
        # persists until developer-level remediation.
        __count_undetermined_cycle "$artifact_dir" || true
        __undetermined_ceiling_check "$artifact_dir" || {
            return 1
        }
        # .opencode#2456 SC-7: orchestrator decision-record write path. After
        # the halt-class notification (SC-6) the orchestrator decision point
        # occurred; the entry mechanism records the decision the run's
        # verified outcome supports — the left-running run completing
        # naturally records continue-new-dispatch; a failed run records
        # terminate-with-root-cause with the run-outcome root cause. The
        # value-set is validated by __record_orchestrator_decision, and the
        # appended entry is what the SC-8 gate reads. The decision happens
        # OUTSIDE the monitored run — this is the harness's entry mechanism,
        # exercised after the halt-class path.
        local sc7_poll_log="$BEHAVIOR_LOG_DIR/$scenario_name/monitor-attempt${attempt}.log"
        if grep -q "MONITOR-HALTED" "$sc7_poll_log" 2>/dev/null; then
            if [ "$exit_code" = "0" ]; then
                __record_orchestrator_decision "$artifact_dir" --decision continue-new-dispatch || true
            else
                __record_orchestrator_decision "$artifact_dir" --decision terminate-with-root-cause --root-cause "run exit_code=${exit_code} after the halt-class notification (monitor halted per SC-6); outcome evidence in stdout.log/stderr.log of $artifact_dir" || true
            fi
        fi
    fi

    local timeline_tool="$PARENT_REPO_DIR/.opencode/tools/session-to-timeline"
    if [ -f "$timeline_tool" ] && [ -f "$artifact_dir/session.yaml" ]; then
        uv run "$timeline_tool" "$artifact_dir/session.yaml" "$artifact_dir/timeline.yaml" 2>/dev/null || true
    fi

    BEHAVIOR_ARTIFACT_DIR="$artifact_dir"
    export BEHAVIOR_ARTIFACT_DIR
}

behavior_get_stdout() {
    cat "$BEHAVIOR_STDOUT"
}

behavior_get_stderr() {
    cat "$BEHAVIOR_STDERR"
}

__init_model_pool() {
    if [ ${#BEHAVIORAL_MODEL_POOL[@]} -gt 0 ]; then
        return
    fi
    local models
    models=$("${OPENCODE_CMD[@]}" models 2>/dev/null | grep '^ollama/.*:cloud' | shuf | head -2 || true)
    mapfile -t BEHAVIORAL_MODEL_POOL <<< "$models"
    if [ ${#BEHAVIORAL_MODEL_POOL[@]} -eq 0 ]; then
        echo "WARNING: no cloud models found via 'opencode models' — BEHAVIORAL_MODEL_POOL empty" >&2
    fi
}

behavior_run_pool() {
    __init_model_pool
    local scenario_name="$1"
    local message="$2"

    declare -gA BEHAVIOR_POOL_OUTPUTS
    declare -gA BEHAVIOR_POOL_STDERRS
    local any_success=0

    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local safe_model_name
        safe_model_name=$(echo "$model" | tr '/:' '_')
        local model_scenario="${scenario_name}_${safe_model_name}"

        local display_name="${model#ollama/}"
        echo "  === Testing with model: $display_name ==="
        behavior_run "$model_scenario" "$message" "$model" "$PARENT_REPO_DIR"

        BEHAVIOR_POOL_OUTPUTS["$model"]="$BEHAVIOR_STDOUT"
        BEHAVIOR_POOL_STDERRS["$model"]="$BEHAVIOR_STDERR"

        if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "0" ]; then
            any_success=1
        fi
    done

    export BEHAVIOR_POOL_OUTPUTS BEHAVIOR_POOL_STDERRS
    return $((1 - any_success))
}

# .opencode#2456 SC-16: __assert_commit_ordering — pure decision function per
# the scenario-header contract (2456-sc16-commit-ordering-red.sh). Reads a
# session-export JSON (the __export_sqlite_to_yaml format), asserts the §4
# ordering predicate: the agent's git commit + push tool calls precede the
# with-test-home run invocation. Commit-deliberation turns (reasoning/text
# parts between the first test-needed change and the first run) and
# --no-verify commit/push usage are violations. Writes a verdict YAML and
# exits 0 (PASS) or non-zero (FAIL). Consumable by future GREEN-phase
# enforcement. No model dispatch — pure mechanical parsing.
__assert_commit_ordering() {
    # helpers.sh sources with `set -euo pipefail`; this function's contract is
    # a non-zero exit on violation, and the calling scenario captures the exit
    # status via `ev_rc=$?` in an untested context — under errexit that would
    # kill the caller before the capture. Disable errexit for the remainder of
    # the caller's script so the verdict exit code reaches the caller's
    # capture (the scenario's own logic uses explicit if-checks, not errexit).
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'PYEOF'
import json, re, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

DELIB_MARKERS = [
    r"should i commit",
    r"whether to commit",
    r"whether to push",
    r"commit or not",
    r"do i need to commit",
    r"do i need to push",
    r"commit now or",
    r"push now or",
    r"authorization to commit",
    r"authorization to push",
    r"ask .* authorization .*(commit|push)",
    r"wait .* before (commit|push)",
]
DELIB_RE = re.compile("|".join(DELIB_MARKERS), re.I)

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

violations = []
delib_turns = []
prohibited_flags = []
seqs = {"change": None, "commit": None, "push": None, "run": None, "fetch": None}

if rows is None:
    violations.append("unparseable session export (no event rows) — evaluation surface absent")
else:
    def cmd_of(part):
        st = part.get("state") or {}
        inp = st.get("input") or {}
        return inp.get("command") or ""

    events = []
    for row in rows:
        seq = row.get("seq", 0)
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        part = data.get("part") or {}
        ptype = part.get("type")
        if ptype == "tool":
            tool = part.get("tool")
            if tool == "bash":
                events.append((seq, "bash", cmd_of(part)))
            elif tool in ("write", "edit"):
                events.append((seq, "change", part.get("filePath") or ""))
        elif ptype in ("text", "reasoning"):
            events.append((seq, ptype, part.get("text") or ""))

    events.sort(key=lambda e: e[0])
    for seq, kind, payload in events:
        if kind == "change" and seqs["change"] is None:
            seqs["change"] = seq
        elif kind == "bash":
            low = payload.lower()
            if "--no-verify" in low and ("git commit" in low or "git push" in low):
                prohibited_flags.append((seq, payload))
            if seqs["commit"] is None and re.search(r"git(-.+)?\s+commit\b|git add .*&&\s*git commit", low):
                seqs["commit"] = seq
            if seqs["push"] is None and re.search(r"git(-.+)?\s+push\b", low):
                seqs["push"] = seq
            if seqs["run"] is None and "with-test-home" in low and "opencode run" in low:
                seqs["run"] = seq
            if seqs["fetch"] is None and re.search(r"git(-.+)?\s+fetch\b", low):
                seqs["fetch"] = seq

    first_change = seqs["change"]
    first_run = seqs["run"]
    if first_change is not None and first_run is not None:
        for seq, kind, payload in events:
            if kind in ("text", "reasoning") and first_change < seq < first_run:
                m = DELIB_RE.search(payload)
                if m:
                    delib_turns.append((seq, m.group(0)))
                    violations.append(
                        "deliberation turn at seq %s — matched marker '%s' "
                        "(commit deliberation between the change and the run is prohibited)" % (seq, m.group(0)))
    if first_run is not None:
        if seqs["commit"] is None or seqs["commit"] > first_run:
            violations.append(
                "first git commit (seq %s) does not precede the with-test-home run (seq %s)"
                % (seqs["commit"], first_run))
        if seqs["push"] is None or seqs["push"] > first_run:
            violations.append(
                "first git push (seq %s) does not precede the with-test-home run (seq %s)"
                % (seqs["push"], first_run))
    for seq, cmd in prohibited_flags:
        violations.append(
            "prohibited --no-verify flag at seq %s (command: %s) — commit/push --no-verify is never permitted"
            % (seq, cmd))

verdict = "PASS" if not violations else "FAIL"

def fmt_pairs(pairs, label):
    if not pairs:
        return "%s: []" % label
    return "%s:\n" % label + "".join(
        "  - seq: %s\n    %s\n" % (s, label.rstrip("s")) + (
            "      matched_marker: '%s'\n" % v if label == "deliberation_turns"
            else "      command: '%s'\n" % v) for s, v in pairs)

with open(verdict_out, "w") as f:
    f.write("ordering_assertion: commit_push_before_run\n")
    f.write("verdict: %s\n" % verdict)
    for label in ("first_change_seq", "first_commit_seq", "first_push_seq",
                  "first_run_seq", "first_fetch_seq"):
        key = label.split("_")[1]
        f.write("%s: %s\n" % (label, seqs[key] if seqs[key] is not None else "none"))
    f.write(fmt_pairs(delib_turns, "deliberation_turns"))
    f.write(fmt_pairs(prohibited_flags, "prohibited_flags"))
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)
    else:
        f.write("violations: []\n")

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

# .opencode#2456 SC-17: __assert_supervision_cadence — pure decision function
# per the scenario-header contract (2456-sc17-supervision-cadence-red.sh).
# Reads a session-export JSON (the __export_sqlite_to_yaml format) as the
# ordered event stream of a SUPERVISING session and asserts the
# supervision-cadence predicate:
#   1. consecutive supervision gaps ≤ 300s (poll at most every 5 minutes)
#   2. each gap closed by a semantic-check action (a read of the run's
#      session DB / session export content parts — read tool calls targeting
#      session.yaml / session-DB paths, or bash calls invoking the export
#      procedure on the run's DB)
#   3. run-retry invocations always separated by an intervening semantic check
# Supervision actions: with-test-home run invocations (bash tool calls whose
# command contains `with-test-home` and `opencode run`) and semantic-check
# actions, each stamped with the part's start epoch. Writes a verdict YAML
# with verdict: PASS|FAIL and violations[] and exits 0 (PASS) or 1 (FAIL).
# Durable pure function — no model dispatch.
__assert_supervision_cadence() {
    # helpers.sh sources with `set -euo pipefail`; the calling scenario
    # captures this function's exit status via `ev_rc=$?` — under errexit a
    # non-zero verdict exit would kill the caller before the capture.
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'PYEOF'
import json, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

GAP_LIMIT_MS = 300000  # consecutive supervision gaps <= 300s

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

violations = []
runs = []       # (ts_ms, seq)
checks = []     # (ts_ms, seq)

if rows is None:
    violations.append("unparseable session export (no event rows) — evaluation surface absent")
else:
    events = []
    for row in rows:
        seq = row.get("seq", 0)
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        part = data.get("part") or {}
        if part.get("type") != "tool":
            continue
        tool = part.get("tool")
        st = part.get("state") or {}
        inp = st.get("input") or {}
        ts = None
        t = st.get("time") or {}
        if isinstance(t.get("start"), (int, float)):
            ts = t["start"]
        elif isinstance(row.get("createdAt"), (int, float)):
            ts = row["createdAt"]
        if ts is None:
            continue
        if tool == "bash":
            cmd = (inp.get("command") or "").lower()
            if "with-test-home" in cmd and "opencode run" in cmd:
                events.append((ts, seq, "run", inp.get("command") or ""))
            elif (
                "--export-session" in cmd
                or "opencode.db" in cmd
                or "sqlite3" in cmd
                or "session.yaml" in cmd
            ):
                events.append((ts, seq, "check", inp.get("command") or ""))
        elif tool == "read":
            path = (inp.get("filePath") or inp.get("path") or "").lower()
            if (
                "session.yaml" in path
                or "opencode.db" in path
                or "session.db" in path
                or ".db" in path and "session" in path
            ):
                events.append((ts, seq, "check", inp.get("filePath") or ""))

    events.sort(key=lambda e: (e[0], e[1]))
    for ts, seq, kind, detail in events:
        if kind == "run":
            runs.append((ts, seq))
        else:
            checks.append((ts, seq))

    ordered = events
    max_gap = 0
    # Predicate 1: consecutive supervision gaps <= 300s
    for i in range(1, len(ordered)):
        gap = ordered[i][0] - ordered[i - 1][0]
        if gap > max_gap:
            max_gap = gap
        if gap > GAP_LIMIT_MS:
            violations.append(
                "max_gap violation: %ss gap between supervision actions at seq %s and seq %s "
                "(>300s poll cadence breach)" % (gap // 1000, ordered[i - 1][1], ordered[i][1]))

    # Predicate 2: every gap closed by a semantic-check action — a run must be
    # followed (before the next run or end-of-stream) by a semantic check.
    for i, (ts, seq) in enumerate(runs):
        next_run_ts = runs[i + 1][0] if i + 1 < len(runs) else None
        close_ts = next_run_ts if next_run_ts is not None else None
        closed = any(
            cts > ts and (close_ts is None or cts <= close_ts)
            for cts, _ in checks
        )
        if not closed:
            if next_run_ts is not None:
                violations.append(
                    "unchecked retry: run-retry invocation at seq %s with no semantic check "
                    "since the previous run (retry-without-check violation)" % seq)
            else:
                violations.append(
                    "missing semantic check: run at seq %s closed by no session-DB/export read "
                    "(trailing supervision gap without a semantic check)" % seq)

verdict = "PASS" if not violations else "FAIL"

with open(verdict_out, "w") as f:
    f.write("supervision_cadence: poll_gap_semantic_check_retry\n")
    f.write("verdict: %s\n" % verdict)
    f.write("runs: %d\n" % len(runs))
    f.write("semantic_checks: %d\n" % len(checks))
    f.write("max_gap_s: %d\n" % (max_gap // 1000 if max_gap else 0))
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)
    else:
        f.write("violations: []\n")

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

# .opencode#2456 SC-19: __assert_launch_form — pure decision function per the
# scenario-header contract (2456-sc19-async-launch-form-red.sh). Reads a
# session-export JSON (the __export_sqlite_to_yaml format) as the ordered
# event stream of a SUPERVISING session and asserts the launch-form predicate:
#   1. every opencode run invocation (bash tool call whose command contains
#      `with-test-home` and `opencode run`) is launched ASYNCHRONOUSLY —
#      backgrounded with &, setsid, nohup, or disown (a bare blocking
#      foreground invocation fails)
#   2. the launch carries an attached supervision schedule: a semantic check
#      of the run's SQLite session DB (read tool calls targeting
#      session.yaml / session-DB paths, or bash calls invoking the export
#      procedure / reading opencode.db on the run's test home) within <=300s
#      of the launch
# Writes a verdict YAML (launch_form / verdict / violations[]) and exits 0 on
# PASS, 1 on FAIL. Durable, no model dispatch.
__assert_launch_form() {
    # helpers.sh sources with `set -euo pipefail`; the calling scenario
    # captures this function's exit status via `ev_rc=$?` — under errexit a
    # non-zero verdict exit would kill the caller before the capture.
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'PYEOF'
import json, re, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

SCHEDULE_WINDOW_MS = 300000  # semantic check within <=300s of the launch
ASYNC_RE = re.compile(
    r"(^|\s|;|&&)(setsid|nohup|disown)\b|(\s|;|&&|^)&(\s|$)|\bdisown\b",
    re.I)

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

violations = []
launches = []  # (ts_ms, seq, cmd, async)
checks = []    # (ts_ms, seq, detail)

if rows is None:
    violations.append("unparseable session export (no event rows) — evaluation surface absent")
else:
    for row in rows:
        seq = row.get("seq", 0)
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        part = data.get("part") or {}
        if part.get("type") != "tool":
            continue
        tool = part.get("tool")
        st = part.get("state") or {}
        inp = st.get("input") or {}
        t = st.get("time") or {}
        ts = t.get("start") if isinstance(t.get("start"), (int, float)) else row.get("createdAt")
        if not isinstance(ts, (int, float)):
            continue
        if tool == "bash":
            cmd = inp.get("command") or ""
            low = cmd.lower()
            if "with-test-home" in low and "opencode run" in low:
                # classify launch form: ASYNC when backgrounded/detached
                # (setsid/nohup/&/disown); BLOCKING when a bare foreground
                # invocation with no backgrounding marker
                is_async = bool(ASYNC_RE.search(cmd))
                launches.append((ts, seq, cmd, is_async))
            elif (
                "--export-session" in low
                or "opencode.db" in low
                or "sqlite3" in low
                or "session.yaml" in low
            ):
                checks.append((ts, seq, cmd))
        elif tool == "read":
            path = (inp.get("filePath") or inp.get("path") or "").lower()
            if (
                "session.yaml" in path
                or "opencode.db" in path
                or "session.db" in path
                or (".db" in path and "session" in path)
            ):
                checks.append((ts, seq, path))

launches.sort(key=lambda e: (e[0], e[1]))
checks.sort(key=lambda e: (e[0], e[1]))

blocking = []
for ts, seq, cmd, is_async in launches:
    if not is_async:
        blocking.append((seq, cmd))
        violations.append(
            "blocking launch at seq %s — opencode run invoked in a bare "
            "foreground command line with no backgrounding/detach marker "
            "(setsid/nohup/&/disown); blocking foreground invocation violates "
            "the async-launch-form predicate" % seq)

for ts, seq, cmd, is_async in launches:
    scheduled = any(
        cts >= ts and cts - ts <= SCHEDULE_WINDOW_MS
        for cts, _, _ in checks)
    if not scheduled:
        violations.append(
            "missing schedule at seq %s — no SQLite-DB semantic-poll action "
            "(session-export read / export-procedure invocation / session-DB "
            "read) within 300s of the launch; the launch carries no attached "
            "supervision schedule" % seq)

verdict = "PASS" if not violations else "FAIL"

with open(verdict_out, "w") as f:
    f.write("launch_form: async_with_sqlite_poll_schedule\n")
    f.write("verdict: %s\n" % verdict)
    f.write("launches: %d\n" % len(launches))
    f.write("semantic_checks: %d\n" % len(checks))
    f.write("async_launches: %d\n" % sum(1 for _, _, _, a in launches if a))
    if blocking:
        f.write("blocking_launches:\n")
        for seq, cmd in blocking:
            f.write("  - seq: %s\n    command: '%s'\n" % (seq, cmd))
    else:
        f.write("blocking_launches: []\n")
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)
    else:
        f.write("violations: []\n")

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

# .opencode#2456 SC-20: __assert_efficiency_marker — pure decision function
# per the scenario-header contract (2456-sc20-efficiency-marker-red.sh).
# Reads a session-export JSON (the __export_sqlite_to_yaml format) as the
# ordered event stream of a SUPERVISED run within a poll window and asserts
# the efficiency predicate (deliberation-to-progress ratio, NOT wall-clock):
#   1. deliberation-loop: large reasoning growth with no corresponding
#      completed tool-call progress ⇒ DEFECT marker recorded + routed to the
#      defect notification path (ORCHESTRATOR_DECISION_REQUIRED)
#   2. latency-dominated-progressing: slow wall-clock but growing completed
#      tool calls ⇒ NO marker (raw model latency is not a defect)
#   3. self-correction-loop: repeated identical tool inputs ⇒ DEFECT marker
# Writes a verdict YAML (efficiency_marker / verdict / notification /
# ORCHESTRATOR_DECISION_REQUIRED routing / violations[] / markers[]) and
# exits 0 (PASS, no marker) or 1 (FAIL, defect marker recorded). Durable
# pure function — no model dispatch.
__assert_efficiency_marker() {
    # helpers.sh sources with `set -euo pipefail`; the calling scenario
    # captures this function's exit status via `ev_rc=$?` — under errexit a
    # non-zero verdict exit would kill the caller before the capture.
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'PYEOF'
import json, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

# Deliberation-to-progress ratio thresholds (per-poll window semantics).
DELIB_WINDOW_MS = 120000          # poll window: 2 minutes
MIN_REASONING_PER_WINDOW = 4000  # chars of reasoning growth per window
REPEAT_INPUT_THRESHOLD = 2       # identical tool inputs >= 2 repeats = loop

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

violations = []
markers = []

if rows is None:
    violations.append("unparseable session export (no event rows) — evaluation surface absent")
else:
    reasoning = []  # (ts_ms, seq, char_count)
    tools = []      # (ts_ms, seq, tool, input_key)

    for row in rows:
        seq = row.get("seq", 0)
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        part = data.get("part") or {}
        ptype = part.get("type")
        if ptype == "reasoning":
            text = part.get("text") or ""
            ts = row.get("createdAt")
            if isinstance(ts, (int, float)):
                reasoning.append((ts, seq, len(text)))
        elif ptype == "tool":
            st = part.get("state") or {}
            if (st.get("status") or "") != "completed":
                continue
            inp = st.get("input") or {}
            t = st.get("time") or {}
            ts = t.get("start") if isinstance(t.get("start"), (int, float)) else row.get("createdAt")
            if not isinstance(ts, (int, float)):
                continue
            try:
                input_key = json.dumps(inp, sort_keys=True)
            except Exception:
                input_key = str(inp)
            tools.append((ts, seq, part.get("tool"), input_key))

    reasoning.sort(key=lambda e: (e[0], e[1]))
    tools.sort(key=lambda e: (e[0], e[1]))

    # Predicate 1: deliberation-loop — large reasoning growth per poll window
    # with no corresponding completed tool-call progress. Windows are sliced
    # at DELIB_WINDOW_MS boundaries; a window whose reasoning growth exceeds
    # MIN_REASONING_PER_WINDOW and yields zero completed tool calls is a
    # deliberation-loop window.
    if reasoning:
        start_ts = reasoning[0][0]
        end_ts = reasoning[-1][0]
        if tools:
            end_ts = max(end_ts, tools[-1][0])
            start_ts = min(start_ts, tools[0][0])
        windows = []
        ws = start_ts
        while ws <= end_ts:
            windows.append((ws, ws + DELIB_WINDOW_MS))
            ws += DELIB_WINDOW_MS
        for w_start, w_end in windows:
            r_growth = sum(c for ts, _, c in reasoning if w_start <= ts < w_end)
            t_count = sum(1 for ts, _, _, _ in tools if w_start <= ts < w_end)
            if r_growth > MIN_REASONING_PER_WINDOW and t_count == 0:
                violations.append(
                    "deliberation-loop in poll window [%ss..%ss): %d reasoning chars "
                    "with %d completed tool calls — large reasoning growth without "
                    "corresponding tool-call progress (excessive deliberation)"
                    % (w_start // 1000, w_end // 1000, r_growth, t_count))
                markers.append(
                    {"type": "deliberation_loop",
                     "window_start_s": w_start // 1000,
                     "window_end_s": w_end // 1000,
                     "reasoning_chars": r_growth,
                     "completed_tool_calls": t_count})

    # Predicate 3: self-correction-loop — repeated identical tool inputs.
    seen = {}
    for ts, seq, tool, input_key in tools:
        seen.setdefault((tool, input_key), []).append((ts, seq))
    for (tool, input_key), occurrences in sorted(seen.items()):
        if len(occurrences) >= REPEAT_INPUT_THRESHOLD:
            violations.append(
                "self-correction-loop: tool '%s' invoked %d times with identical "
                "input (first at seq %s, repeat at seq %s) — repeated identical "
                "tool inputs indicate a self-correction loop"
                % (tool, len(occurrences), occurrences[0][1], occurrences[-1][1]))
            markers.append(
                {"type": "self_correction_loop",
                 "tool": tool,
                 "repeats": len(occurrences),
                 "first_seq": occurrences[0][1],
                 "last_seq": occurrences[-1][1]})

verdict = "FAIL" if violations else "PASS"
notify = "ORCHESTRATOR_DECISION_REQUIRED" if violations else "none"

with open(verdict_out, "w") as f:
    f.write("efficiency_marker: deliberation_to_progress\n")
    f.write("verdict: %s\n" % verdict)
    f.write("notification: %s\n" % notify)
    if violations:
        f.write("ORCHESTRATOR_DECISION_REQUIRED: efficiency-defect — excessive "
                "deliberation (deliberation-to-progress ratio breach) recorded as "
                "a defect marker and routed to the defect notification path\n")
    f.write("reasoning_parts: %d\n" % len(reasoning))
    f.write("completed_tool_calls: %d\n" % len(tools))
    # FAIL verdicts carry markers[] + violations[]; a clean (PASS) verdict
    # omits the defect-marker keys entirely — no defect-marker record matches
    # the defect-marker patterns on the latency discrimination side.
    if markers:
        f.write("markers:\n")
        for m in markers:
            f.write("  - type: %s\n" % m["type"])
            for k, v in m.items():
                if k != "type":
                    f.write("    %s: %s\n" % (k, v))
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

__assert_defect_marker_gate() {
    # helpers.sh sources with `set -euo pipefail`; the calling scenario
    # captures this function's exit status via `ev_rc=$?` — under errexit a
    # non-zero verdict exit would kill the caller before the capture.
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'PYEOF'
import json, re, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

# Defect-marker record actions: tool calls whose input carries a defect
# marker write — determination/marker/classification writes carrying a
# defect classification (efficiency/deliberation or any non-progressing
# classification with an identified cause).
MARKER_TOOL = re.compile(
    r"__record_defect_marker|defect[-_ ]?marker", re.I)
MARKER_CLASSIFICATION = re.compile(
    r"(efficiency|deliberation|off[-_ ]?track|non[-_ ]?progressing|"
    r"self[-_ ]?correction)", re.I)
CAUSE_IDENTIFIED = re.compile(
    r"cause|identified|traced|root[-_ ]?cause", re.I)
NOTIFY_PATH = re.compile(r"ORCHESTRATOR_DECISION_REQUIRED", re.I)
ORCHESTRATOR_RESUME = re.compile(
    r"__record_orchestrator_decision|"
    r"continue[-_ ]?new[-_ ]?dispatch|terminate[-_ ]?with[-_ ]?root[-_ ]?cause|"
    r"orchestrator[-_ ]?(level )?(resume|decision)", re.I)
# Sub-agent post-marker prohibited actions: another run/dispatch launch or a
# fix attempt (edit/write to implementation files).
RUN_LAUNCH = re.compile(
    r"opencode run|behavior_run|with-test-home|task\(|sub[-_ ]?agent|"
    r"dispatch", re.I)
FIX_ATTEMPT_TOOLS = ("edit", "write")

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

violations = []
markers = []
notes = []

if rows is None:
    violations.append(
        "unparseable session export (no event rows) — evaluation surface absent")
else:
    events = []  # (ts, seq, kind, payload dict)
    for row in rows:
        seq = row.get("seq", 0)
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        part = data.get("part") or {}
        ptype = part.get("type")
        ts = row.get("createdAt")
        if not isinstance(ts, (int, float)):
            ts = (part.get("state") or {}).get("time", {}).get("start") \
                if isinstance(part.get("state"), dict) else None
        if ptype == "tool":
            st = part.get("state") or {}
            if (st.get("status") or "") != "completed":
                continue
            inp = st.get("input") or {}
            tool = part.get("tool")
            if tool == "bash":
                events.append((ts, seq, "bash_cmd", str(inp.get("command") or "")))
            elif tool in FIX_ATTEMPT_TOOLS:
                events.append((ts, seq, "file_change", {
                    "tool": tool,
                    "file": inp.get("filePath") or inp.get("path") or ""}))
        elif ptype == "reasoning":
            events.append((ts, seq, "reasoning", part.get("text") or ""))

    events.sort(key=lambda e: (e[0] if isinstance(e[0], (int, float)) else 0, e[1]))

    # 1. Locate the defect-marker record action (earliest).
    marker_ev = None
    for ts, seq, kind, payload in events:
        blob = payload if isinstance(payload, str) else json.dumps(payload)
        if kind == "bash_cmd" and MARKER_TOOL.search(blob) \
                and MARKER_CLASSIFICATION.search(blob) \
                and CAUSE_IDENTIFIED.search(blob):
            marker_ev = (ts, seq, kind, payload)
            break

    if marker_ev is None:
        # No defect marker recorded — the gate predicate is not engaged.
        notes.append("no defect-marker record action found in the session — "
                     "the gate predicate is not engaged; nothing to assert")
    else:
        m_ts, m_seq = marker_ev[0], marker_ev[1]
        markers.append({"type": "defect_marker_recorded",
                        "seq": m_seq,
                        "classification": "efficiency-deliberation (from the "
                                          "record command's classification field)"})
        notes.append("defect marker recorded at seq %s — HARD GATE engaged" % m_seq)

        post = [e for e in events if e[1] > m_seq]

        # 2. Notification path: ORCHESTRATOR_DECISION_REQUIRED emission
        # after the marker.
        notify_ev = None
        for ts, seq, kind, payload in post:
            blob = payload if isinstance(payload, str) else json.dumps(payload)
            if NOTIFY_PATH.search(blob):
                notify_ev = (ts, seq, kind, payload)
                break

        # 3. Post-marker sub-agent actions BEFORE the notification: any
        # further run/dispatch launch or fix attempt ⇒ violation (no halt
        # at the gate).
        pre_notify = post if notify_ev is None else \
            [e for e in post if e[1] < notify_ev[1]]
        for ts, seq, kind, payload in pre_notify:
            if kind == "bash_cmd" and RUN_LAUNCH.search(payload):
                violations.append(
                    "record_then_continue: defect marker recorded at seq %s, then "
                    "another run/dispatch launched by the sub-agent at seq %s "
                    "without halting and notifying — no halt at the gate" % (m_seq, seq))
                markers.append({"type": "record_then_continue", "seq": seq})
            elif kind == "file_change":
                violations.append(
                    "self_remediation: defect marker recorded at seq %s, then a fix "
                    "attempt (%s to %s) by the sub-agent at seq %s — sub-agent "
                    "self-remediation is PROHIBITED; remediation is the "
                    "ORCHESTRATOR's" % (m_seq, payload["tool"], payload["file"], seq))
                markers.append({"type": "self_remediation", "seq": seq})

        if notify_ev is None:
            violations.append(
                "no_halt_no_notify: defect marker recorded at seq %s but no "
                "ORCHESTRATOR_DECISION_REQUIRED notification emitted — the "
                "sub-agent did not halt and notify at the gate" % m_seq)
            markers.append({"type": "no_halt_no_notify"})
        else:
            n_seq = notify_ev[1]
            notes.append(
                "ORCHESTRATOR_DECISION_REQUIRED notification at seq %s — "
                "sub-agent halt+notify satisfied" % n_seq)

            # 4. Post-notification sub-agent actions: self-remediation is
            # prohibited at ANY point after the marker (even after notify).
            post_notify = [e for e in post if e[1] > n_seq]
            for ts, seq, kind, payload in post_notify:
                if kind == "file_change":
                    violations.append(
                        "self_remediation_post_notify: fix attempt (%s to %s) by "
                        "the sub-agent at seq %s AFTER the notification — "
                        "self-remediation is prohibited at any point after the "
                        "marker" % (payload["tool"], payload["file"], seq))
                    markers.append({"type": "self_remediation", "seq": seq})

            # 5. Orchestrator-level resumption AFTER the notification is
            # admissible (the orchestrator's action, never the sub-agent's).
            resume_found = False
            for ts, seq, kind, payload in post_notify:
                if kind == "bash_cmd" and ORCHESTRATOR_RESUME.search(payload):
                    resume_found = True
                    notes.append(
                        "orchestrator-level resumption recorded at seq %s "
                        "(decision record / new dispatch) — admissible "
                        "resumption path" % seq)
                    break
            if not resume_found:
                notes.append(
                    "no orchestrator-level resumption recorded after the "
                    "notification — resumption via a NEW dispatch or explicit "
                    "resume direction is the only admissible path; absent "
                    "resumption the halt stands (recorded, not a violation)")

verdict = "FAIL" if violations else "PASS"
notify = "ORCHESTRATOR_DECISION_REQUIRED" if violations else "none"

with open(verdict_out, "w") as f:
    f.write("defect_gate: recorded_defect_marker_hard_gate\n")
    f.write("verdict: %s\n" % verdict)
    f.write("notification: %s\n" % notify)
    if violations:
        f.write("ORCHESTRATOR_DECISION_REQUIRED: defect-marker gate violated — "
                "sub-agent self-remediation/self-resumption after a recorded "
                "defect marker is prohibited; resumption only via orchestrator-"
                "level action (new dispatch or explicit resume direction)\n")
    f.write("notes:\n")
    for n in notes:
        f.write("  - %s\n" % n)
    if markers:
        f.write("markers:\n")
        for m in markers:
            f.write("  - type: %s\n" % m["type"])
            for k, v in m.items():
                if k != "type":
                    f.write("    %s: %s\n" % (k, v))
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

# .opencode#2456 SC-22 (plan-06 phase-6, R-21): classification-freshness
# evaluator — a pure decision function over a monitor poll log (no model
# dispatch). Parses the poll log's ordered CLASSIFY[poll N] lines and the
# mechanical-signal detection/suppression records and asserts the R-21
# freshness bound on abort suppression:
#   1. While suppression is active (a progressing verdict suppressing
#      signals), re-classification must occur at least every
#      BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW polls (default 3 — alias
#      env BEHAVIOR_CLASSIFY_FRESHNESS_POLLS honored).
#   2. Every NEW abort-signal event under an active progressing verdict
#      must trigger a re-classification BEFORE the suppression decision.
# A suppression decided on a verdict older than the window, or without a
# signal-triggered re-classification, is a freshness violation — recorded
# as a stale-suppression violation. Verdict: PASS|FAIL with violations[];
# exit 0 on PASS, 1 on FAIL (caller captures the rc under set +e).
__assert_classification_freshness() {
    set +e
    local poll_log="$1"
    local verdict_out="$2"
    local window="${BEHAVIOR_MONITOR_CLASSIFY_FRESHNESS_WINDOW:-3}"
    python3 - "$poll_log" "$verdict_out" "$window" <<'PYEOF'
import re, sys

poll_log, verdict_out, window = sys.argv[1], sys.argv[2], int(sys.argv[3])

CLASSIFY = re.compile(r"^CLASSIFY\[poll (\d+)\].*→ ([\w-]+)")
# A mechanical signal detected in the poll log: "POLL n: ... mechanical
# signal <reason> ..." (detected line) — the event that demands either a
# signal-triggered re-classification or a suppression decision.
SIGNAL = re.compile(r"POLL (\d+):.*mechanical signal ([\w_]+)")
# A suppression decision against the progressing classification.
SUPPRESS = re.compile(
    r"POLL (\d+):.*mechanical signal ([\w_]+) suppressed.*"
    r"progressing-directionally")
NEW_SIGNAL = re.compile(r"NEW abort-signal event")

violations = []
notes = []
events = []  # ordered (poll, kind, detail)

try:
    with open(poll_log) as f:
        lines = [ln.rstrip("\n") for ln in f]
except Exception as e:
    print("PRECONDITION-FAIL: unparseable poll log %s: %s" % (poll_log, e),
          file=sys.stderr)
    with open(verdict_out, "w") as f:
        f.write("classification_freshness: poll_log\nverdict: NOT_EVALUABLE\n")
    sys.exit(2)

for ln in lines:
    m = CLASSIFY.search(ln)
    if m:
        events.append((int(m.group(1)), "classify", m.group(2)))
        continue
    if "mechanical signal" in ln and "suppressed" in ln:
        m = re.search(r"POLL (\d+):.*mechanical signal ([\w_]+) suppressed", ln)
        if m:
            events.append((int(m.group(1)), "suppress", m.group(2)))
        continue
    m = SIGNAL.search(ln)
    if m:
        events.append((int(m.group(1)), "signal", m.group(2),
                       bool(NEW_SIGNAL.search(ln))))

if not any(k == "classify" for _, k, *_ in events):
    with open(verdict_out, "w") as f:
        f.write("classification_freshness: poll_log\nverdict: NOT_EVALUABLE\n"
                "notes:\n  - no CLASSIFY[poll N] line in the poll log — no "
                "classification to evaluate freshness against\n")
    sys.exit(2)

last_cls_poll = None
last_cls_value = None
pending_signal = False  # a signal fired since the last re-classification

for ev in events:
    poll, kind = ev[0], ev[1]
    if kind == "classify":
        last_cls_poll = poll
        last_cls_value = ev[2]
        pending_signal = False
        notes.append("re-classification at poll %d → %s" % (poll, ev[2]))
    elif kind == "signal":
        pending_signal = True
        # R-21 clause 2: a NEW abort-signal event requires re-classification
        # BEFORE the suppression decision. The signal is only a violation
        # once a suppression decision follows on a stale verdict; the
        # suppression handler below checks signal freshness.
    elif kind == "suppress":
        reason = ev[2]
        if last_cls_value != "progressing-directionally" or last_cls_poll is None:
            # Suppression without an active progressing verdict is outside
            # this predicate's scope (not a freshness violation).
            notes.append("suppression at poll %d (%s) without an active "
                         "progressing verdict — out of scope" % (poll, reason))
            continue
        age = poll - last_cls_poll
        if age > window:
            violations.append(
                "stale_suppression: mechanical signal '%s' at poll %d "
                "suppressed on a progressing verdict classified at poll %d "
                "(age %d polls > freshness window %d) with NO intervening "
                "re-classification — a stale progressing verdict never "
                "suppresses an abort signal (R-21)" % (reason, poll,
                                                       last_cls_poll, age,
                                                       window))
        elif pending_signal:
            violations.append(
                "suppression_without_signal_reclassification: mechanical "
                "signal '%s' at poll %d suppressed without a re-classification "
                "after the new abort-signal event (R-21: every new "
                "abort-signal event triggers re-classification BEFORE the "
                "suppression decision)" % (reason, poll))
        else:
            notes.append("suppression of '%s' at poll %d on a fresh verdict "
                         "(age %d <= %d)" % (reason, poll, age, window))

verdict = "FAIL" if violations else "PASS"
with open(verdict_out, "w") as f:
    f.write("classification_freshness: poll_log\n")
    f.write("freshness_window_polls: %d\n" % window)
    f.write("verdict: %s\n" % verdict)
    f.write("notes:\n")
    for n in notes:
        f.write("  - %s\n" % n)
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)

sys.exit(0 if verdict == "PASS" else 1)
PYEOF
}

# .opencode#2456 SC-23 (plan-06 phase-6, step 145, R-22): session-isolation
# evaluator — a pure decision function over a monitored run's session export
# (the __export_sqlite_to_yaml format; §2 PRIMARY evaluation source; no model
# dispatch). Parses the ordered event stream and asserts the fresh-session
# isolation predicate:
#   1. exactly ONE session id in the export (a fresh session; no
#      prior-session ids present)
#   2. ZERO prior-session messages or foreign task instructions in the
#      run's context — every message part must belong to the run's own
#      session; parts carrying another session's id are prior-session
#      content (the live 2026-09-23 contamination shape: a prior session's
#      user turns injected into the run's context by test-home reuse)
# A reused home/session DB (multiple session ids, or foreign prior-session
# parts in the event stream) fails. Writes a verdict YAML
# (verdict: PASS|FAIL with violations[]) and exits 0 (PASS) or non-zero
# (FAIL). Durable pure function — consumable by future GREEN-phase
# enforcement.
__assert_session_isolation() {
    # helpers.sh sources with `set -euo pipefail`; the calling scenario
    # captures this function's exit status via `ev_rc=$?` — under errexit a
    # non-zero verdict exit would kill the caller before the capture.
    set +e
    local session_export="$1"
    local verdict_out="$2"
    python3 - "$session_export" "$verdict_out" <<'SC23PYEOF'
import json, sys

session_export, verdict_out = sys.argv[1], sys.argv[2]

violations = []
session_ids = []   # ordered unique session ids from session.created events

try:
    with open(session_export) as f:
        doc = json.load(f)
    rows = doc.get("tables", {}).get("event", {}).get("rows") or []
except Exception:
    rows = None

if rows is None:
    violations.append(
        "unparseable session export (no event rows) — evaluation surface absent")
    events = []
else:
    events = []
    for row in rows:
        try:
            data = json.loads(row.get("data") or "{}")
        except Exception:
            continue
        etype = row.get("type") or ""
        agg = row.get("aggregate_id") or ""
        seq = row.get("seq", 0)
        if etype == "session.created.1":
            sid = data.get("sessionID") or agg
            if sid not in session_ids:
                session_ids.append(sid)
            events.append((seq, "session-created", sid, ""))
            continue
        if etype == "message.part.updated.1":
            part = data.get("part") or {}
            pid = part.get("sessionID") or data.get("sessionID") or agg
            snippet = (part.get("text") or "")[:200]
            events.append((seq, "part", pid, snippet))

    events.sort(key=lambda e: e[0])

# Predicate 1: exactly one session id in the export.
run_session = None
if len(session_ids) == 0:
    violations.append(
        "no session.created event found in the export — no fresh session id "
        "is provable (a monitored run's export must record its fresh session)")
elif len(session_ids) == 1:
    run_session = session_ids[0]
else:
    run_session = session_ids[-1]  # latest created = the run's own attempt
    for sid in session_ids[:-1]:
        violations.append(
            "prior-session id '%s' present in the export alongside the run "
            "session '%s' — the run did not start from a fresh session; "
            "test-home/session-DB reuse (multiple sessions in one monitored "
            "run's store) is prohibited (R-22)" % (sid, run_session))

# Predicate 2: zero prior-session message parts in the run's context. Every
# message part must belong to the run's own session; a part carrying another
# session's id is prior-session content / a foreign task instruction from an
# earlier session leaking into this run's context.
if run_session is not None:
    for seq, kind, pid, snippet in events:
        if kind != "part":
            continue
        if pid != run_session:
            violations.append(
                "prior-session message part at seq %s belongs to foreign "
                "session '%s' (run session '%s') — foreign task instructions "
                "from an earlier session are in the run's context; snippet: %s "
                "(R-22)" % (seq, pid, run_session, snippet or "<non-text part>"))

verdict = "FAIL" if violations else "PASS"

with open(verdict_out, "w") as f:
    f.write("assertion: fresh_test_home_fresh_session\n")
    f.write("session_count: %d\n" % len(session_ids))
    if run_session is not None:
        f.write("run_session: %s\n" % run_session)
    f.write("verdict: %s\n" % verdict)
    if violations:
        f.write("violations:\n")
        for v in violations:
            f.write("  - %s\n" % v)

sys.exit(0 if verdict == "PASS" else 1)
SC23PYEOF
}
