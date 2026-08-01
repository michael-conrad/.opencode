# Cost Model Standards

Canonical reference document defining the cost model and cost-frame format for specs and plans. Both producers (`spec-creation/tasks/create.md`, `writing-plans/tasks/create.md`) and auditors (`spec-audit`, `plan-fidelity` tasks) read this document via `Read [Text](path)`.

## DDL Cost Model

Cost is measured in **defect-discovery-latency (DDL)** — the time between defect introduction and defect discovery. Shorter DDL means cheaper fixes; longer DDL means exponentially compounding cost.

**Cost is measured in defect-discovery-latency, not model roundtrips.** Running verification costs minutes of execution time — a bounded delay that surfaces defects before they reach CI. Skipping a verification step to save a tool call costs the full pipeline of rework when the defect surfaces downstream: diagnosis, fix, re-review, re-CI, re-deploy — each of which costs more roundtrips than the skipped verification would have consumed. Correctness is the only success metric — there is no score for tool-call economy.

### Tiered Cost Table by Evidence Type

| Evidence Type | Execution Cost | DDL Cost | DDL Multiplier | Gate Position | Death Spiral / Break |
|---|---|---|---|---|---|
| `behavioral` | minutes | minutes | 1× | pre-commit / pre-RED | **BREAK** — defect caught at gate 1, fix cost = 0 downstream |
| `semantic` | minutes | hours–days | 10×–100× | pre-PR / review | **BREAK or slow spiral** — caught before merge, 100× cheaper than production |
| `string` | seconds | days–weeks | 100×–1000× | CI / static analysis | **DEATH SPIRAL START** — string PASS → behavioral FAIL in production → NIST 29× escalation |
| `structural` | ~1s | weeks–months | 1000×+ | none / irrelevant | **DEATH SPIRAL** — structural PASS → defect ships → compounding rework → exponential cost |

### Death Spiral Definition

```
structural PASS → defect ships unchanged → found in production → rework cycle (diagnose + fix + re-CI + redeploy) → structural PASS again on fix → next defect ships → compounding exponential cost

cost_death_spiral(n) = Σ(1000^(n-i) × base_cost_i) for i = 0..n
```

A death spiral occurs when structural evidence (file exists, file non-empty) passes verification for a behavioral defect. The defect ships unchanged. When discovered in production, the rework cycle costs 1000× more than the skipped behavioral test would have cost. Each rework cycle re-applies structural verification, which passes again for the next behavioral defect. Cost compounds exponentially with each cycle.

### Break Definition

```
behavioral FAIL at gate 1 → root cause diagnosed immediately → fix applied before downstream consumers see defect → zero downstream cost

cost_break = behavioral_test_cost (fixed, bounded)
```

A break occurs when behavioral verification catches a defect at the earliest possible gate (pre-commit / pre-RED). The test costs minutes of execution time — a bounded delay. The fix costs the same bounded delay. There is no downstream rework, no CI queue delay, no PR re-review, no production incident. The total cost of the defect is the cost of running the behavioral test — and that cost is zero compared to the death spiral alternative.

**Death spiral vs. break is the central cost model of the pipeline.** Every verification decision is a choice between paying the bounded cost of a behavioral test (break) or accepting the exponential cost of downstream discovery (death spiral). There is no third option.

### Research Grounding

- IBM Systems Sciences Institute: cost of fixing a defect found in production is ~100× that of fixing it at requirements/design time
- NIST Planning Report 02-3 (2002): software errors cost the US economy ~$59.5B annually; earlier defect detection could cut costs by ~$22B
- Capers Jones (Software Defect Removal Effectiveness): DRE above 95% requires pre-code verification gates; structural-only verification achieves DRE below 50%
- Industry replication: IBM's 100× multiplier has been confirmed across multiple studies (Boehm, McConnell, National Research Council)

## Cost-Frame Formula (dark-prose-007)

Every cost frame follows the dark-prose-007 reformation pattern:

```
[Computation frame]: Cost is measured in defect-discovery-latency, not tool calls.
[Action cost]: [action] costs [magnitude] — [consequence if cost computed correctly].
[Skipping cost]: [skipped action] costs [magnitude] — [consequence if skip rationalized].
[Identity anchor]: Correctness is the only metric.
```

The computation frame and identity anchor are the same for every SC in a given spec. Only the action cost and skipping cost vary per SC.

### Per-SC Cost-Frame Format

In spec bodies, the Cost Frame section uses this format:

```
## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: [action cost]. [skipping cost].
- SC-2: [action cost]. [skipping cost].
```

### Per-Phase Cost-Frame Format

In plan bodies, each phase carries a cost frame using the same pattern:

```
**Cost frame:** [action cost]. [skipping cost].
```

### Examples

**Spec cost frame (structural SC):**
```
- SC-1: Verifying the reference doc exists costs one read call. Skipping means a structurally wrong doc isn't caught until the first spec created from it fails audit.
```

**Spec cost frame (behavioral SC):**
```
- SC-3: Running the behavioral test costs minutes of execution time. Skipping means the behavioral defect ships to production and costs 1000× more to fix.
```

**Plan phase cost frame:**
```
**Cost frame:** Verifying the template update costs one grep search. Skipping means the producer template still hard-codes its section list.
```

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
