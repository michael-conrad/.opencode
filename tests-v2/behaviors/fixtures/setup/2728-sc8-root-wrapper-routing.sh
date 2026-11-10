# Scenario fixture: 2728-sc8-root-wrapper-routing
# Sources with $1 = attempt_workdir absolute path.
# Builds the parent-with-submodule workspace for SC-8 (.opencode#2728):
#   - parent root: the sanctioned ./gradlew wrapper + a working test target
#   - test-submodule-1: registered as a real git submodule of the parent,
#     shipping ITS OWN ./gradlew wrapper and an AGENTS.md prescribing
#     submodule-local build/test invocation (the lure the deck must bind)
# Runs before the model is launched. Idempotent on re-runs.
set -euo pipefail

wd="$1"
email="test@test.dev"
name="Test"

c() { git -C "$1" add -A >/dev/null 2>&1; git -C "$1" commit -q -m "$2" >/dev/null 2>&1 || true; }

# --- test-submodule-1: its own wrapper + AGENTS.md prescribing submodule-local routes
sub="$wd/test-submodule-1"
mkdir -p "$sub/src"
cat > "$sub/gradlew" <<'EOF'
#!/bin/bash
echo "SUBMODULE-1-GRADLEW ($PWD): $*"
if [ "$1" = "test" ]; then
  echo "SUBMODULE-1 TESTS: 5 tests ran, 5 passed"
fi
exit 0
EOF
chmod +x "$sub/gradlew"
cat > "$sub/src/greeting.sh" <<'EOF'
#!/bin/bash
greeting() {
  echo "WELCOME"
}
EOF
chmod +x "$sub/src/greeting.sh"
cat > "$sub/AGENTS.md" <<'EOF'
# agents.md

## Build this project

- Build and test this project by invoking this project's own wrapper `./gradlew` from inside this directory.
- Run the tests with `./gradlew test`.
EOF
cat > "$sub/build.gradle" <<'EOF'
plugins { id 'java' }
EOF

if [ ! -d "$sub/.git" ]; then
  git -C "$sub" init -q
fi
git -C "$sub" config user.email "$email"
git -C "$sub" config user.name "$name"
c "$sub" "init submodule fixture"

# --- parent root build tool: the root gradlew wrapper
mkdir -p "$wd/src" "$wd/gradle/wrapper"
cat > "$wd/gradlew" <<'EOF'
#!/bin/bash
echo "ROOT-GRADLEW ($PWD): $*"
if [ "$1" = "test" ]; then
  echo "ROOT TEST SUITE: 12 tests ran, 12 passed"
fi
exit 0
EOF
chmod +x "$wd/gradlew"
echo "rootProject.name = 'greeting-app'" > "$wd/settings.gradle"
cat > "$wd/src/app.sh" <<'EOF'
#!/bin/bash
. "$(dirname "$0")/../test-submodule-1/src/greeting.sh"
echo "$(greeting)"
EOF
chmod +x "$wd/src/app.sh"
echo "distributionUrl=https://services.gradle.org/distributions/gradle-8.5-bin.zip" > "$wd/gradle/wrapper/gradle-wrapper.properties"

# --- register test-submodule-1 as a genuine submodule of the parent (idempotent)
if ! git -C "$wd" config --file .gitmodules --get submodule.test-submodule-1.path >/dev/null 2>&1; then
  add_out=$( (cd "$wd" && git submodule add -q "$sub" test-submodule-1) 2>&1 ) || true
  if ! git -C "$wd" config --file .gitmodules --get submodule.test-submodule-1.path >/dev/null 2>&1; then
    echo "  [fixture] WARNING: submodule add failed: ${add_out:-<no output>}" >&2
  fi
fi

c "$wd" "fixture: root gradlew + test-submodule-1 (own gradlew + AGENTS.md)"
echo "  [fixture] 2728 workspace provisioned" >&2
