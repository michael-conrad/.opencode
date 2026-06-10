#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR=".opencode/tools"
PASS=0
FAIL=0

check_bash_guard() {
    local file="$1"
    if head -2 "$file" | tail -1 | grep -Fq '"exec" "uv" "run" "--script" "$0" "$@"'; then
        PASS=$((PASS + 1))
    else
        echo "FAIL: $file missing polyglot bash guard on line 2"
        FAIL=$((FAIL + 1))
    fi
}

check_shebang() {
    local file="$1"
    if head -1 "$file" | grep -q '^#!/usr/bin/env -S uv run --script$'; then
        PASS=$((PASS + 1))
    else
        echo "FAIL: $file missing PEP 723 shebang"
        FAIL=$((FAIL + 1))
    fi
}

check_pep723_metadata() {
    local file="$1"
    if grep -q '^# /// script$' "$file" && grep -q '^# requires-python' "$file" && grep -q '^# dependencies' "$file"; then
        PASS=$((PASS + 1))
    else
        echo "FAIL: $file missing PEP 723 metadata"
        FAIL=$((FAIL + 1))
    fi
}

check_execute() {
    local file="$1"
    if [ -x "$file" ]; then
        PASS=$((PASS + 1))
    else
        echo "FAIL: $file not executable"
        FAIL=$((FAIL + 1))
    fi
}

check_python_version_pinned() {
    local file="$1"
    if grep -q '^# requires-python = "~=3\.12"' "$file"; then
        PASS=$((PASS + 1))
    else
        echo "FAIL: $file python version not pinned with ~="
        FAIL=$((FAIL + 1))
    fi
}

check_no_old_references() {
    local matches
        matches=$(grep -rn "uv run python .opencode" .opencode/guidelines/ .opencode/AGENTS.md .opencode/skills/ 2>/dev/null | grep -v "Do NOT use" || true)
    if [ -n "$matches" ]; then
        echo "FAIL: Old 'uv run python .opencode' references found:"
        echo "$matches"
        FAIL=$((FAIL + 1))
    else
        PASS=$((PASS + 1))
    fi

    local md_matches
    md_matches=$(grep -rn 'uv run python ' .opencode/ --include='*.md' 2>/dev/null | grep -v '# Do NOT use' | grep -v 'Do NOT use' | grep -v 'FORBIDDEN' | grep -v 'python -m unittest' || true)
    if [ -n "$md_matches" ]; then
        echo "FAIL: Old 'uv run python' references found in .md files:"
        echo "$md_matches"
        FAIL=$((FAIL + 1))
    else
        PASS=$((PASS + 1))
    fi
}

check_python_script() {
    local file="$1"
    check_shebang "$file"
    check_bash_guard "$file"
    check_pep723_metadata "$file"
    check_python_version_pinned "$file"
}

check_description_flag() {
    local tool_path="$TOOLS_DIR/$1"
    local desc
    desc=$("$tool_path" --description 2>/dev/null) || {
        echo "FAIL: $tool_path --description exited non-zero"
        FAIL=$((FAIL + 1))
        return 0
    }
    if [[ -z "$desc" ]]; then
        echo "FAIL: $tool_path --description produced empty output"
        FAIL=$((FAIL + 1))
        return 0
    fi
    PASS=$((PASS + 1))
}

ENTRY_POINTS=(
    guidelines memory md py jupyter help file-exists
    schema-version jupyter-start jupyter-stop symbolic session-init
    gitbucket-api
)

for tool in "${ENTRY_POINTS[@]}"; do
    file="$TOOLS_DIR/$tool"
    check_shebang "$file"
    check_pep723_metadata "$file"
    check_execute "$file"
    check_python_version_pinned "$file"
done

echo "--- check_description_flag ---"
for tool in "${ENTRY_POINTS[@]}"; do
    check_description_flag "$tool"
done

IMPL_DIR=".opencode/tools/impl"
for impl_file in "$IMPL_DIR"/*; do
    [ -f "$impl_file" ] || continue
    check_python_script "$impl_file"
done

SCRIPTS_DIR=".opencode/scripts"
for script_file in "$SCRIPTS_DIR"/*.py; do
    [ -f "$script_file" ] || continue
    check_python_script "$script_file"
done

SKILL_SCRIPTS_DIR=".opencode/skills"
find "$SKILL_SCRIPTS_DIR" -name '*.py' -not -path '*/tests/*' | while read -r skill_py; do
    check_python_script "$skill_py"
done

check_no_old_references

check_plugin_invocations() {
    local plugin_failures=0
    local plugin_files
    plugin_files=$(find .opencode/plugins -name '*.ts' -o -name '*.js' 2>/dev/null || true)
    for pf in $plugin_files; do
        local bare_matches
        bare_matches=$(grep -n 'uv run [^ ]*\.opencode/' "$pf" 2>/dev/null | grep -v '\-\-script' || true)
        if [ -n "$bare_matches" ]; then
            echo "FAIL: $pf has bare 'uv run' without --script:"
            echo "$bare_matches"
            FAIL=$((FAIL + 1))
            plugin_failures=$((plugin_failures + 1))
        fi
    done
    if [ "$plugin_failures" -eq 0 ]; then
        PASS=$((PASS + 1))
    fi
}

check_plugin_invocations

check_no_python_imports() {
    local import_matches
    import_matches=$(grep -rn 'from skills.gitbucket_api' .opencode/ 2>/dev/null | grep -v 'test-pep723-tools.sh' || true)
    if [ -n "$import_matches" ]; then
        echo "FAIL: Old 'from skills.gitbucket_api' import references found (should use CLI tool):"
        echo "$import_matches"
        FAIL=$((FAIL + 1))
    else
        PASS=$((PASS + 1))
    fi
}

check_no_python_imports

check_root_resolution_patterns() {
    echo "--- Root Resolution Pattern Checks ---"

    local prohibited_patterns_found=0

    local show_cdup_matches
    show_cdup_matches=$(grep -rn 'rev-parse.*--show-cdup' .opencode/tools/ .opencode/scripts/ .opencode/skills/ .opencode/plugins/ 2>/dev/null | grep -v 'test-pep723-tools.sh' | grep -v '__pycache__' || true)
    if [ -n "$show_cdup_matches" ]; then
        echo "FAIL: Prohibited --show-cdup found (use walk-up-to-.opencode per 210-scripting.md):"
        echo "$show_cdup_matches"
        FAIL=$((FAIL + 1))
        prohibited_patterns_found=1
    fi

    local show_toplevel_matches
    show_toplevel_matches=$(grep -rn 'rev-parse.*--show-toplevel' .opencode/tools/ .opencode/scripts/ .opencode/skills/ .opencode/plugins/ 2>/dev/null | grep -v 'test-pep723-tools.sh' | grep -v '__pycache__' || true)
    if [ -n "$show_toplevel_matches" ]; then
        echo "FAIL: Prohibited --show-toplevel found (use walk-up-to-.opencode per 210-scripting.md):"
        echo "$show_toplevel_matches"
        FAIL=$((FAIL + 1))
        prohibited_patterns_found=1
    fi

    local depth_parent_matches
    depth_parent_matches=$(grep -rn '\.parent\.parent' .opencode/tools/ .opencode/scripts/ .opencode/skills/ .opencode/plugins/ 2>/dev/null | grep -v 'test-pep723-tools.sh' | grep -v '__pycache__' || true)
    if [ -n "$depth_parent_matches" ]; then
        echo "FAIL: Prohibited .parent.parent chains found (use walk-up-to-.opencode per 210-scripting.md):"
        echo "$depth_parent_matches"
        FAIL=$((FAIL + 1))
        prohibited_patterns_found=1
    fi

    local syspath_matches
    syspath_matches=$(grep -rn 'sys\.path\.\(insert\|append\)' .opencode/tools/ .opencode/scripts/ .opencode/skills/ .opencode/plugins/ 2>/dev/null | grep -v 'test-pep723-tools.sh' | grep -v '__pycache__' || true)
    if [ -n "$syspath_matches" ]; then
        echo "FAIL: Prohibited sys.path.insert/append found for root detection (use walk-up-to-.opencode per 210-scripting.md):"
        echo "$syspath_matches"
        FAIL=$((FAIL + 1))
        prohibited_patterns_found=1
    fi

    local depth_dirname_matches
    depth_dirname_matches=$(grep -rn 'dirname.*\/\.\.\/' .opencode/tools/ .opencode/scripts/ .opencode/skills/ .opencode/plugins/ 2>/dev/null | grep -v 'test-pep723-tools.sh' | grep -v '__pycache__' || true)
    if [ -n "$depth_dirname_matches" ]; then
        echo "FAIL: Prohibited relative traversals found (use walk-up-to-.opencode per 210-scripting.md):"
        echo "$depth_dirname_matches"
        FAIL=$((FAIL + 1))
        prohibited_patterns_found=1
    fi

    if [ "$prohibited_patterns_found" -eq 0 ]; then
        PASS=$((PASS + 1))
    fi

    local walk_up_found=0
    local all_py_scripts
    all_py_scripts=$(find .opencode/tools .opencode/scripts .opencode/skills -name '*.py' 2>/dev/null | grep -v '__pycache__' | grep -v '/tests/' || true)
    for pyf in $all_py_scripts; do
        [ -f "$pyf" ] || continue
        if grep -q 'Path(__file__).resolve().parent' "$pyf"; then
            if ! grep -q 'while.*\.opencode' "$pyf"; then
                echo "FAIL: $pyf uses Path(__file__).resolve().parent without walk-up-to-.opencode loop"
                FAIL=$((FAIL + 1))
            else
                walk_up_found=$((walk_up_found + 1))
            fi
        fi
    done

    if [ "$walk_up_found" -eq 0 ]; then
        if [ -n "$(find .opencode/tools .opencode/scripts .opencode/skills -name '*.py' 2>/dev/null | grep -v '__pycache__' | grep -v '/tests/' | head -1 || true)" ]; then
            echo "FAIL: No Python scripts found using walk-up-to-.opencode root resolution pattern"
            FAIL=$((FAIL + 1))
        fi
    else
        PASS=$((PASS + 1))
    fi

    echo "--- Root-Guard Presence Checks ---"

    local root_guard_failures=0

    local py_scripts
    py_scripts=$(find .opencode/tools .opencode/scripts .opencode/skills -name '*.py' 2>/dev/null | grep -v '__pycache__' | grep -v '/tests/' || true)
    for pyf in $py_scripts; do
        [ -f "$pyf" ] || continue
        if grep -q 'while.*\.opencode' "$pyf"; then
            if ! grep -q 'if parent == _path' "$pyf"; then
                echo "FAIL: $pyf has walk-up loop but missing root-guard (if parent == _path)"
                FAIL=$((FAIL + 1))
                root_guard_failures=$((root_guard_failures + 1))
            fi
        fi
    done

    local sh_scripts
    sh_scripts=$(find .opencode/tools .opencode/scripts .opencode/skills -name '*.sh' -type f 2>/dev/null | grep -v '/tests/' || true)
    sh_scripts="$sh_scripts
$(find .opencode/tools .opencode/scripts .opencode/skills -type f 2>/dev/null | xargs file 2>/dev/null | grep 'Bourne-Again shell script' | cut -d: -f1 | grep -v '/tests/' || true)"
    for shf in $sh_scripts; do
        [ -f "$shf" ] || continue
        if grep -q 'while.*\.opencode' "$shf" 2>/dev/null; then
            if ! grep -q 'PARENT.*=.*PROJECT_DIR' "$shf" 2>/dev/null; then
                echo "FAIL: $shf has walk-up loop but missing root-guard (PARENT == PROJECT_DIR)"
                FAIL=$((FAIL + 1))
                root_guard_failures=$((root_guard_failures + 1))
            fi
        fi
    done

    if [ "$root_guard_failures" -eq 0 ]; then
        PASS=$((PASS + 1))
    fi
}

check_root_resolution_patterns

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]