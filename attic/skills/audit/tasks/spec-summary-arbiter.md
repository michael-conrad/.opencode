
# Task: spec-summary-arbiter

## Purpose

Produce the final spec-summary result contract with resolution paths and recommendations based on the Evaluator's verdict. Reads `verdict.yaml` (Evaluator) and produces the final result contract.

## Entry Criteria

- `verdict.yaml` exists at `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`
- Evaluator verdict contains per-criterion PASS/FAIL results

## Exit Criteria

- Final YAML verdict artifact written to `{project_root}/tmp/{issue-N}/artifacts/`
- Frugal result contract returned with `status`, `artifact_path`, `summary`, `remediation_required`

## Role: Arbiter

You are the Arbiter. You read the Evaluator's verdict and provide resolution paths. You produce the final result contract for the orchestrator.

## Procedure

- [ ] 1. **Read Verdict** — Read `verdict.yaml` from `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`.

- [ ] 2. **Classify Mismatches** —

    | Mismatch Type | Classification |
    |--------------|----------------|
    | TITLE_MISMATCH | PR title does not match spec title |
    | CRITERIA_MISSING | Success criteria must be documented |
    | FILES_MISSMATCH | Extra/missing files need explanation |
    | SCOPE_EXPANSION | PR exceeds spec scope |
    | SCOPE_INCOMPLETE | PR doesn't address full spec |
    | LINK_MISSING | Should reference spec issue |
    | CLOSING_MISSING | PR won't auto-close spec issue — must use Fixes/Closes/Resolves/Implements with valid format |
    | CLOSING_BARE_HASH | PR uses bare `#N` without keyword — must prefix with Fixes/Closes/Resolves/Implements |
    | CLOSING_CROSS_REPO | PR uses bare `#N` for cross-repo reference — must use `owner/repo#N` format |

- [ ] 3. **Generate Recommendations** — For each FAIL criterion, provide a resolution path.

- [ ] 4. **Write Final Artifact** — Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-summary-{STATUS}-{timestamp}.yaml`.

- [ ] 5. **Return Frugal Result Contract** —

    ```yaml
    status: DONE | FAIL
    artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-summary-PASS-{timestamp}.yaml"
    summary: "PR/Spec consistency: {match_percentage}% matched. Verdict: {overall}."
    remediation_required: true
    ```
