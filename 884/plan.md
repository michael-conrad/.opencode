# Plan: #884 — Orphaned opencode-cli run processes from sub-agent dispatch

**Spec:** https://github.com/michael-conrad/.opencode/issues/884
**Constraint:** No `timeout` binary, no process group management, bash tool sole timeout authority

## RED/GREEN Pairs

### Pair 0: Orphans survive timeout/interrupt (SC-1, behavioral)

**RED:** `timeout bash with-test-home env -i opencode-cli run` chain creates 3+ processes. When bash tool kills the script, `timeout` survives in its own PGID. `ps` shows orphaned cluster.
**GREEN:** Synchronous `env -i /bin/sh -c "exec opencode-cli run"` — no intermediate processes. No orphan.

### Pair 1: `--setup` mode for `with-test-home` (SC-5 prep, structural)

**RED:** `--setup` flag does not exist in `with-test-home`. Test home is created inside the timeout chain.
**GREEN:** Add `--setup [workdir]` mode. Creates test home, seeds config, prints `TEST_HOME=<path>`, exits 0.

### Pair 2: Remove `timeout` binary from test harness (SC-2, structural)

**RED:** `helpers.sh` uses `timeout "$BEHAVIOR_TIMEOUT" bash "$BEHAVIOR_TEST_HOME" opencode-cli run` (5 matches).
**GREEN:** Replace with synchronous `env -i /bin/sh -c ". $env_file && exec opencode-cli run"`. No `timeout` binary.

### Pair 3: Remove `bash with-test-home` wrapper (SC-4, structural)

**RED:** `with-test-home` referenced in `behavior_run` retry loop (1 match). Dispatch chain has intermediate bash barrier.
**GREEN:** Call `with-test-home --setup` once before retry loop. Inside loop, direct `env -i` dispatch. No wrapper.

### Pair 4: Process tree depth verification (SC-3, structural)

**RED:** `pstree -p` during behavior_run shows `timeout -> bash -> env -i -> opencode-cli` (4 processes).
**GREEN:** `pstree -p` shows `helpers.sh -> env -i -> opencode-cli` (≤2 processes).

## Implementation Pipeline Checklist

- [ ] 1. sc-coherence-gate
- [ ] 2. pre-red-baseline
- [ ] 3. red-phase (Pairs 0-4)
- [ ] 4. red-doublecheck
- [ ] 5. green-phase (Pairs 0-4)
- [ ] 6. checkpoint-commit
- [ ] 7. structural-checks
- [ ] 8. green-doublecheck
- [ ] 9. green-vbc
- [ ] 10. adversarial-audit
- [ ] 11. cross-validate
- [ ] 12. regression-check
- [ ] 13. review-prep
- [ ] 14. exec-summary

---