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
# ║  `opencode run "continue" --task_id <id>` — NEVER kill and restart.           ║
# ║                                                                              ║
# ║  Violation = orphaned processes = hang = manual kill -9 required.            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../default-model.sh"
BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests-v2/with-test-home}"
BEHAVIOR_FIXTURE_ISSUES="${BEHAVIOR_FIXTURE_ISSUES:-1}"
BEHAVIOR_HARNESS_VERSION="${BEHAVIOR_HARNESS_VERSION:-1}"

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

    # SC-4: Generate admin token
    local token
    token=$(curl -s -X POST "http://localhost:$port/api/v3/tokens" -H "Content-Type: application/json" -d '{"name":"test-token","permissions":["repo","issue"]}' 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('token',''))" 2>/dev/null || true)
    if [ -z "$token" ]; then
        # GitBucket admin default: root/root
        token=$(curl -s -u root:root -X POST "http://localhost:$port/api/v3/tokens" -H "Content-Type: application/json" -d '{"name":"test-token","permissions":["repo","issue"]}' 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('token',''))" 2>/dev/null || true)
    fi
    if [ -z "$token" ]; then
        echo "  [gitbucket] WARNING: could not generate admin token — using default root:root" >&2
        export GB_TOKEN="root"
    else
        export GB_TOKEN="$token"
        echo "  [gitbucket] admin token generated" >&2
    fi

    # SC-5: Create test repo via API (no gb config needed — curl with basic auth)
    curl -s -u root:root -X POST "http://localhost:$port/api/v3/user/repos" \
        -H "Content-Type: application/json" \
        -d '{"name":"test-repo"}' >/dev/null 2>&1 || true
    echo "  [gitbucket] test repo created via API" >&2

    # Wire origin on the test project
    local test_project="${TEST_PROJECT:-$project_root}"
    if git -C "$test_project" remote get-url origin &>/dev/null; then
        git -C "$test_project" remote remove origin 2>/dev/null || true
    fi
    git -C "$test_project" remote add origin "http://root:${GB_TOKEN}@localhost:${port}/git/root/test-repo.git" 2>/dev/null || true
    git -C "$test_project" push -u origin main 2>/dev/null || true
    echo "  [gitbucket] test repo wired as origin" >&2
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

    # Search stdout first, then stderr — TEST_HOME= is emitted to stderr by with-test-home.
    local test_home=""
    if [ -n "$stdout_file" ] && [ -f "$stdout_file" ]; then
        test_home=$(grep '^TEST_HOME=' "$stdout_file" | head -1 | sed 's/^TEST_HOME=//')
    fi
    if [ -z "$test_home" ] && [ -n "$stderr_file" ] && [ -f "$stderr_file" ]; then
        test_home=$(grep '^TEST_HOME=' "$stderr_file" | head -1 | sed 's/^TEST_HOME=//')
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

        # Create a fresh workdir per attempt — with-test-home moves it into the test home.
        local attempt_workdir
        attempt_workdir=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
        git init -q "$attempt_workdir"
        git -C "$attempt_workdir" config user.email "test@test.dev"
        git -C "$attempt_workdir" config user.name "Test"

        git clone -q "$submodule_remote_url" "$attempt_workdir/.opencode" 2>/dev/null || {
            echo "FATAL: git clone failed for .opencode from $submodule_remote_url" >&2
            exit 1
        }

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

        if [ "${BEHAVIOR_SET_BARE_REMOTE:-0}" = "1" ]; then
            local bare_repo="$attempt_workdir/../origin.git"
            git init --bare "$bare_repo" 2>/dev/null || true
            git -C "$attempt_workdir" remote add origin "$bare_repo" 2>/dev/null || true
            echo "  [harness] bare remote set up at $bare_repo"
        fi

        if [ "${BEHAVIOR_SETUP_STALE_WORKTREE:-0}" = "1" ]; then
            (cd "$attempt_workdir" && ./.opencode/tools/local-issues create --title "stale-test" 2>/dev/null) || true
            rm -rf "$attempt_workdir/.issues"
            echo "  [harness] stale worktree state set up (issue created, .issues/ deleted)"
        fi

        if [ "${BEHAVIOR_SETUP_DEAD_BRANCHES:-0}" = "1" ]; then
            # Create a branch with only submodule pointer changes (dead branch)
            git -C "$attempt_workdir" checkout -b feature/2219-sub-pointer-only main 2>/dev/null || true
            # Simulate a dirty submodule pointer by modifying .gitmodules or creating a submodule entry
            echo "# dirty submodule pointer" >> "$attempt_workdir/.gitmodules"
            git -C "$attempt_workdir" add .gitmodules 2>/dev/null || true
            git -C "$attempt_workdir" commit -m "chore: update submodule pointer" 2>/dev/null || true
            # Reset to main to leave the branch as-is
            git -C "$attempt_workdir" checkout main 2>/dev/null || true

            # Create a branch with real code changes + submodule pointer changes (live branch)
            git -C "$attempt_workdir" checkout -b feature/2219-real-changes main 2>/dev/null || true
            echo "real code change" > "$attempt_workdir/src/test.txt"
            mkdir -p "$attempt_workdir/src"
            echo "real code change" > "$attempt_workdir/src/test.txt"
            echo "# dirty submodule pointer" >> "$attempt_workdir/.gitmodules"
            git -C "$attempt_workdir" add src/test.txt .gitmodules 2>/dev/null || true
            git -C "$attempt_workdir" commit -m "feat: real change plus submodule update" 2>/dev/null || true
            git -C "$attempt_workdir" checkout main 2>/dev/null || true
            echo "  [harness] dead branches set up (feature/2219-sub-pointer-only, feature/2219-real-changes)"
        fi

        # Wire GitBucket remote on the attempt workdir if GitBucket is provisioned
        if [ "${BEHAVIOR_NEEDS_REMOTE:-0}" = "1" ] && [ -n "${GITBUCKET_PORT:-}" ]; then
            local gb_port="${GITBUCKET_PORT}"
            local gb_token="${GB_TOKEN:-root}"
            git -C "$attempt_workdir" remote add origin "http://root:${gb_token}@localhost:${gb_port}/git/root/test-repo.git" 2>/dev/null || true
            git -C "$attempt_workdir" push -u origin main 2>/dev/null || true
            echo "  [harness] GitBucket remote wired on attempt workdir (port $gb_port)" >&2
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

assert_semantic() {
    local artifact_dir="$1"
    local sc_id="$2"
    local description="$3"
    local model="${4:-$DEFAULT_TEST_MODEL}"

    local stdout_file="$artifact_dir/stdout.log"
    local stderr_file="$artifact_dir/stderr.log"
    local session_file="$artifact_dir/session.yaml"
    local timeline_file="$artifact_dir/timeline.yaml"

    if [ ! -f "$stdout_file" ] || [ ! -f "$stderr_file" ]; then
        echo "  FAIL: $sc_id — artifact files not found in $artifact_dir" >&2
        return 1
    fi

    local stdout_content
    stdout_content=$(cat "$stdout_file")
    local stderr_content
    stderr_content=$(cat "$stderr_file")

    local structured_data=""
    if [ -f "$session_file" ]; then
        structured_data="${structured_data}
SESSION.YAML (structured tool call data):
$(cat "$session_file")"
    fi
    if [ -f "$timeline_file" ]; then
        structured_data="${structured_data}
TIMELINE.YAML (condensed tool call timeline):
$(cat "$timeline_file")"
    fi

    local inspector_prompt="You are a clean-room semantic inspector. Evaluate the following agent output and determine if the agent's actions and decisions satisfy this criterion:

CRITERION: $description

STDOUT (agent prose):
$stdout_content

STDERR (tool dispatch trace):
$stderr_content
${structured_data}

Respond with exactly one word: PASS or FAIL. Then on a new line, provide a one-sentence justification."

    local inspector_output
    inspector_output=$("${OPENCODE_CMD[@]}" run "$inspector_prompt" --model "$model" 2>/dev/null || true)

    if echo "$inspector_output" | grep -q '^PASS'; then
        return 0
    fi
    echo "  FAIL: $sc_id — semantic inspector returned FAIL" >&2
    echo "  Inspector output: $inspector_output" >&2
    return 1
}
