#!/bin/bash
# Docker harness primitives for the tests-v2 behavioral harness.
# Spec: .opencode#2582 (R-2, R-4, R-5, R-10) — sourced by behaviors/helpers.sh.
#
# Isolation contract (SC-3/SC-4/SC-12):
#   - containers run as the invoking user's uid:gid (--user, never root);
#   - the ONLY host mount is the project's tmp/ directory, mounted at the
#     SAME absolute path inside the container so every path emitted by the
#     in-container run (TEST_HOME= markers, artifacts) is directly valid
#     host-side — no path mapping anywhere;
#   - no production path (`.tools/`, the repo worktree outside tmp/, $HOME,
#     either .issues/ store) is mounted into, or copied into, the container;
#   - the test home starts bare of agent-managed tooling (TEST_ENV=docker in
#     with-test-home skips the binary/uv copies; the image's baked base tools
#     serve as the harness's instruments).
#
# Network posture: --network host — network-neutral versus the host-mode
# runs (the test container reaches host Ollama at localhost:11434 unchanged).

TESTS_V2_GB_CONTAINER="${TESTS_V2_GB_CONTAINER:-tests-v2-gitbucket}"
TESTS_V2_AGENT_IMAGE="${TESTS_V2_AGENT_IMAGE:-tests-v2-test-agent}"
TESTS_V2_GB_IMAGE="${TESTS_V2_GB_IMAGE:-tests-v2-gitbucket}"
TESTS_V2_DOCKER_DIR="${TESTS_V2_DOCKER_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
TESTS_V2_STAGING_DIR="${TESTS_V2_STAGING_DIR:-}"

# Deferred resolution — PARENT_REPO_DIR is assigned by helpers.sh after this
# source; compute the default at first use, not at source time.
__staging_dir() {
    if [ -z "$TESTS_V2_STAGING_DIR" ]; then
        TESTS_V2_STAGING_DIR="$PARENT_REPO_DIR/tmp/docker-staging"
    fi
    echo "$TESTS_V2_STAGING_DIR"
}

__docker_available() {
    if ! docker info >/dev/null 2>&1; then
        echo "HARNESS_FAILURE: Docker daemon unavailable — start the docker service (e.g. sudo systemctl start docker) and re-run; no container created" >&2
        return 1
    fi
    return 0
}

# R-10 failure class: image pull/build failure.
__ensure_image_test_agent() {
    if docker image inspect "$TESTS_V2_AGENT_IMAGE" >/dev/null 2>&1; then
        return 0
    fi
    echo "  [docker] building test-agent image ($TESTS_V2_AGENT_IMAGE)..." >&2
    # Pre-supplied environment mandate (tests-v2/AGENTS.md §3a): the image
    # bakes the deck-mandated platform CLIs. gh installs from the Ubuntu
    # archive inside the Dockerfile; gb has no public upstream (deck
    # built-in) and is staged from the host's built-in install at provision
    # time — the same staging pattern as the GitBucket WAR.
    local gb_src
    gb_src=$(command -v gb 2>/dev/null || true)
    if [ -z "$gb_src" ]; then
        echo "HARNESS_FAILURE: gb CLI not found on host — the deck mandates gb for GitBucket operations and the image must bake it (§3a); install the deck built-in gb and re-run" >&2
        return 1
    fi
    local build_ctx="$PARENT_REPO_DIR/tmp/docker-build-agent"
    rm -rf "$build_ctx"
    mkdir -p "$build_ctx"
    cp "$TESTS_V2_DOCKER_DIR/Dockerfile.test-agent" "$build_ctx/"
    cp "$TESTS_V2_DOCKER_DIR/entrypoint.sh" "$build_ctx/"
    cp "$gb_src" "$build_ctx/gb"
    if ! docker build -f "$build_ctx/Dockerfile.test-agent" \
            -t "$TESTS_V2_AGENT_IMAGE" "$build_ctx" >&2; then
        echo "HARNESS_FAILURE: test-agent image build failed for $TESTS_V2_AGENT_IMAGE — inspect the build output above; fix the Dockerfile or the network and re-run" >&2
        return 1
    fi
    return 0
}

# Stage the harness scripts the container executes under tmp/ scratch
# (fresh copies at provision time — always current, no image-rebuild
# dependency). The staging layout preserves with-test-home's project-root
# resolution: the walk-up finds .opencode at <staging>/.opencode.
__stage_harness_scripts() {
    local staging_tests_dir="$(__staging_dir)/.opencode/tests-v2"
    mkdir -p "$staging_tests_dir"
    cp "$BEHAVIOR_HELPERS_DIR/../with-test-home" "$staging_tests_dir/with-test-home"
    cp "$BEHAVIOR_HELPERS_DIR/../default-model.sh" "$staging_tests_dir/default-model.sh"
    return 0
}

# The GitBucket container's Docker-assigned host port (SC-6: discovered via
# `docker port`, assigned at container creation).
__docker_gb_port() {
    local port
    port=$(docker port "$TESTS_V2_GB_CONTAINER" 8080/tcp 2>/dev/null | head -1 | sed 's/.*://')
    if [ -z "$port" ]; then
        echo "HARNESS_FAILURE: docker port discovery failed for $TESTS_V2_GB_CONTAINER — the container is running but publishes no 8080 mapping; inspect with: docker port $TESTS_V2_GB_CONTAINER" >&2
        return 1
    fi
    echo "$port"
}

# Mint the admin token against the provisioned instance (web-form flow —
# GitBucket exposes no REST token endpoint). Shared by provision and
# idempotent paths.
__mint_gb_token() {
    local port="$1"
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
    echo "$token"
}

__export_gb_env() {
    local port="$1" token="$2"
    export GITBUCKET_PORT="$port"
    export GB_HOST="http://localhost:$port"
    export GB_REPO="root/test-repo"
    export GB_PROTOCOL="http"
    if [ -n "$token" ]; then
        export GB_TOKEN="$token"
    else
        export GB_TOKEN="root"
    fi
    gb auth login -H "$GB_HOST" -t "$GB_TOKEN" --protocol "$GB_PROTOCOL" >/dev/null 2>&1 || true
}

# __ensure_gitbucket — containerized provisioning (SC-6, R-4).
# Idempotent: a second invocation against the running container re-exports
# the same values (token persisted under tmp/) without recreating it.
__ensure_gitbucket() {
    __docker_available || return 1
    local project_root="$PARENT_REPO_DIR"
    local staging="$(__staging_dir)/gitbucket-staging"
    local war="$staging/gitbucket.war"
    local data_dir="$project_root/tmp/gitbucket-data"
    local token_file="$project_root/tmp/.gitbucket.token"

    GITBUCKET_CONTAINER_NAME="$TESTS_V2_GB_CONTAINER"
    GITBUCKET_DATA_DIR="$data_dir"

    # Idempotent path: container already running → re-export, no recreate.
    if docker inspect -f '{{.State.Running}}' "$TESTS_V2_GB_CONTAINER" 2>/dev/null | grep -q true; then
        local port
        port=$(__docker_gb_port) || return 1
        local token=""
        if [ -f "$token_file" ]; then
            token=$(cat "$token_file" 2>/dev/null || true)
        fi
        if [ -z "$token" ]; then
            token=$(__mint_gb_token "$port")
            [ -n "$token" ] && echo "$token" > "$token_file"
        fi
        __export_gb_env "$port" "$token"
        echo "  [gitbucket] reusing container $TESTS_V2_GB_CONTAINER on port $port" >&2
        return 0
    fi

    # R-10 stale-container class: a same-name container exists but is not
    # running (crashed/stopped) — remove it before creating fresh.
    if docker container inspect "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1; then
        echo "  [gitbucket] removing stale container $TESTS_V2_GB_CONTAINER..." >&2
        docker rm -f "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1 || true
    fi

    # WAR staging: the existing release-resolution logic downloads the WAR
    # into tmp/ scratch; the image is built from that staged copy at
    # provision time (no rebuild on WAR refresh beyond re-provisioning).
    mkdir -p "$staging"
    if [ ! -f "$war" ]; then
        echo "  [gitbucket] downloading GitBucket WAR into $staging..." >&2
        local release_url
        release_url=$(curl -sL "https://api.github.com/repos/gitbucket/gitbucket/releases/latest" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print([a['browser_download_url'] for a in d['assets'] if a['name'].endswith('.war')][0])" 2>/dev/null || true)
        if [ -z "$release_url" ]; then
            echo "HARNESS_FAILURE: could not resolve GitBucket release URL — check network access to api.github.com and re-run" >&2
            return 1
        fi
        curl -sL -o "$war" "$release_url" 2>/dev/null || {
            echo "HARNESS_FAILURE: GitBucket WAR download failed — check network access and re-run" >&2
            return 1
        }
    fi

    echo "  [gitbucket] building image $TESTS_V2_GB_IMAGE from staged WAR..." >&2
    if ! docker build -q -f "$TESTS_V2_DOCKER_DIR/Dockerfile.gitbucket" \
            --build-context "war=$staging" \
            -t "$TESTS_V2_GB_IMAGE" "$TESTS_V2_DOCKER_DIR" >&2; then
        echo "HARNESS_FAILURE: GitBucket image build failed for $TESTS_V2_GB_IMAGE — inspect the build output above; fix the Dockerfile or the base-image pull and re-run" >&2
        return 1
    fi

    mkdir -p "$data_dir"
    # Docker-assigned port (-P) at container creation; discovered via docker port.
    # Runs as the invoking uid:gid — root-in-container with a write mount of a
    # tmp/ path would leave root-owned files in the host tree (SC-3 posture).
    if ! docker run -d --name "$TESTS_V2_GB_CONTAINER" -P \
            --user "$(id -u):$(id -g)" \
            -v "$data_dir:/gitbucket-home" \
            "$TESTS_V2_GB_IMAGE" >&2; then
        echo "HARNESS_FAILURE: GitBucket container creation failed (port/resource conflict or daemon error) — inspect: docker ps -a | grep $TESTS_V2_GB_CONTAINER" >&2
        return 1
    fi

    local port=""
    local wait_seconds=0
    while [ $wait_seconds -lt 30 ]; do
        port=$(__docker_gb_port 2>/dev/null || true)
        if [ -n "$port" ]; then
            break
        fi
        sleep 1
        wait_seconds=$((wait_seconds + 1))
    done
    if [ -z "$port" ]; then
        echo "HARNESS_FAILURE: GitBucket container published no port within 30s — inspect: docker port $TESTS_V2_GB_CONTAINER" >&2
        docker rm -f "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1 || true
        return 1
    fi

    # Wait for HTTP readiness.
    local ready=0
    wait_seconds=0
    while [ $wait_seconds -lt 60 ]; do
        if curl -s "http://localhost:$port/" >/dev/null 2>&1; then
            ready=1
            break
        fi
        sleep 1
        wait_seconds=$((wait_seconds + 1))
    done
    if [ "$ready" -ne 1 ]; then
        echo "HARNESS_FAILURE: GitBucket container not HTTP-ready after 60s — inspect: docker logs $TESTS_V2_GB_CONTAINER" >&2
        docker rm -f "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1 || true
        return 1
    fi

    local token
    token=$(__mint_gb_token "$port")
    if [ -n "$token" ]; then
        echo "$token" > "$token_file"
        echo "  [gitbucket] admin token generated" >&2
    else
        echo "  [gitbucket] WARNING: could not generate admin token — using default root:root" >&2
    fi
    __export_gb_env "$port" "$token"
    echo "  [gitbucket] container $TESTS_V2_GB_CONTAINER serving on port $port" >&2

    # Test repo via API (no git-mutating operation here — remote wiring stays
    # in behavior_run against the validated isolated attempt workdir).
    curl -s -u root:root -X POST "http://localhost:$port/api/v3/user/repos" \
        -H "Content-Type: application/json" \
        -d '{"name":"test-repo"}' >/dev/null 2>&1 || true
    echo "  [gitbucket] test repo created via API" >&2
}

# __reset_gitbucket — container removal + data-directory rebuild + re-provision
# (SC-7: new container id, rebuilt data dir, regenerated token).
__reset_gitbucket() {
    echo "  [gitbucket] resetting container $TESTS_V2_GB_CONTAINER..." >&2
    docker rm -f "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1 || true
    local data_dir="${GITBUCKET_DATA_DIR:-$PARENT_REPO_DIR/tmp/gitbucket-data}"
    rm -rf "$data_dir"
    rm -f "$PARENT_REPO_DIR/tmp/.gitbucket.token"
    unset GITBUCKET_PORT
    __ensure_gitbucket
}

# __kill_gitbucket — remove the container and staged state without restarting
# (--clean-all path; called from with-test-home's cleanup too).
__kill_gitbucket() {
    docker rm -f "$TESTS_V2_GB_CONTAINER" >/dev/null 2>&1 || true
    rm -rf "${GITBUCKET_DATA_DIR:-$PARENT_REPO_DIR/tmp/gitbucket-data}"
    rm -f "$PARENT_REPO_DIR/tmp/.gitbucket.token" "$PARENT_REPO_DIR/tmp/.gitbucket.pid" "$PARENT_REPO_DIR/tmp/.gitbucket.port"
    if [ -d "$PARENT_REPO_DIR/tmp/behavior-isolated" ]; then
        rm -rf "$PARENT_REPO_DIR/tmp/behavior-isolated"*
    fi
    unset GITBUCKET_PORT
}

# Remove every harness-created run container (abort/cleanup helper; images
# are preserved — R-10/SC-19).
__docker_clean_run_containers() {
    docker ps -aq --filter "name=tests-v2-run-" 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1 || true
}

# Liveness and abort for a run target — either a host PID (host tier) or
# container:<name> (Docker tier, R-5: abort = docker stop + docker rm -f,
# a guaranteed whole-tree kill).
__run_target_alive() {
    case "$1" in
        container:*)
            docker inspect -f '{{.State.Running}}' "${1#container:}" 2>/dev/null | grep -q true
            ;;
        *)
            kill -0 "$1" 2>/dev/null
            ;;
    esac
}

__abort_run_target() {
    case "$1" in
        container:*)
            local cname="${1#container:}"
            docker stop -t 10 "$cname" >/dev/null 2>&1 || true
            docker rm -f "$cname" >/dev/null 2>&1 || true
            ;;
        *)
            kill -TERM -- "-$1" 2>/dev/null || kill "$1" 2>/dev/null || true
            sleep 2
            kill -KILL -- "-$1" 2>/dev/null || kill -9 "$1" 2>/dev/null || true
            ;;
    esac
}

# Docker-mode launch of one attempt (SC-9, R-5): stage harness scripts under
# tmp/ scratch, launch the run container detached on the host network, with
# in-container redirection of stdout/stderr to the mounted log files. Prints
# the run target (container:<name>) on stdout.
__docker_launch_run() {
    local scenario_name="$1" message="$2" model="$3" agent="$4" workdir="$5" output_file="$6" err_file="$7"

    __docker_available || return 1
    __ensure_image_test_agent || return 1
    __stage_harness_scripts || return 1

    local staged_wth="$(__staging_dir)/.opencode/tests-v2/with-test-home"
    local cname="tests-v2-run-${scenario_name}-$(date +%s)-$$"
    local user_uid_gid
    user_uid_gid="$(id -u):$(id -g)"

    # Build the in-container command. Paths under tmp/ are valid in the
    # container unchanged (the mount keeps the same absolute path).
    local parent_remote_url
    parent_remote_url=$(git -C "$PARENT_REPO_DIR" config --get remote.origin.url 2>/dev/null || true)
    parent_remote_url=$(echo "$parent_remote_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')
    local -a docker_env=(-e TEST_ENV=docker -e TEST_WORKDIR="$workdir" -e "TEST_PARENT_REMOTE_URL=$parent_remote_url")
    # Submodule-URL handling: the .opencode submodule URL in the cloned
    # .gitmodules is the SSH form; the container has no SSH keys. GIT_CONFIG_*
    # env config applies to EVERY git invocation in the container (including
    # the submodule clones the parent clone spawns) — one rewrite, no
    # per-path URL handling.
    docker_env+=(-e GIT_CONFIG_COUNT=1 -e "GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf" -e "GIT_CONFIG_VALUE_0=git@github.com:")
    [ -n "${GITBUCKET_PORT:-}" ] && docker_env+=(-e "GITBUCKET_PORT=$GITBUCKET_PORT")
    [ -n "${GB_HOST:-}" ] && docker_env+=(-e "GB_HOST=$GB_HOST")
    [ -n "${GB_REPO:-}" ] && docker_env+=(-e "GB_REPO=$GB_REPO")
    [ -n "${GB_PROTOCOL:-}" ] && docker_env+=(-e "GB_PROTOCOL=$GB_PROTOCOL")
    [ -n "${GB_TOKEN:-}" ] && docker_env+=(-e "GB_TOKEN=$GB_TOKEN")
    [ -n "${BEHAVIOR_NEEDS_REMOTE:-}" ] && docker_env+=(-e "BEHAVIOR_NEEDS_REMOTE=$BEHAVIOR_NEEDS_REMOTE")
    docker_env+=(-e "OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=4000")
    [ -n "${BEHAVIOR_SET_BARE_REMOTE:-}" ] && docker_env+=(-e "BEHAVIOR_SET_BARE_REMOTE=$BEHAVIOR_SET_BARE_REMOTE")
    [ -n "${BEHAVIOR_NEEDS_MULTI_SUBMODULES:-}" ] && docker_env+=(-e "BEHAVIOR_NEEDS_MULTI_SUBMODULES=$BEHAVIOR_NEEDS_MULTI_SUBMODULES")
    [ -n "${BEHAVIOR_SHARED_HOME:-}" ] && docker_env+=(-e "BEHAVIOR_SHARED_HOME=$BEHAVIOR_SHARED_HOME")
    # Xvfb display override: --network host shares the host network namespace,
    # and Xvfb's abstract-socket listener (@/tmp/.X11-unix/X<n>) is
    # namespace-scoped — a host Xvfb on the same display number collides and
    # the entrypoint dies before the command runs. Propagate the entrypoint's
    # existing TEST_XVFB_DISPLAY hook so callers can move the container display.
    [ -n "${TEST_XVFB_DISPLAY:-}" ] && docker_env+=(-e "TEST_XVFB_DISPLAY=$TEST_XVFB_DISPLAY")

    local -a cmd=(bash "$staged_wth" opencode run "$message" --model "$model" --log-level INFO --print-logs)
    [ -n "$agent" ] && cmd+=(--agent "$agent")
    # Scenario attachment support (.opencode#2640 SC-8): SCENARIO_ATTACH carries
    # colon-separated workdir-relative paths, attached via `opencode run -f`.
    # Paths stay workdir-relative — with-test-home moves the attempt workdir
    # into the test home after fixture setup, and opencode resolves relative
    # paths from its working directory (the test project) in-container.
    if [ -n "${SCENARIO_ATTACH:-}" ]; then
        local attach_file
        local old_ifs="$IFS"
        IFS=:
        for attach_file in $SCENARIO_ATTACH; do
            [ -n "$attach_file" ] && cmd+=( -f "$attach_file" )
        done
        IFS="$old_ifs"
    fi

    local inner_cmd
    inner_cmd=$(printf '%q ' "${cmd[@]}")
    inner_cmd="$inner_cmd > $(printf '%q' "$output_file") 2> $(printf '%q' "$err_file")"

    if ! docker run -d --name "$cname" --network host \
            --user "$user_uid_gid" \
            -v "$PARENT_REPO_DIR/tmp:$PARENT_REPO_DIR/tmp" \
            "${docker_env[@]}" \
            "$TESTS_V2_AGENT_IMAGE" \
            bash -c "$inner_cmd" >/dev/null 2>&1; then
        echo "HARNESS_FAILURE: run container creation failed for $cname — inspect: docker ps -a | grep tests-v2-run-" >&2
        return 1
    fi

    echo "container:$cname"
}

# Resume launch (.opencode#2646 R-4): a second container run resuming the
# prior invocation's staged test home via `--resume-home` + `opencode run
# --continue`. Same env contract as __docker_launch_run; the staged home
# persists under the mounted tmp/ (same absolute path), so the in-container
# determination gate and session store resolve unchanged. The docker-tier
# home is bare by contract — with-test-home's docker-aware resume branch
# resolves the image binary (no host binary required in the home).
__docker_launch_resume() {
    local scenario_name="$1" home="$2" model="$3" output_file="$4" err_file="$5"
    # The run's artifact directory — where the determination record is written.
    # Optional: a caller that does not know it keeps the scan roots it had.
    local artifact_dir="${7:-}"
    # Optional resume message: the cap-resume path uses the #2646 R-4 form;
    # the two-SC scenarios pass their turn directive (.opencode#2646 docker-
    # resume fix — observed 2026-10-20: tier-2 turn-2 launches cannot exec
    # the home's bin/opencode host-side, docker homes are bare of it).
    #
    # The default is NOT the anchorless "Continue the task from where you left
    # off.": that form gives the model no state anchor, so it re-derives the
    # session's history, spends the whole per-turn budget re-deriving, and
    # issues no tool call — the resume makes no progress and the run exhausts
    # the cap-resume ceiling with no artifact
    # (lessons-learned/session-2026-10-20 LL-3). The default is the recorded
    # tail instead, composed from the home's own session database.
    local message="${6:-}"
    if [ -z "$message" ]; then
        if command -v __recorded_tail_message >/dev/null 2>&1; then
            message=$(__recorded_tail_message "$home/.local/share/opencode/opencode.db")
        fi
        if [ -z "$message" ]; then
            message="Your previous turn was cut off by the per-turn output cap. Continue the task from exactly the point your last recorded step left it; do not re-plan or re-derive the task history."
        fi
    fi

    __docker_available || return 1
    __stage_harness_scripts || return 1

    local staged_wth="$(__staging_dir)/.opencode/tests-v2/with-test-home"
    local cname="tests-v2-run-${scenario_name}-resume-$(date +%s)-$$"
    local user_uid_gid
    user_uid_gid="$(id -u):$(id -g)"

    local -a docker_env=(-e TEST_ENV=docker -e "RESUME_HOME=$home")
    docker_env+=(-e GIT_CONFIG_COUNT=1 -e "GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf" -e "GIT_CONFIG_VALUE_0=git@github.com:")
    [ -n "${GITBUCKET_PORT:-}" ] && docker_env+=(-e "GITBUCKET_PORT=$GITBUCKET_PORT")
    [ -n "${GB_HOST:-}" ] && docker_env+=(-e "GB_HOST=$GB_HOST")
    [ -n "${GB_REPO:-}" ] && docker_env+=(-e "GB_REPO=$GB_REPO")
    [ -n "${GB_PROTOCOL:-}" ] && docker_env+=(-e "GB_PROTOCOL=$GB_PROTOCOL")
    [ -n "${GB_TOKEN:-}" ] && docker_env+=(-e "GB_TOKEN=$GB_TOKEN")
    [ -n "${BEHAVIOR_NEEDS_REMOTE:-}" ] && docker_env+=(-e "BEHAVIOR_NEEDS_REMOTE=$BEHAVIOR_NEEDS_REMOTE")
    docker_env+=(-e "OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=4000")
    # The §10.7 determination gate inside the container must also scan the
    # run's evidence dir (where determination records live) — TMP_DIR alone
    # is the staging root there and never contains the record (.opencode#2646
    # docker-resume fix; tmp/ is mounted at the same absolute path, so the
    # host-side evidence dir path is valid in-container).
    # Both roots: the run's own evidence dir and the run's artifact directory,
    # which is where the determination record is written (.opencode#2663 — the
    # gate scanned only these two and never the artifact dir, so it refused
    # every cap-hit resume with "determination.yaml not found").
    local scan_list="$(dirname "$err_file")"
    [ -n "$artifact_dir" ] && scan_list="$scan_list:$artifact_dir"
    docker_env+=(-e "BEHAVIOR_DETERMINATION_SCAN_DIR=$scan_list")

    local -a cmd=(bash "$staged_wth" --resume-home "$home" opencode run --continue "$message" --model "$model" --log-level INFO --print-logs)

    local inner_cmd
    inner_cmd=$(printf '%q ' "${cmd[@]}")
    # Append (>>) — the attempt's logs already carry the original turn's
    # output incl. the TEST_HOME marker the post-run export and the scenario
    # turn-2 discovery read; truncating here destroyed them (observed
    # 2026-10-20: turn-1 evidence lost, turn-2 home discovery failed).
    inner_cmd="$inner_cmd >> $(printf '%q' "$output_file") 2>> $(printf '%q' "$err_file")"

    if ! docker run -d --name "$cname" --network host             --user "$user_uid_gid"             -v "$PARENT_REPO_DIR/tmp:$PARENT_REPO_DIR/tmp"             "${docker_env[@]}"             "$TESTS_V2_AGENT_IMAGE"             bash -c "$inner_cmd" >/dev/null 2>&1; then
        echo "HARNESS_FAILURE: resume container creation failed for $cname — inspect: docker ps -a | grep tests-v2-run-" >&2
        return 1
    fi

    echo "container:$cname"
}

# Wait for a run target to finish; prints the container's exit code for
# container targets, 0 for host PIDs (the host path waits its own way).
__wait_run_target() {
    case "$1" in
        container:*)
            docker wait "${1#container:}" 2>/dev/null || echo "1"
            ;;
        *)
            wait "$1" 2>/dev/null || true
            echo "0"
            ;;
    esac
}
