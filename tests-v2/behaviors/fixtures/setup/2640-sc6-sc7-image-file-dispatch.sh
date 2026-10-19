# Per-scenario fixture for 2640-sc6-sc7-image-file-dispatch.
# Pre-supplies the image material on disk (project-relative path) that the
# scenario's image-work task references — the run agent never has to
# generate or discover it (pre-supplied environment mandate, §3a).
setup_2640_sc6_sc7() {
    local wd="$1"
    source "$(dirname "${BASH_SOURCE[0]}")/2640-image-common.sh"
    mkdir -p "$wd/assets"
    make_test_png "$wd/assets/metrics.png"
}
setup_2640_sc6_sc7 "$1"
