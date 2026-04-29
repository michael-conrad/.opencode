# Task: completion

## Purpose

Ensure the research workflow documents its results and produces a status report regardless of outcome. This task is the completion guarantee for research — it runs whenever the workflow halts, whether successful, partial, inconclusive, or in error.

## Entry Criteria

The research workflow is halting. This includes:
- Successful discovery with findings
- Partial results where some modalities were unavailable
- Inconclusive research where no definitive answer was found
- An error that prevented research from completing

## Exit Criteria

- Research results documented
- Status report produced in chat
- No orphaned state remains (temporary files cleaned, cache valid)
- Byline present as last element of chat output

## Procedure

### Step 1: Document Results

Compile a status report summarizing all research operations:

```
Research Status: <completed | partial | inconclusive | failed>
Findings: <summary of key findings>
Modalities Used: <list of modalities that produced results>
Models Used: <list of models invoked>
Unverified Modalities: <list of modalities with no available model>
Gaps: <list of knowledge gaps that research could not resolve>
```

Status determination:
- `completed`: All research questions answered with evidence
- `partial`: Some questions answered, others had insufficient evidence
- `inconclusive`: No definitive answer found despite exhaustive search
- `failed`: Research process encountered errors that prevented completion

### Step 2: Clean Up

- Clear any temporary research state in `./tmp/` (never `/tmp/`)
- Ensure multimodal-dispatch cache is left in valid state
- Document any gaps in modality coverage in the report

### Step 3: Evidence Attribution

For each finding, attribute the source:

| Finding Source | Attribution Format |
|---------------|-------------------|
| Live tool call | `Tool: <tool_name>(<params>) → <result_excerpt>` |
| Web search | `Source: <URL> → <relevant_excerpt>` |
| Code inspection | `File: <path>:<line> → <finding>` |
| Model inference | `Model: <model_id> → <reasoning>` |

Unattributed findings MUST be marked as `[UNVERIFIED]` in the report.

### Step 4: Report

Produce the status report in chat output.

Follow the completion-core reference for:
- Push branch (if applicable, idempotent)
- Generate URL (if applicable)
- Report executive summary in chat

### Step 5: Gap Escalation

If research gaps remain that could impact implementation decisions:

- List each gap explicitly
- Classify severity: blocker (stops implementation) or advisory (implementation can proceed with caution)
- Recommend specific verification actions if the gap is advisory

## Report Format

```
**Summary:**

<1-2 sentences describing research outcome>

**Outcome:** <What was learned or why research was inconclusive>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

## Key Principles

### Evidence Attribution Is Mandatory

Every finding must be attributed to its source. Unattributed findings are treated as unverified claims — they MUST be marked `[UNVERIFIED]` in the report. This is not optional and applies regardless of how "obvious" or "well-known" the finding seems. The attribution format varies by source type (tool call, web search, code inspection, model inference) and must be preserved in the report.

### Gap Escalation Prevents Downstream Failures

Unresolved research gaps that could impact implementation decisions must be escalated explicitly. A gap classified as "blocker" means the implementation should not proceed without resolving the gap. A gap classified as "advisory" means the implementation can proceed but with caution and specific verification steps. The completion task ensures gaps are not silently dropped from the research output.

### Idempotent Completion

The completion task is idempotent — it can be invoked multiple times without side effects. If the research workflow halts at multiple points, each halt can safely invoke completion. The status report reflects the state at the time of invocation. Temporary file cleanup runs each time but targets files that no longer exist (no-op) or exist and need removal (correct removal).

### Report Before Halt

The research workflow MUST NOT halt without producing a status message. This is a critical violation per `000-critical-rules.md` §Silent Agent Termination. The completion task is the mechanism that guarantees this — it produces the status report before any HALT.

## Result Contract

```yaml
status: DONE | PARTIAL | INCONCLUSIVE | FAILED
task: completion
findings_count: <int>
gaps_count: <int>
modalities_used: [<str>, ...]
unverified_modalities: [<str>, ...]
evidence_artifacts: [<ref>, ...]
```