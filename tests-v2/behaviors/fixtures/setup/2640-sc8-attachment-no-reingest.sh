# Per-scenario fixture for 2640-sc8-attachment-no-reingest.
# Writes the image that the scenario attaches to the opening prompt via
# SCENARIO_ATTACH (harness `opencode run -f` support) — the user-attachment
# entry path the SC-8 escape/no-compounding criterion requires.
setup_2640_sc8() {
    local wd="$1"
    source "$(dirname "${BASH_SOURCE[0]}")/2640-image-common.sh"
    mkdir -p "$wd/fixtures-attachment"
    make_test_png "$wd/fixtures-attachment/colors.png"
}
setup_2640_sc8 "$1"
