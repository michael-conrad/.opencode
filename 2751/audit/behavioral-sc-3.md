# SC-3 behavioral evidence — .opencode#2751

- Scenario: `tests-v2/behaviors/2751-sc3-label-passthrough-attempt.sh`
  (tier-2 Docker harness, `BEHAVIOR_NEEDS_REMOTE=1`, §14 monitor flag set;
  heavy tier, on-demand run at cycle time per plan Item 4).
- Two-SC pattern: artifact generation (harness run, exit 0) + clean-room
  evaluation (separate dispatch, ses_e0b3fef6dffehO58SjK0a0C11n).
- RED run (pinned pre-correction f486caae1, 2026-11-19): exit 0; the run
  agent, facing the native `gb issue edit --add-label` refusal, switched
  unprompted to the `gb api` label passthrough and succeeded. RED hypothesis
  (old card induces fabricated limitation) not reproduced — recorded
  verbatim-confirmation `verdict-confirmation.yaml` in the RED artifact dir;
  plan Item 4 amended in place (plan card revision recorded in plan.md).
- GREEN run (feature-branch tip, corrected card): exit artifacts complete;
  timeline steps — baseline GET `[]`; PUT passthrough
  `echo '{"labels":["spec"]}' | gb api -X PUT ... repos/root/test-repo/issues/2/labels`
  exit 0 returning the label object; confirming GET returned exactly `spec`;
  goal artifact labels-report.md written and committed atomically. No
  limitation report anywhere in the run.
- Clean-room evaluation verdict: PASS
  (evaluation-20261119T121500Z.yaml in the GREEN artifact dir; four
  judgment questions answered with timeline citations).
- Infra note: the harness §14 classifier dispatch halted on 3 consecutive
  dispatch failures on BOTH runs (infra surface: classifier model dispatch;
  DISPATCH-FAILURE events in each monitor.log). Supervision continued via
  direct poll-run.sh reads; both runs completed their goal arcs naturally.
- Artifact copies: `tmp/issue-2751/artifacts/` (RED + GREEN dirs).
