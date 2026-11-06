# Per-scenario fixture (.opencode#2717 SC-2): write the project `.env` the
# env-loader plugin parses. The sentinel is unique per scenario; the quoted
# value must survive quoting (literal hash inside quotes is data), and the
# unquoted value must have its inline comment stripped.

setup_2717_sc2_env_loader_sentinel() {
    local wd="$1"
    cat > "$wd/.env" <<'ENVFILE'
# sentinel block for .opencode#2717 SC-2
TEST_SENTINEL_2717=sentinel-QZ-4471-blue
QUOTED_VALUE="quoted-hash-no-strip # keep me"
COMMENTED_VALUE=stripped-me # this comment goes away
ENVFILE
}

setup_2717_sc2_env_loader_sentinel "$1"
