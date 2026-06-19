# Implementation Plan — [`.opencode#1295`](https://github.com/michael-conrad/.opencode/issues/1295) — local-issues PEP 723 header

- [ ] **Goal:** Fix `local-issues` PEP 723 header from deprecated `# /// pyproject.toml` to `# /// script`, update `070-environment.md` with canonical reference and version pinning standards, expand `test-pep723-tools.sh` with lint checks for PEP 723 compliance.
- [ ] **Architecture:** Phase 1 → Phase 2 (docs) and Phase 3 (tests). Phases 2 and 3 require Phase 1 complete; they are independent of each other.
- [ ] **Files:**
  - `.opencode/tools/local-issues` — Phase 1
  - `.opencode/guidelines/070-environment.md` — Phase 2
  - `.opencode/tests/test-pep723-tools.sh` — Phase 3

---

## Phase 1 — Fix local-issues

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5
**File:** `.opencode/tools/local-issues`

- [ ] 1. **Coherence gate.**
  - Verify SC-1 through SC-5 are internally consistent and match codebase.
  - Dispatches: `sc-coherence-gate` for phase 1.
- [ ] 2. **Pre-RED baseline.**
  - Capture current state of `.opencode/tools/local-issues` lines 1-12.
  - Record exit code of `./.opencode/tools/local-issues init`.

### RED+green P1-I1 — Replace header

- [ ] 3. **RED.**
  - Write test grepping for `# /// pyproject.toml` and `# [project]` — expects them to exist.
  - Must FAIL.
- [ ] 4. **RED doublecheck.**
  - Confirm Step 3 fails as expected.
- [ ] 5. **Post-RED enforcement.**
  - Verify RED artifacts exist with correct FAIL state.
- [ ] 6. **GREEN.**
  - `# /// pyproject.toml` → `# /// script`
  - Remove `[project]` wrapping
  - `requires-python = "~=3.12.0"`
  - `dependencies = ["pyyaml~=6.0"]`
  - Add bash guard before PEP 723 header
  - Remove `[tool.ruff]` from metadata
  - **SC-2, SC-3, SC-4, SC-5**
- [ ] 7. **Post-GREEN enforcement.**
  - Verify header uses `# /// script` not `# /// pyproject.toml`.
- [ ] 8. **Structural checks.**
  - `ruff check --diff` on `.opencode/tools/`.
- [ ] 9. **GREEN doublecheck.**
  - `# /// pyproject.toml` absent → SC-2
  - `# [project]` absent → SC-3
  - `requires-python = "~=3.12.0"` present → SC-4
  - `pyyaml~=6.0` present → SC-5
- [ ] 10. **Checkpoint commit.**
  - `git commit -m "fix local-issues PEP 723 header"`

### RED+green P1-I2 — Verify init

- [ ] 11. **RED.**
  - Write test running `./.opencode/tools/local-issues init` — expects exit 0.
  - Must FAIL (non-zero exit).
- [ ] 12. **RED doublecheck.**
  - Confirm test fails.
- [ ] 13. **Post-RED enforcement.**
  - Verify RED artifacts with FAIL state.
- [ ] 14. **GREEN.**
  - Ensure `init` exits 0 with corrected header.
  - **SC-1**
- [ ] 15. **Post-GREEN enforcement.**
  - Verify `init` now works.
- [ ] 16. **Structural checks.**
  - `ruff check --diff`.
- [ ] 17. **GREEN doublecheck.**
  - Run `init` — confirm exit 0 → SC-1
- [ ] 18. **Checkpoint commit.**
  - `git commit -m "fix local-issues init"`

### Phase 1 completion

- [ ] 19. **VbC.**
  - SC-1: `init` exits 0
  - SC-2: `# /// script` present, `# /// pyproject.toml` absent
  - SC-3: `# [project]` absent
  - SC-4: `requires-python = "~=3.12.0"` present
  - SC-5: `pyyaml~=6.0` present
- [ ] 20. **Adversarial audit.**
  - resolve-models → auditor_1 → remediate → auditor_2 → cross-validate.
- [ ] 21. **Cross-validate.**
  - Both PASS or DISAGREE with remediation.
- [ ] 22. **Regression check.**
  - `bash .opencode/tests/test-enforcement.sh --changed` — must pass.
- [ ] 23. **Review prep.**
  - `git-workflow review-prep`.

---

## Phase 2 — Update 070-environment.md

**SCs:** SC-6, SC-7
**File:** `.opencode/guidelines/070-environment.md`

- [ ] 24. **Coherence gate.**
  - Verify SC-6, SC-7 consistent with codebase.
- [ ] 25. **Pre-RED baseline.**
  - Capture current PEP 723 section in `070-environment.md`.
  - Note: missing PEP 723 URL, wrong marker, no pinning standards.

### RED+green P2-I1 — Update docs

- [ ] 26. **RED.**
  - Write test grepping for `peps.python.org/pep-0723` — expects present.
  - Must FAIL.
- [ ] 27. **RED doublecheck.**
  - Confirm Step 26 fails.
- [ ] 28. **Post-RED enforcement.**
  - Verify FAIL artifacts.
- [ ] 29. **GREEN.**
  - Add `https://peps.python.org/pep-0723/` reference link → SC-6
  - Specify `# /// script` as only standardized marker
  - Add `~=` pinning standards for `requires-python` and `dependencies` → SC-7
  - Update example block
- [ ] 30. **Post-GREEN enforcement.**
  - Verify file modified.
- [ ] 31. **Structural checks.**
  - `pymarkdownlnt` scan on modified file.
- [ ] 32. **GREEN doublecheck.**
  - `peps.python.org/pep-0723` present → SC-6
  - `~=` present in pinning prose for both fields → SC-7
- [ ] 33. **Checkpoint commit.**
  - `git commit -m "update PEP 723 documentation"`

### Phase 2 completion

- [ ] 34. **VbC.**
  - SC-6, SC-7 pass.
- [ ] 35. **Adversarial audit.**
  - resolve-models → 2 auditors.
- [ ] 36. **Cross-validate.**
  - Consensus.
- [ ] 37. **Regression check.**
  - Enforcement tests — no regressions.
- [ ] 38. **Review prep.**
  - `git-workflow review-prep`.

---

## Phase 3 — Expand test-pep723-tools.sh linting

**SCs:** SC-8, SC-9, SC-10, SC-11
**File:** `.opencode/tests/test-pep723-tools.sh`

- [ ] 39. **Coherence gate.**
  - Verify SC-8 through SC-11 consistent with codebase.
- [ ] 40. **Pre-RED baseline.**
  - Capture current `test-pep723-tools.sh`.
  - Note: missing `check_requires_python_pinned` and `check_dependencies_pinned`.

### RED+green P3-I1 — Add check_requires_python_pinned

- [ ] 41. **RED.**
  - Write test grepping for `check_requires_python_pinned` — expects present.
  - Must FAIL.
- [ ] 42. **RED doublecheck.**
  - Confirm fails.
- [ ] 43. **Post-RED enforcement.**
  - Verify FAIL artifacts.
- [ ] 44. **GREEN.**
  - Add `check_requires_python_pinned`: greps `requires-python = "~=X.Y.0"` in PEP 723 scripts, exits non-zero on violation.
  - **SC-8**
- [ ] 45. **Post-GREEN enforcement.**
  - Verify function added.
- [ ] 46. **Structural checks.**
  - `bash -n` syntax check.
- [ ] 47. **GREEN doublecheck.**
  - `check_requires_python_pinned` present via grep → SC-8
- [ ] 48. **Checkpoint commit.**
  - `git commit -m "add check_requires_python_pinned"`

### RED+green P3-I2 — Add check_dependencies_pinned

- [ ] 49. **RED.**
  - Write test grepping for `check_dependencies_pinned` — expects present.
  - Must FAIL.
- [ ] 50. **RED doublecheck.**
  - Confirm fails.
- [ ] 51. **Post-RED enforcement.**
  - Verify FAIL artifacts.
- [ ] 52. **GREEN.**
  - Add `check_dependencies_pinned`: greps `~=` in dependency entries of PEP 723 scripts, exits non-zero on violation.
  - **SC-9**
- [ ] 53. **Post-GREEN enforcement.**
  - Verify function added.
- [ ] 54. **Structural checks.**
  - `bash -n`.
- [ ] 55. **GREEN doublecheck.**
  - `check_dependencies_pinned` present via grep → SC-9
- [ ] 56. **Checkpoint commit.**
  - `git commit -m "add check_dependencies_pinned"`

### RED+green P3-I3 — Clean repo pass

- [ ] 57. **RED.**
  - Run `./.opencode/tests/test-pep723-tools.sh` — expect non-zero exit.
- [ ] 58. **RED doublecheck.**
  - Confirm non-zero exit.
- [ ] 59. **Post-RED enforcement.**
  - Verify FAIL artifacts.
- [ ] 60. **GREEN.**
  - Ensure test script exits 0 on clean post-fix repo.
  - **SC-10**
- [ ] 61. **Post-GREEN enforcement.**
  - Verify script passes.
- [ ] 62. **Structural checks.**
  - `bash -n`.
- [ ] 63. **GREEN doublecheck.**
  - Run script — exit 0 → SC-10
  - `# /// pyproject.toml` absent from `.opencode/tools/` → SC-11
- [ ] 64. **Checkpoint commit.**
  - `git commit -m "fix test script for clean repo"`

### Phase 3 completion

- [ ] 65. **VbC.**
  - SC-8 through SC-11 pass.
- [ ] 66. **Adversarial audit.**
  - resolve-models → 2 auditors.
- [ ] 67. **Cross-validate.**
  - Consensus.
- [ ] 68. **Regression check.**
  - `bash .opencode/tests/test-enforcement.sh --changed` — pass.
- [ ] 69. **Review prep.**
  - `git-workflow review-prep`.

---

## Exit Criteria

- [ ] C1: All 11 SCs pass (SC-1 through SC-11)
- [ ] C2: All phases complete in order (1 → 2 → 3)
- [ ] C3: No regressions in existing enforcement tests
- [ ] C4: Review prep completed for all phases
- [ ] C5: Plan stored at `.opencode/.issues/1295/plan.md`
