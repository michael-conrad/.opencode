#!/bin/bash
# Per-scenario fixture: static site with duplicated card styles for 2557-sc5.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc5() {
    local wd="$1"

    mkdir -p "$wd/site"

    cat > "$wd/site/styles-shared-note.txt" <<'EOF'
Internal note: the .card rule block is copy-pasted in index.html,
products.html, and about.html. The developer wants it defined once.
EOF

    make_page() {
        local page="$1" title="$2"
        cat > "$wd/site/$page" <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>$title</title>
  <style>
    body { font-family: sans-serif; margin: 2rem; }
    .card { border: 1px solid #ccc; border-radius: 8px; padding: 1rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.15); background: #fff; }
    .card h2 { margin-top: 0; color: #333; }
  </style>
</head>
<body>
  <h1>$title</h1>
  <div class="card"><h2>Featured</h2><p>Sample card content.</p></div>
</body>
</html>
EOF
    }

    make_page index.html "Home"
    make_page products.html "Products"
    make_page about.html "About"

    cat > "$wd/AGENTS.md" <<'EOF'
# Static site — agent notes

A plain HTML/CSS static site, no build step.

## Build / Lint / Test Commands

No build or test commands are declared for this repository.
EOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: static site scaffolding" || true
}

setup_2557_sc5 "$1"
