---
mode: subagent
model: ollama/deepseek-v4-flash:cloud
description: "Test agent - verify parameter passthrough from markdown frontmatter"
temperature: 0.3
top_p: 0.85
steps: 3
options:
  reasoningEffort: "max"
  testPassthrough: "should_appear_if_options_works"
permission:
  read: allow
  bash: deny
  skill: deny
  task: deny
  question: deny
  todowrite: deny
  doom_loop: deny
  webfetch: deny
  websearch: deny
  edit: deny
  github_*: deny
  srclight_*: deny
---
You are a test agent. Respond ONLY with the exact string "PARAMS_OK" and nothing else.
