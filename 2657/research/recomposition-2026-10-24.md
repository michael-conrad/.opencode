# Re-evaluation and recomposition — .opencode#2657 (2026-10-24)

Trigger: the developer's directive of 2026-10-24 — a spec or plan that needs
more than four revisions to address defects is re-evaluated for proper
decomposition and recomposition (repo boundaries, separation of concerns,
atomic work units, a spec too fat to hold, intent poorly worded or not
reachable), and the revision count is itself an indicator of intent
problems.

## The measurements that fired the trigger

| Artifact | Revisions to reach a zero-finding verdict | Validation dispatches |
|----------|-------------------------------------------|------------------------|
| `2657/spec.md` | 15 | 27 |
| `2657/plan.md` | 6 | 9 (round 9 cancelled before a verdict) |

Both are past the threshold. The loop was not idle: revisions 1–15 changed
requirements, criteria, citations, and the conditionality of a claim. The
question the re-evaluation answers is whether the *artifact's shape* is what
made each round produce a fresh finding.

## Findings

### F1 — one spec, three concerns, three governance surfaces

The spec carried:

1. a **policy** change — the deck's path selection (`floor.md`, the `work`,
   `plan`, `implement`, `verify`, `skill-creator`, `git-workflow-pr`,
   `git-workflow-branch`, `git-workflow-cleanup` cards);
2. a **harness** change — the behavioral measurement apparatus
   (`tests-v2/behaviors/helpers.sh`, `tests-v2/docker/docker-harness.sh`,
   `tests-v2/with-test-home`, `tests-v2/AGENTS.md`, `skills/behavioral-testing/SKILL.md`);
3. a **scenario set** — the behavioral cases for the policy.

Concern 1 is deck content and passes the deck-governance admission gate.
Concern 2 is harness content and passes the harness's own change-control
rules. The spec merged the two gates into one approval, so neither gate could
be exercised on its own terms.

### F2 — the measurement concern was under-specified, so it was absorbed late

Problem 5 described the harness's anchorless cap-hit resume. It did not
describe the harness's *determination gate*, and the gate's defect surfaced
only when the first GREEN run failed: the gate's scan roots were the Docker
tier's staging root and the run's behaviour-test directory, and the
determination record is written to the run's artifact directory — so the gate
refused every cap-hit resume with `determination.yaml not found in any
scenario evidence dir` (`a6029f78`, `170e6814`). Each of those discoveries
forced a spec revision (`R-13` grew twice, `SC-12` grew twice), and each
revision cost a validation round. A spec that carries a dependency it cannot
guarantee is the classic fat-spec failure: the dependency is absorbed into the
spec instead of being declared.

### F3 — verbosity is where the findings clustered, and it defeats the duty-of-care pass

Round 26's two findings were mechanical: a citation that pointed at the wrong
section, and a requirement that asserted a conditional as an invariant. Round
27's residual was an ordering ambiguity in a behavioral criterion. All three
sat in the two longest requirements — `R-3` (a single sentence of several
hundred words carrying six criteria and three exception clauses) and `R-13`
(three unrelated harness changes in one requirement). The spec card's
duty-of-care pass asks the writer to spend the fresh-context dispatch on
judgment-level defects; an 853-line, 13-requirement artifact cannot be held
in one context, so mechanical defects leak into review and each leak costs a
full round. The artifact's size was the mechanism of the loop.

### F4 — two claims in the branch assert behavior the code does not implement

Neither was caught by 27 validation rounds, because those rounds checked the
spec's internal consistency, not the spec-to-code correspondence.

- `tests-v2/with-test-home`'s `__sc8_determination_gate` carries a comment
  stating that the gate "permits the resume when the target home's own
  session record shows the last assistant turn ended with finish=length".
  The function contains no such check: it scans for a determination record,
  permits `progressing-directionally` / `off-track`, otherwise requires a
  valid recorded orchestrator decision, and otherwise exits `FATAL`. The
  word `finish` appears in the file only in that comment.
- `tests-v2/AGENTS.md` §10.7 row 6 states that an unmonitored run's
  determination record "carries the run's exit code and a recorded
  orchestrator decision", so the resumption path passes the gate. The record
  is flag-gated: `__write_determination_record` runs only under
  `BEHAVIOR_SEMANTIC_MONITOR=1`, so an unmonitored run writes no record at
  all.

The consequence is concrete: a cap-hit run whose monitor classification is
`undetermined` and whose poll log carries no `MONITOR-HALTED` marker has a
record that the gate finds (after the scan-root fix) and still blocks on.
The observed failure — three consecutive `FATAL: resume failed — no
non-undetermined determination exists`, no inference dispatched, the run's
artifact never produced — is only *partly* addressed by the scan-root fix.

### F5 — the intent statement names two intents and omits a third

The title is "Path selection honors a stated stage request; the short path is
bounded, recorded, and coherent" — two intents joined by a semicolon. The
third concern (the harness's measurability) is in the body and in the blast
radius, and nowhere in the intent statement. The intent is reachable; the
statement is incomplete.

## Decomposition decision

Two inter-dependent specs, one concern each.

| Spec | Concern | Governance | Depends on |
|------|---------|------------|------------|
| **M** (new issue) | The behavioral harness can complete and judge a capped run: a tail-anchored resume, a gate that finds its record and permits the cap-hit resume, documentation that states the gate truthfully | the harness's own change-control rules | nothing |
| **P** (`#2657`) | The deck's path selection: a stated stage request runs its stage; the short path is bounded, recorded, and coherent with the verify and PR gates | the deck-governance admission gate | M, for its behavioral criteria |

M is a prerequisite for P's evidence: P's behavioral criteria are judged from
runs that only complete if the harness can resume and judge them. P now states
that dependency; it no longer absorbs the harness's internals.

### Considered and rejected

- **Splitting P further** into "stage-request routing" and "short-path
  bounding". Both concerns edit rule 1 of `skills/work/SKILL.md` and share the
  criteria set — the "request names no stage" criterion is routing's rule and
  bounding's first criterion. The split would require authoring an
  intermediate card state (old card plus routing rules) that is itself an
  artifact to validate, adding a failure surface without adding separability.
- **Keeping one spec with a measurement section.** That is the shape that
  produced F1–F5.
- **Carrying the deck's own revision-budget rule in this spec.** It is a
  different concern and a different consumer; it is its own item.

## Recomposition — how P is re-cut

Twelve requirements become nine, each a few sentences, with the exception
clauses that caused F3 moved to the requirement they qualify or to the
out-of-scope list.

| New | Old | Content |
|-----|-----|---------|
| R-1 | R-1, R-2, R-7 | A stated stage request runs its stage; a request for a stage is not a specification; a directive satisfies a stage's content and never suppresses a stage |
| R-2 | R-3 | The short path's criteria, stated once, assessed before implementation begins; a failed or uncertain criterion sends the change to the full path; the developer-directed deck edit with a material open choice is excepted and takes the short path |
| R-3 | R-4, R-10, R-11 | The work record and the scope statement: one file, two parts, a named path, a write time per part; the scope statement discharges the spec and plan stages |
| R-4 | R-5 | The short path ends when the work outgrows it |
| R-5 | R-8 | The deck-governance carve-out is bounded |
| R-6 | R-6 | No ceremony, and no waived stage; the stage-pricing text leaves the deck |
| R-7 | R-10 (rest) | One definition of "short path"; the routing cards point at it, the consuming cards name the artifact; every record reference names the work record |
| R-8 | R-12 | The verify and PR-readiness gates read the scope statement |
| R-9 | R-9 | The scenario set is aligned |
| R-10 | (R-9's scenario set, split out) | The scenario set is aligned, with each scenario's goal condition discriminating |

R-13 and SC-12 leave P and become M's requirements and criteria. P's
behavioural criteria keep their substance; SC-9's ordering ambiguity (round
27) is re-scoped so that each observable in the run has one stated position
relative to the next.

## What M still owes

M is not a documentation exercise; two items are open code work:

- the gate must permit the cap-hit resume (the exemption `with-test-home`'s
  comment already describes and the function does not implement), keyed on the
  home's own session record's last assistant finish reason — the same signal
  `__last_assistant_finish` already reads in `helpers.sh`;
- `tests-v2/AGENTS.md` §10.7 row 6 must state the unmonitored path truthfully
  (no record is written, so the resumption path still blocks, and §10.5's
  full re-run fallback remains the recovery).

Both are stated in M's criteria with an executable instrument, so that the
correspondence between the spec and the code is checked rather than asserted.

## The threshold, crossed twice

The developer's rule fired on this artifact and on the extracted harness spec
(`.opencode#2663`), and the second crossing is recorded here because the
first crossing's remedy is what made the second one visible.

**First crossing — `#2657` at 15 spec revisions and 6 plan revisions.** The
re-evaluation above is its remedy: the measurement concern became a separate
spec, the policy spec's requirements were re-cut from twelve to ten, each
short, and the measurement surface left the policy spec entirely.

**Second crossing — `.opencode#2663` at five revisions.** Its re-evaluation:
repo boundaries (one repository; the harness's change-control rules and one
deck card's admission gate are different gates, but the card's single clause
states the harness's rule and splitting it would strand it from its subject);
separation of concerns (two defects, one path, five atomic requirements, one
intent — the harness can complete and judge a capped run); atomicity (each
requirement is one deliverable with a binary instrument); fatness (the spec
is 329 lines with six criteria, down from 383 — not fat); intent reachability
(the criteria are executable, and two of them were executed and pass).
**Conclusion: no further decomposition.** The revisions were not a structural
confusion: each was a claim about the code that the code did not support, and
each was caught by a reviewer executing the criterion's instrument against the
code rather than reading the spec.

**What the loop produced, and what caught it.** Two of the harness spec's
revisions were corrections of *the branch's own* first commit: that commit
narrowed the gate's rule in `skills/behavioral-testing/SKILL.md` to one of
its two branches, described the unmonitored path as recoverable by a route it
does not have, and left a comment in `tests-v2/with-test-home` claiming an
exemption the code does not implement. The performative loop introduced false
claims into the deck's own documentation, and the fresh-context review caught
them only because the criteria carry *executable* instruments — a gate
replayed against a preserved run, a scanned-roots list read out of the gate's
own error message. A criteria set that could only be checked by reading would
have passed all of it.

**The durable consequence**, carried into the separate deck item: every
criterion about behavior needs an instrument that can fail, and every claim a
spec makes about code must be checked against the code — never against the
deck's documentation, which is where the drift starts.
