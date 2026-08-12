#!/bin/bash
# Per-scenario fixture for 2272-sc3-shared-status-check-skip.
# Creates a feature branch with the harness-staged .issues/ fixture files,
# wires a bare remote so git-workflow pre-work trunk-tip verification passes,
# provisions the verification-audit upstream artifacts (evidence.yaml,
# reasoning.yaml, verdict.yaml) plus behavioral evidence for the arbiter role,
# and sets ticket #2272 to the ALREADY-CORRECT verified-complete state (labels
# include approved-for-review) so the test exercises the skip-when-already-
# correct branch of the shared status-check discipline.
# Usage: this file is sourced by the harness with $attempt_workdir as $1.

set -euo pipefail

setup_audit_status_skip_fixture() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev"
    git -C "$wd" config user.name "Test"

    # Bare remote so origin/$DEFAULT_BRANCH tracking exists for pre-work.
    local bare_repo="$wd/../origin.git"
    git init --bare -q "$bare_repo"

    # Commit fixture issues on main, then push main to origin.
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: fixture baseline" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare_repo" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch carrying the (already-implemented) plan work.
    git -C "$wd" checkout -q -b feature/2272-audit-status-skip 2>/dev/null || true
    mkdir -p "$wd/src/logging"
    printf '"""Logging module."""\n' > "$wd/src/logging/__init__.py"
    printf 'from logging import get_logger\n' > "$wd/src/app.py"
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: implement all 2 phases of plan #2272" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2272-audit-status-skip 2>/dev/null || true

    # Provision behavioral evidence artifacts for the audit chain.
    local ev_dir="$wd/tmp/behavioral-evidence-fixture"
    mkdir -p "$ev_dir"
    cat > "$ev_dir/manifest.yaml" <<'EVEOF'
scenario_name: 2272-implementation-verification
phase: GREEN
model: fixture-model
timestamp: "2026-08-12T00:00:00Z"
exit_code: 0
harness_version: 1
EVEOF
    printf '0\n' > "$ev_dir/exit_code"
    printf 'All tests pass. SC-1 logging module created at src/logging/__init__.py. SC-2 wired into src/app.py.\n' > "$ev_dir/stdout.log"
    printf 'TEST_HOME=/tmp/fixture-test-home\n' > "$ev_dir/stderr.log"
    cat > "$ev_dir/session.yaml" <<'EVEOF'
source_db: /tmp/fixture-test-home/.local/share/opencode/opencode.db
harness_version: 1
tables:
  event:
    columns: [id, aggregate_id, seq, type, data]
    rows:
      - id: 1
        aggregate_id: session-1
        seq: 1
        type: message.part.updated
        data: '{"text": "Implement SC-1: create src/logging/__init__.py"}'
      - id: 2
        aggregate_id: session-1
        seq: 2
        type: tool.call
        data: '{"tool": "write", "input": {"filePath": "src/logging/__init__.py"}}'
      - id: 3
        aggregate_id: session-1
        seq: 3
        type: message.part.updated
        data: '{"text": "Implement SC-2: wire logging into src/app.py"}'
      - id: 4
        aggregate_id: session-1
        seq: 4
        type: tool.call
        data: '{"tool": "write", "input": {"filePath": "src/app.py"}}'
      - id: 5
        aggregate_id: session-1
        seq: 5
        type: tool.call
        data: '{"tool": "bash", "input": {"command": "uv run pytest test/"}}'
      - id: 6
        aggregate_id: session-1
        seq: 6
        type: message.part.updated
        data: '{"text": "All tests pass. SC-1 and SC-2 verified."}'
EVEOF

    # Provision the verification-audit upstream artifacts so the ARBITER role
    # can run standalone (the scope point where a PASS verdict is produced).
    local audit_dir="$wd/tmp/2272/artifacts/verification-audit"
    mkdir -p "$audit_dir"
    cat > "$audit_dir/evidence.yaml" <<'AUDEOF'
evidence:
  generated_at: "2026-08-12T01:00:00Z"
  spec_issue_number: 2272
  spec:
    local_dir: .issues/2272/
    scs:
      - id: "SC-1"
        criterion: "A src/logging/ module is created with leveled logging functions"
        declared_evidence_type: "behavioral"
      - id: "SC-2"
        criterion: "The logging module is wired into application startup"
        declared_evidence_type: "behavioral"
  evidence_artifacts:
    - path: "tmp/behavioral-evidence-fixture/manifest.yaml"
      category: "manifest"
    - path: "tmp/behavioral-evidence-fixture/session.yaml"
      category: "session"
    - path: "tmp/behavioral-evidence-fixture/stdout.log"
      category: "stdout"
    - path: "tmp/behavioral-evidence-fixture/stderr.log"
      category: "stderr"
    - path: "tmp/behavioral-evidence-fixture/exit_code"
      category: "exit-code"
  sc_evidence_map:
    - sc_id: "SC-1"
      evidence_artifacts: ["tmp/behavioral-evidence-fixture/session.yaml", "tmp/behavioral-evidence-fixture/stdout.log"]
      evidence_status: "present"
    - sc_id: "SC-2"
      evidence_artifacts: ["tmp/behavioral-evidence-fixture/session.yaml", "tmp/behavioral-evidence-fixture/stdout.log"]
      evidence_status: "present"
AUDEOF
    cat > "$audit_dir/reasoning.yaml" <<'AUDEOF'
reasoning:
  generated_at: "2026-08-12T01:01:00Z"
  spec_issue_number: 2272
  sc_validation:
    - sc_id: "SC-1"
      sc_exists_in_spec: true
      criterion_text_matches: true
      declared_evidence_type_matches_spec: true
      evidence_artifacts_exist: true
      evidence_artifacts_readable: true
      evidence_status_valid: true
    - sc_id: "SC-2"
      sc_exists_in_spec: true
      criterion_text_matches: true
      declared_evidence_type_matches_spec: true
      evidence_artifacts_exist: true
      evidence_artifacts_readable: true
      evidence_status_valid: true
  artifact_metadata_validation:
    - filename: "session.yaml"
      path_exists: true
      size_matches: true
    - filename: "stdout.log"
      path_exists: true
      size_matches: true
  spec_metadata_validation:
    spec_issue_number_matches: true
  evidence_type_validation:
    - sc_id: "SC-1"
      spec_declared_type: "behavioral"
      evidence_type_used: "behavioral"
      compliant: true
    - sc_id: "SC-2"
      spec_declared_type: "behavioral"
      evidence_type_used: "behavioral"
      compliant: true
  issues: []
AUDEOF
    cat > "$audit_dir/verdict.yaml" <<'AUDEOF'
verdict:
  generated_at: "2026-08-12T01:02:00Z"
  spec_issue_number: 2272
  summary:
    total_criteria: 2
    pass: 2
    fail: 0
    all_criteria_pass: true
  per_criterion:
    - criterion_id: "SC-1"
      declared_evidence_type: "behavioral"
      result: "PASS"
      evidence: "tmp/behavioral-evidence-fixture/session.yaml"
      explanation: "Behavioral evidence confirms the agent created src/logging/__init__.py with leveled logging functions and the test suite passed."
      remediation: ""
      next_step: "proceed"
    - criterion_id: "SC-2"
      declared_evidence_type: "behavioral"
      result: "PASS"
      evidence: "tmp/behavioral-evidence-fixture/session.yaml"
      explanation: "Behavioral evidence confirms the logging module is wired into src/app.py startup and the test suite passed."
      remediation: ""
      next_step: "proceed"
  remediation_required: false
  self_consistency_downgrades: []
AUDEOF

    # Set ticket #2272 to the ALREADY-CORRECT verified-complete state: labels
    # include the approved-for-review marker so an update is NOT warranted. The
    # arbiter must read the current status and skip the update. Both the flat
    # .issues/2272/ and the .issues/open/2272/ copies are updated so the
    # local-issues CLI sees the already-correct state regardless of which path
    # it resolves.
    local issue_content='title: "[SPEC] Add structured logging to the repository"\nlabels: ["spec", "approved-for-implementation", "approved-for-review"]\nnumber: 2272\nstatus: open\n'
    for issue_yaml in "$wd/.issues/2272/issue.yaml" "$wd/.issues/open/2272/issue.yaml"; do
        if [ -f "$issue_yaml" ]; then
            printf "%b" "$issue_content" > "$issue_yaml"
        fi
    done

    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: fixture audit artifacts and already-correct ticket status" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2272-audit-status-skip 2>/dev/null || true
}

setup_audit_status_skip_fixture "$1"
