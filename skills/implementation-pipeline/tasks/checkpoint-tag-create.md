# Task: checkpoint-tag-create

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Create a checkpoint git tag after a pipeline step completes successfully. The tag enables rollback to the last known-good state per `000-critical-rules.md` §Checkpoint Rollback Exception.

## Context Required

- `issue_number`
- `github.repo`
- `worktree.path` (if applicable)
- `pipeline_phase` — current step label (e.g., `green-phase`)

## Execution

- [ ] 1. Determine the step number N from the pipeline dispatch table (1-indexed)
- [ ] 2. Determine submodule suffix: if working in a submodule, use the submodule directory name from `.gitmodules` (e.g., `.opencode` → `-opencode`); otherwise empty string
- [ ] 3. Reap any prior tag for this step (re-dispatch from prior failure):
       `git tag -d "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || true`
       `git push origin --delete "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || true`
- [ ] 4. Commit current state and tag checkpoint:
       `git add -A`
       `git commit -m "checkpoint(#$ISSUE_NUM): step-$N complete"`
       `git tag "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX"`
       `git push origin "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || echo "Remote push skipped"`
- [ ] 5. Write YAML artifact at `./tmp/{issue-N}/artifacts/pipeline-checkpoint-tag-create-{STATUS}-{timestamp}.yaml` with status PASS/FAIL

## Return

- `status`: DONE | BLOCKED
- `artifact_path`: path to YAML artifact
- `summary`: "Checkpoint tag created for step N" or failure reason
