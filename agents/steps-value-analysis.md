<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Steps Value Determination for Auditor Sub-Agents

## Source Data

Empirical query of `~/.local/share/opencode/opencode.db` — the local opencode session database containing **5,113 sub-agent sessions** across all projects worked on this machine.

## Queries Executed

```sql
-- Tool-call steps per sub-agent session
SELECT COUNT(*) AS step_count
FROM part p
JOIN session s ON s.id = p.session_id
WHERE s.parent_id IS NOT NULL
  AND p.data LIKE '%"type":"step-start"%'
GROUP BY p.session_id;
```

## Results

| Metric | Steps | Meaning |
|--------|-------|---------|
| **Median** | 6 | Half of all sub-agents finish in ≤6 tool-call steps |
| **Average** | 9.4 | Mean across all sessions |
| **P90** | 18 | 90th percentile — 1 in 10 exceeds this |
| **P95** | 28 | 95th percentile — 1 in 20 exceeds this |
| **Max** | 1,044 | Runaway outlier — no step cap in place |

## Determination: `steps: 50`

| Criterion | Value | Rationale |
|-----------|-------|-----------|
| Safety margin above P95 | 50 > 28 | 1.8× headroom above 95th percentile |
| Auditor workload | 50 | Adversarial auditors need more steps than average sub-agents: read evidence (multiple read/grep), evaluate each SC independently (B1-B8 per criterion), write YAML artifact (write), return frugal contract. A complex audit with 10-15 SCs could reasonably reach 20-30 steps |
| Runaway guard | 50 < 1044 | Catches the runaway outlier class before user intervention needed |
| Not over-constrained | 50 | Would not have triggered on 95% of historical sub-agent sessions |

The value 50 provides adequate headroom for complex multi-SC audits while capping the extreme runaway case at a small fraction of the observed 1,044-step outlier.

🤖 Co-authored with AI: DeepSeek V4 Flash (ollama-cloud/deepseek-v4-flash)
