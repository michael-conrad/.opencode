# Per-scenario fixture: 2434-sc8-cycle-compliance (SC-8, .opencode#2434).
# Sourced by behavior_run() with $1 = attempt workdir (the future test-home project).
# See .opencode/tests-v2/AGENTS.md §3 Step 0b for the fixture-script contract.
#
# Sets up, inside the isolated workdir ONLY (never the live repo):
# 1. fixtures-remote/opencode-bare.git — a local bare remote seeded from the
#    cloned .opencode history, so the agent's commit+push remediation lands on an
#    isolated remote (no real-remote mutation) and the nested harness clone+checkout
#    gate can see the pushed commit.
# 2. .opencode origin, .git/config, and .gitmodules rewritten to relative paths
#    that resolve from the project root (./fixtures-remote/...) and from inside
#    .opencode (../fixtures-remote/...) — both survive the workdir move into the
#    test home.
# 3. The test-framework bug under test: behaviors/smoke-probe.sh with a typo'd
#    behavior_runn call — the real-domain bug the agent must fix.
# 4. .tools/ copies (standalone opencode binary, uv, uvx) so the agent's nested
#    with-test-home invocation finds the standalone binary (§5 Binary) and the
#    uv/uvx copies (§5 uv/uvx Copy).

setup_2434_sc8_cycle_compliance() {
    local wd="$1"
    local fixture_dir
    fixture_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # fixtures/setup -> fixtures -> behaviors -> tests-v2 -> .opencode -> project root
    local prod_root
    prod_root="$(cd "$fixture_dir/../../../../.." && pwd)"

    # 1. isolated bare remote seeded from the .opencode clone's history
    mkdir -p "$wd/fixtures-remote"
    git clone --bare -q "$wd/.opencode" "$wd/fixtures-remote/opencode-bare.git" || return 1

    # 2. rewire origin + effective config + .gitmodules to the isolated bare remote
    git -C "$wd/.opencode" remote set-url origin "../fixtures-remote/opencode-bare.git"
    git -C "$wd" config submodule..opencode.url "./fixtures-remote/opencode-bare.git"
    if [ -f "$wd/.gitmodules" ]; then
        git config --file "$wd/.gitmodules" submodule..opencode.url "./fixtures-remote/opencode-bare.git"
    fi

    # 3. plant the test-framework bug (typo'd behavior_runn call in smoke-probe.sh)
    cat > "$wd/.opencode/tests-v2/behaviors/smoke-probe.sh" <<'SMOKEEOF'
#!/bin/bash
# Behavioral test: smoke-probe
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="smoke-probe"
SCENARIO_PROMPT="Reply with exactly: SMOKE-PROBE-OK"

behavior_runn "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
SMOKEEOF
    chmod +x "$wd/.opencode/tests-v2/behaviors/smoke-probe.sh"

    # 4. .tools/ copies for the agent's nested with-test-home invocation
    mkdir -p "$wd/.tools/opencode" "$wd/.tools/uv"
    if [ -x "$prod_root/.tools/opencode/opencode" ]; then
        cp "$prod_root/.tools/opencode/opencode" "$wd/.tools/opencode/opencode"
    fi
    if [ -x "$prod_root/.tools/uv/uv" ]; then
        cp "$prod_root/.tools/uv/uv" "$wd/.tools/uv/uv"
        cp "$prod_root/.tools/uv/uvx" "$wd/.tools/uv/uvx" 2>/dev/null || true
    fi
}
setup_2434_sc8_cycle_compliance "$1"