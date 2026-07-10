# Plan: #1789 — VbC verify task procedural gap

## Sequencing

**Must be implemented BEFORE #675.** #1789 adds the behavioral-test-evaluation dispatch step; #675 adds infrastructure references within that step.

## RED Phase — Behavioral Tests

### Behavioral Test 1: `1789-sc4-behavioral-evaluation-dispatch.sh`

**SC target:** SC-4 (agent dispatches `behavioral-test-evaluation`, not file-existence check)

**Prompt (real-domain):**
```
The VbC verify task has completed Step 1 (Query Success Criteria). SC-3 is declared as evidence type `behavioral`. The artifacts directory at ./tmp/issue-1789/artifacts/ contains behavioral-evidence-*.log files. Proceed with Step 2 (Check for Evidence).
```

**Expected RED behavior:** Agent checks artifacts directory for SC-3 (file-existence check) — does NOT dispatch `behavioral-test-evaluation`. Test FAILS because the procedural step doesn't exist yet.

**Assertions (GREEN):** `assert_stderr_pattern_present 'behavioral-test-evaluation'` — agent dispatches the evaluation task.

### Behavioral Test 2: `1789-sc5-no-artifact-generated-pass.sh`

**SC target:** SC-5 (agent does NOT report PASS based on artifact file existence alone)

**Prompt (real-domain):**
```
The behavioral test artifacts are ready at ./tmp/behavioral-evidence-1789-sc4-GREEN-default/. Verify SC-4 from the VbC verify task spec.
```

**Expected RED behavior:** Agent reports "artifact generated" or file-existence as PASS for behavioral SC. Test FAILS because the mandatory gate doesn't exist yet.

**Assertions (GREEN):** `assert_stderr_pattern_absent 'artifact generated'` — agent does NOT accept artifact existence as PASS; dispatches clean-room evaluation.

## GREEN Phase — Implementation Steps

### File 1: `skills/verification-before-completion/tasks/verify.md`

#### Change 1.1 — Split Step 2 into evidence-type-aware substeps

**Anchor:** Lines 126-130 (current `### 2. Check for Evidence` block)

**Insertion point:** Replace the current Step 2 block with a branched version:

```
### 2. Check for Evidence

- [ ] 2a. **Classify each SC by evidence type** — read the spec's evidence type column for each SC
- [ ] 2b. **For behavioral SCs:** dispatch `behavioral-test-evaluation` via `task(subagent_type="general", prompt: "execute behavioral-test-evaluation task from verification-before-completion")` with `{ artifact_dir, sc_list }` context. Do NOT check the artifacts directory directly — behavioral SCs require clean-room evaluation, not file-existence checks.
- [ ] 2c. **For non-behavioral SCs (structural/string/semantic):** check `{project_root}/tmp/{issue-N}/artifacts/` for verification artifacts matching each SC's evidence type
- [ ] 2d. **Verify evidence matches criteria** — confirm each artifact satisfies the SC's verification method
```

**Preservation:** Lines 170-220 (Evidence Types section, prohibitions) and lines 320-350 (Per-SC Evidence Table, Behavioral SC Enforcement) remain untouched.

#### Change 1.2 — Add mandatory gate note after Step 2

**Anchor:** After the new Step 2 block, before `### 2a. Todowrite Cleanup Verification` (line 132)

**Insertion point:** Add a mandatory gate paragraph:

```
**🚫 MANDATORY GATE:** For any SC with evidence type `behavioral`, `behavioral-test-evaluation` MUST be dispatched before PASS can be claimed. "Artifact generated" is NEVER a valid PASS verdict for behavioral SCs — only clean-room evaluation counts. Skipping this dispatch for a behavioral SC is a CRITICAL VIOLATION.
```

### File 2: `skills/verification-before-completion/SKILL.md`

#### Change 2.1 — Update Operating Protocol reference

**Anchor:** Line 68 (`See \`verification-before-completion/tasks/operating-protocol.md\` for the full operating protocol`)

**Change:** Append a sentence referencing verify.md's mandatory gate:

```
See `verification-before-completion/tasks/operating-protocol.md` for the full operating protocol and authorization context. The behavioral-test-evaluation dispatch is a mandatory gate in `verify.md` Step 2 — see `verification-before-completion/tasks/verify.md` §2b for the procedural requirement.
```

### File 3: `skills/verification-before-completion/tasks/operating-protocol.md`

#### Change 3.1 — Update §7 cross-reference

**Anchor:** Line 16 (current §7: "Behavioral test evaluation: After behavior_run produces artifacts, the orchestrator MUST dispatch behavioral-test-evaluation...")

**Change:** Append a cross-reference to verify.md:

```
- [ ] 7. **Behavioral test evaluation:** After `behavior_run` produces artifacts, the orchestrator MUST dispatch `behavioral-test-evaluation` to evaluate artifacts via clean-room sub-agents. "Artifact generated" is NOT a valid PASS verdict for behavioral SCs. **This step is procedurally enforced in `verify.md` Step 2b — the verify task's evidence-type branching gate is the canonical source for this requirement.**
```

## Post-GREEN Verification

| SC | Verification Method | Expected Result |
|----|-------------------|-----------------|
| SC-1 (string) | `grep` for evidence type check + behavioral-test-evaluation dispatch in Step 2 | Step 2 branches on evidence type; behavioral SCs dispatch behavioral-test-evaluation |
| SC-2 (string) | `grep` for mandatory gate text referencing behavioral-test-evaluation dispatch | Mandatory gate paragraph present after Step 2 |
| SC-3 (string) | `grep` for cross-reference in operating-protocol.md | operating-protocol.md §7 references verify.md Step 2b |
| SC-4 (behavioral) | Run `1789-sc4-behavioral-evaluation-dispatch.sh` → clean-room evaluation | stderr shows `behavioral-test-evaluation` dispatch |
| SC-5 (behavioral) | Run `1789-sc5-no-artifact-generated-pass.sh` → clean-room evaluation | stderr shows clean-room evaluation dispatch, NOT file-existence check |
