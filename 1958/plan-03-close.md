# Phase 3 — Close and Inform

**Goal:** Close #1953 as superseded, comment on #1925 and #1926 with canonical format reference.

**Concern:** Closure
**SCs:** SC-8, SC-9
**Dependencies:** Phase 2 complete

## Steps

### 3.1 Close #1953 as superseded

- [ ] Read all comments on #1953
- [ ] Add comment: "Closed as superseded by #1958 — the canonical cross-reference format is `Load [descriptive text](relative/path.md)`. See #1958 for the full rollout."
- [ ] Close #1953 with `state_reason: not_planned`
- [ ] SC-8: Verify #1953 state is `closed` with `state_reason: not_planned`

### 3.2 Comment on #1925

- [ ] Read all comments on #1925
- [ ] Add comment: "The canonical cross-reference format is now `Load [descriptive text](relative/path.md)`. See #1958 for the full rollout. Linting rules should enforce this format."
- [ ] SC-9: Verify comment exists on #1925

### 3.3 Comment on #1926

- [ ] Read all comments on #1926
- [ ] Add comment: "The canonical cross-reference format is now `Load [descriptive text](relative/path.md)`. See #1958 for the full rollout. Behavioral tests should verify this pattern."
- [ ] SC-9: Verify comment exists on #1926

## Exit Criteria

- [ ] #1953 closed as superseded
- [ ] #1925 has comment linking to this spec
- [ ] #1926 has comment linking to this spec
