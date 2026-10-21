# Session 2026-10-20 (evening, EDT) — Correction Catalog

Scope: the #2639 SC-8 recovery passes 7–9 and their harness fixes (commits `5d4a109d`, `e85ca39b` on `feature/2639-scope-boundary-stacked-pr`).

## LL-1: Editing a behavioral test script while its wrapper is mid-flight corrupts the wrapper's incremental parse

**Classification:** systemic (first recorded instance; the §4 commit→push→fetch→verify cycle provides the natural between-passes window that was bypassed)

**What happened:** During SC-8 recovery pass 8 (wrapper pid 4031929, launched 22:02 EDT), the orchestrator edited the scenario script at ~22:38 to add the `BEHAVIOR_NEEDS_REMOTE` default while the wrapper was still supervising the live container. Bash reads scripts incrementally — when the container finished at ~22:55, the wrapper's file offset landed mid-structure after the 10 inserted lines, and the wrapper died with `syntax error near unexpected token 'fi'` at the OLD line 116. The run agent's work was unharmed (it lives in the session DB), but the wrapper's post-run section (export + manifest) never executed, requiring the §10.5 manual export.

**Root cause:** The commit→push→fetch→verify precondition cycle exists to land harness fixes BETWEEN runs; the edit was applied mid-flight because the fix felt urgent for the NEXT pass. The wrapper process holds no protection against its script changing underneath it — the file offset, not the line content, is what bash resumes from.

**Remediation target:** agent conduct — harness-fix commit+push cycles happen BETWEEN passes, never during a live run; if a fix cannot wait, the run is killed + exported + relaunched rather than edited under. No deck text change required (the §4 cycle already encodes the correct window); recording here so the pattern is searchable.

## LL-2: Recovery launches must re-state the scenario's environment-class flags (`BEHAVIOR_NEEDS_REMOTE`)

**Classification:** systemic (recovery paths silently degrade environment provisioning that the fresh path sets up; the recurring "stored token emptying" observations were this defect misread as gb state loss)

**What happened:** Recovery passes of the SC-8 scenario launched the scenario script with `SC8_RECOVERY_HOME`/`SC8_SKIP_TURN2`/`SC8_DIRECT_RESUME` but WITHOUT `BEHAVIOR_NEEDS_REMOTE=1` (the fresh path gets it from the scenario's own `behavior_run` call, which recovery skips). `with-test-home`'s `seed_gb_config()` keys the stored-token write and `GB_ENV_ARGS` the `GB_TOKEN` env passthrough on that flag — so every resume boot rewrote `$TEST_HOME/.config/gb/config.toml` with an EMPTY token and stripped `GB_TOKEN` from the agent env. The run agent's recorded `gb pr create` was then guaranteed to 401 on both credential surfaces while the same token authenticated host-side. Root cause fixed in `e85ca39b` (recovery block defaults the flag on); pass 9 with the fix created the PR on the first recorded attempt.

**Root cause:** Recovery paths re-invoke `with-test-home` but not the scenario code that establishes environment-class state; flags governing provisioning live at the launch-env layer where they are easy to omit, and `seed_gb_config`'s unconditional `cat > config.toml` turns an omission into an active credential wipe.

**Remediation target:** `e85ca39b` (scenario recovery block). Generalized lesson for scenario authors: any scenario-level env flag that governs with-test-home provisioning must be defaulted by the scenario's own recovery paths, not left to the launcher's memory.

**Consumed:** 2026-10-20 — fixed in commit `e85ca39b` on the #2639 branch; defect documented in the harness-defect filing for this session.

## LL-3: The default resume message drives full state reconstruction — directive messages for recorded-tail completion

**Classification:** systemic (recovery-machinery default interacts with bounded per-turn generation; two full turns of compute lost per occurrence before diagnosis)

**What happened:** Two consecutive SC-8 recovery turns (pass 7) each consumed their entire 4,000-token output cap re-deriving the session's history ("Let me reconstruct what actually happened…") and issued ZERO tool calls, ending `finish: length` — the default resume message ("Continue the task from where you left off.") gives the model no state anchor, so it reconstructs from a ~65k-token context every turn. With `SC8_RESUME_MESSAGE` (fixed in `5d4a109d`) carrying a directive message that states the recorded change and names the recorded remaining action, the next pass (pass 8) immediately executed the recorded command.

**Root cause:** The default message optimizes for generality, not for the recorded-tail case; under the #2646 per-turn output cap, orientation-only turns are pure loss — the cap truncates before any action.

**Remediation target:** `5d4a109d` (`SC8_RESUME_MESSAGE` passthrough on the direct-resume recovery path).

**Consumed:** 2026-10-20 — fixed in commit `5d4a109d` on the #2639 branch.
