## Summary

Agent received a purely interrogative question ("why is this suddenly out of scope?") and immediately took action (deleted 4 remote branches) instead of answering the question and halting. The agent pattern-matched the question's implied normative premise ("this *should* be in scope") as an authorization directive, collapsing the answer-to-action gap entirely.

This issue was incorrectly filed in `opencode-config` — the target files live in the `.opencode` submodule (`michael-conrad/.opencode`). The correct spec is: michael-conrad/.opencode#227

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
