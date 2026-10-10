# Remediation evidence — .opencode#2564 SC-2

Verify pass (2026-10-09) found SC-2's conditional re-run unmet. Remediated:

- Re-run: `169-sc4-wiki-edit-gitbucket.sh` (existing remote scenario,
  BEHAVIOR_NEEDS_REMOTE=1, exercises the modified shared provisioning in
  `with-test-home`) on branch commit 0d67db73.
- Result: run completed green — full artifact set at
  `tmp/behavioral-evidence-169-sc4-wiki-edit-gitbucket-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
  (session.yaml, manifest.yaml, exit_code 0), GitBucket provisioned on the
  modified env-scoping path (GB_USER/GB_PASSWORD as harness-owned constants),
  scenario agent completed its task (wiki page published + sidebar, verified
  against live GitBucket HTML).
- Supervision: continuous 60s poll cycle with per-poll chat updates; two
  signal-3 false triggers annotated (discharged with tool completions each
  time; big-blob deliberation pattern, not runaway).

SC-2 evidence condition now met: shared provisioning change did not break
existing remote scenarios.
