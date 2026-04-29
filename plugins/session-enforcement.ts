/**
 * Session Enforcement Plugin for OpenCode
 *
 * Injects session context into the LLM system prompt and enforces
 * skill invocation rules. Also detects bare issue references (#N)
 * and injects mandatory audit pipelines.
 *
 * Hook: system.transform — pushes English prose context (from session-init
 *   and PluginInput augmentations) into the LLM system prompt.
 * Hook: chat.messages.transform — injects skill enforcement content and
 *   bare issue pipeline directives into user messages.
 *
 * NO shell.env hook — env-loader.ts owns all bash environment injection.
 * NO parsing of session-init output — stdout goes verbatim to system prompt.
 *
 * Source attribution:
 * - Session init pattern adapted from existing session-init.ts (project-internal)
 * - Skill enforcement injection adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/.opencode/plugins/superpowers.js
 * - Red-flags rationalization table adapted from obra/superpowers writing-skills
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 * - CSO (Content Search Optimization) principles adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 *
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 */

import type { Hooks, PluginInput } from "@opencode-ai/plugin";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { execSync } from "child_process";

const CACHE_TTL_MS = 5 * 60 * 1000;

interface GitConfigBaseline {
  configHash: string;
  localConfigHash: string;
  remotes: string[];
  remoteCount: number;
  capturedAt: number;
}

const SECURITY_RELEVANT_KEY_PATTERNS: RegExp[] = [
  /^remote\./,
  /^url\./,
  /^http\.proxy$/,
  /^core\.sshCommand$/,
  /^http\.sslVerify$/,
  /^http\.sslCAInfo$/,
  /^credential\.helper$/,
  /^credential\.username$/,
  /^protocol\..*\.allow$/,
  /^core\.hooksPath$/,
  /^init\.templateDir$/,
];

const EXEMPT_KEY_PATTERNS: RegExp[] = [
  /^user\.name$/,
  /^user\.email$/,
  /^core\.autocrlf$/,
  /^core\.filemode$/,
  /^push\.default$/,
  /^submodule\./,
  /^branch\./,
];

function isSecurityRelevantKey(key: string): boolean {
  return SECURITY_RELEVANT_KEY_PATTERNS.some(p => p.test(key));
}

function isExemptKey(key: string): boolean {
  return EXEMPT_KEY_PATTERNS.some(p => p.test(key));
}

function sha256(data: string): string {
  return crypto.createHash("sha256").update(data, "utf8").digest("hex");
}

function captureGitConfigBaseline(projectDir: string): GitConfigBaseline | null {
  try {
    const gitDir = resolveGitDir(projectDir);
    const configContent = gitDir
      ? fs.readFileSync(path.join(gitDir, "config"), "utf8")
      : "";
    const configHash = sha256(configContent);

    let localConfigOutput = "";
    try {
      localConfigOutput = execSync("git config --local --list", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      // No local config or git unavailable
    }
    const localConfigHash = sha256(localConfigOutput);

    let remoteOutput = "";
    try {
      remoteOutput = execSync("git remote -v", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      // No remotes or git unavailable
    }

    const remotes = remoteOutput
      ? [...new Set(remoteOutput.split("\n").map(l => l.split(/\s+/)[0]).filter(Boolean))]
      : [];

    return {
      configHash,
      localConfigHash,
      remotes,
      remoteCount: remotes.length,
      capturedAt: Date.now(),
    };
  } catch {
    return null;
  }
}

function extractChangedSecurityKeys(oldLocalConfig: string, newLocalConfig: string): string[] {
  const oldKeys = new Set(
    oldLocalConfig.split("\n").filter(Boolean).map(l => l.split("=")[0].trim())
  );
  const newKeys = new Set(
    newLocalConfig.split("\n").filter(Boolean).map(l => l.split("=")[0].trim())
  );

  const changed: string[] = [];
  for (const key of newKeys) {
    if (!oldKeys.has(key) && isSecurityRelevantKey(key) && !isExemptKey(key)) {
      changed.push(key);
    }
  }
  for (const key of oldKeys) {
    if (!newKeys.has(key) && isSecurityRelevantKey(key) && !isExemptKey(key)) {
      changed.push(key);
    }
  }

  return changed;
}

let gitConfigBaseline: GitConfigBaseline | null = null;
let baselineLocalConfig: string = "";

function buildGitConfigMutationBlock(changedKeys: string[]): string {
  const keyList = changedKeys.map(k => `- \`${k}\``).join("\n");
  return `<GIT_CONFIG_MUTATION>
⚠️ CRITICAL: Security-relevant git configuration was mutated during this session!

Changed keys:
${keyList}

This is a Tier 1 mandate violation unless explicitly authorized by the developer.
HALT and verify the mutation was authorized before proceeding.
See 000-critical-rules.md → "Git Configuration and Destructive Command Authorization".
</GIT_CONFIG_MUTATION>`;
}

function buildNoVerifyBlockedBlock(): string {
  return `<NO_VERIFY_BLOCKED>
⚠️ CRITICAL: \`--no-verify\` is FORBIDDEN in repos with remotes.

\`git commit --no-verify\` and \`git push --no-verify\` bypass git hooks that
enforce repository safety. This is a Tier 1 mandate.

Only permitted in local-only repos (zero remotes). Check \`git remote -v\` first.
See 000-critical-rules.md → "Git Configuration and Destructive Command Authorization".
</NO_VERIFY_BLOCKED>`;
}

interface PluginDiagnostic {
  source: string;
  level: "error" | "warning" | "info";
  message: string;
  exitCode?: number;
}

const DIAGNOSTICS_PATH = path.join(".opencode", "tmp", "plugin-diagnostics.jsonl");

function writeDiagnostic(projectDir: string, diagnostic: PluginDiagnostic): void {
  const fullPath = path.join(projectDir, DIAGNOSTICS_PATH);
  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  const line = JSON.stringify(diagnostic) + "\n";
  fs.appendFileSync(fullPath, line, "utf8");
}

function collectDiagnostics(projectDir: string): PluginDiagnostic[] {
  const fullPath = path.join(projectDir, DIAGNOSTICS_PATH);
  if (!fs.existsSync(fullPath)) {
    return [];
  }
  try {
    const content = fs.readFileSync(fullPath, "utf8");
    const diagnostics: PluginDiagnostic[] = [];
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (!trimmed) continue;
      try {
        diagnostics.push(JSON.parse(trimmed));
      } catch {
        // Skip malformed lines
      }
    }
    // Clear the file after reading
    fs.writeFileSync(fullPath, "", "utf8");
    return diagnostics;
  } catch {
    return [];
  }
}

function buildDiagnosticBlock(diagnostics: PluginDiagnostic[]): string {
  if (diagnostics.length === 0) return "";

  const entries = diagnostics.map(d => {
    let line = `- [${d.level.toUpperCase()}] ${d.source}: ${d.message}`;
    if (d.exitCode !== undefined) {
      line += ` (exit code ${d.exitCode})`;
    }
    return line;
  }).join("\n");

  const hasErrors = diagnostics.some(d => d.level.toUpperCase() === "ERROR");

  if (hasErrors) {
    const actions = diagnostics
      .filter(d => d.level.toUpperCase() === "ERROR")
      .map(d => `- Investigate and resolve the ${d.source} ERROR before proceeding`)
      .join("\n");

    return `<PLUGIN_DIAGNOSTICS>
⚠️ The following plugin diagnostics were collected during session startup:

${entries}

🚫 MUST NOT proceed — ERROR-level diagnostics detected. HALT immediately and resolve these errors.

**MANDATORY ACTIONS:**
${actions}

Do NOT continue with any operations until ALL ERROR-level diagnostics are resolved.
</PLUGIN_DIAGNOSTICS>`;
  }

  return `<PLUGIN_DIAGNOSTICS>
⚠️ The following plugin diagnostics were collected during session startup:

${entries}

Review these diagnostics. For errors, investigate the source script. For warnings, assess whether action is needed.
</PLUGIN_DIAGNOSTICS>`;
}

let cachedOutput: string | null = null;
let cacheTimestamp = 0;

/**
 * Process-scoped set of session IDs that are sub-agent sessions
 * (sessions with a parentID). Populated in system.transform by
 * querying client.session.get() for parentID. Used in messages.transform
 * to gate first-turn-only injections for sub-agent sessions.
 *
 * REQ-5: No disk persistence — the set is rebuilt from live API queries
 * on each process restart, never written to disk.
 */
const subAgentSessions = new Set<string>();

function resolveGitDir(projectDir: string): string | null {
  try {
    const result = execSync("git rev-parse --git-dir", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    if (path.isAbsolute(result)) return result;
    return path.resolve(projectDir, result);
  } catch {
    return null;
  }
}

function ensureHooksInstalled(projectDir: string): void {
  const hooksSourceDir = path.join(projectDir, ".opencode", "hooks");
  if (!fs.existsSync(hooksSourceDir)) {
    console.error("[session-enforcement] .opencode/hooks/ directory missing — repo integrity problem");
    writeDiagnostic(projectDir, {
      source: "session-enforcement",
      level: "error",
      message: ".opencode/hooks/ directory missing — repo integrity problem",
    });
    return;
  }

  const gitDir = resolveGitDir(projectDir);
  if (!gitDir) {
    console.error("[session-enforcement] Could not resolve .git directory for hooks installation");
    writeDiagnostic(projectDir, {
      source: "session-enforcement",
      level: "error",
      message: "Could not resolve .git directory for hooks installation",
    });
    return;
  }

  const hooksTargetDir = path.join(gitDir, "hooks");
  fs.mkdirSync(hooksTargetDir, { recursive: true });

  const sourceEntries = fs.readdirSync(hooksSourceDir);
  for (const hookName of sourceEntries) {
    const sourcePath = path.join(hooksSourceDir, hookName);
    if (!fs.statSync(sourcePath).isFile()) continue;
    if (hookName.endsWith(".sample")) continue;

    const targetPath = path.join(hooksTargetDir, hookName);
    let needsCopy = false;

    if (!fs.existsSync(targetPath)) {
      needsCopy = true;
    } else {
      const sourceContent = fs.readFileSync(sourcePath, "utf8");
      const targetContent = fs.readFileSync(targetPath, "utf8");
      if (sourceContent !== targetContent) {
        needsCopy = true;
      }
    }

    if (needsCopy) {
      fs.copyFileSync(sourcePath, targetPath);
      fs.chmodSync(targetPath, 0o755);
    }
  }
}

async function runSessionInit(projectDir: string): Promise<string> {
  if (cachedOutput && Date.now() - cacheTimestamp < CACHE_TTL_MS) {
    return cachedOutput;
  }

  try {
    const stdout = execSync("./.opencode/tools/session-init", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedOutput = stdout;
    cacheTimestamp = Date.now();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (!stdout || stdout.length === 0) {
      const errorMsg = isTimeout
        ? `session-init timed out after 30s — likely git credential prompt, lock contention, or submodule hang`
        : (stderr || "Script returned empty output");
      console.error(`[session-enforcement] session-init: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session-init",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      if (stderr && !isTimeout) {
        writeDiagnostic(projectDir, {
          source: "session-init",
          level: "error",
          message: stderr,
          exitCode,
        });
      }
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session-init",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    cachedOutput = stdout;
    cacheTimestamp = Date.now();

    return stdout;
  }
}

let cachedIdentityOutput: string | null = null;
let identityCacheTimestamp = 0;

async function runSessionContextIdentity(projectDir: string): Promise<string> {
  if (cachedIdentityOutput && Date.now() - identityCacheTimestamp < CACHE_TTL_MS) {
    return cachedIdentityOutput;
  }

  try {
    const stdout = execSync("./.opencode/scripts/session_context_identity.py", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedIdentityOutput = stdout;
    identityCacheTimestamp = Date.now();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (!stdout || stdout.length === 0) {
      const errorMsg = isTimeout
        ? `session_context_identity.py timed out after 30s`
        : (stderr || "Script returned empty output");
      console.error(`[session-enforcement] session_context_identity.py: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session_context_identity.py",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session_context_identity.py",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    cachedIdentityOutput = stdout;
    identityCacheTimestamp = Date.now();

    return stdout;
  }
}

let cachedTriggersOutput: string | null = null;
let triggersCacheTimestamp = 0;

async function runSessionContextTriggers(projectDir: string): Promise<string> {
  if (cachedTriggersOutput && Date.now() - triggersCacheTimestamp < CACHE_TTL_MS) {
    return cachedTriggersOutput;
  }

  try {
    const stdout = execSync("./.opencode/scripts/session_context_triggers.py", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    cachedTriggersOutput = stdout;
    triggersCacheTimestamp = Date.now();

    return stdout;
  } catch (err: any) {
    const stdout = err?.stdout?.toString().trim() ?? "";
    const stderr = err?.stderr?.toString().trim() ?? "";
    const exitCode = err?.status ?? 1;

    const isTimeout = err?.killed || err?.signal === "SIGTERM";

    if (exitCode !== 0) {
      const errorMsg = isTimeout
        ? `session_context_triggers.py timed out after 30s`
        : (stderr || "Script exited with non-zero code");
      console.error(`[session-enforcement] session_context_triggers.py exited with code ${exitCode}: ${errorMsg}`);
      writeDiagnostic(projectDir, {
        source: "session_context_triggers.py",
        level: "error",
        message: errorMsg,
        exitCode: isTimeout ? undefined : exitCode,
      });
      return "";
    }

    if (!stdout || stdout.length === 0) {
      if (stderr) {
        writeDiagnostic(projectDir, {
          source: "session_context_triggers.py",
          level: "warning",
          message: stderr,
          exitCode,
        });
      }
      return "";
    }

    if (stderr) {
      writeDiagnostic(projectDir, {
        source: "session_context_triggers.py",
        level: "warning",
        message: stderr,
        exitCode,
      });
    }

    cachedTriggersOutput = stdout;
    triggersCacheTimestamp = Date.now();

    return stdout;
  }
}

interface ProjectMetadata {
  name: string;
  version: string;
  pythonVersion: string;
}

function readProjectMetadata(projectDir: string): ProjectMetadata | null {
  const pyprojectPath = path.join(projectDir, "pyproject.toml");
  if (!fs.existsSync(pyprojectPath)) {
    return null;
  }

  let name = "";
  let version = "";
  let inProjectSection = false;

  try {
    const content = fs.readFileSync(pyprojectPath, "utf8");
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (trimmed === "[project]") {
        inProjectSection = true;
        continue;
      }
      if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
        inProjectSection = false;
        continue;
      }
      if (inProjectSection) {
        if (trimmed.startsWith("name")) {
          const eqIdx = trimmed.indexOf("=");
          if (eqIdx > 0) {
            name = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, "");
          }
        } else if (trimmed.startsWith("version")) {
          const eqIdx = trimmed.indexOf("=");
          if (eqIdx > 0) {
            version = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, "");
          }
        }
      }
    }
  } catch {
    return null;
  }

  if (!name) {
    return null;
  }

  let pythonVersion = "";
  const pythonVersionPath = path.join(projectDir, ".python-version");
  if (fs.existsSync(pythonVersionPath)) {
    try {
      pythonVersion = fs.readFileSync(pythonVersionPath, "utf8").trim();
    } catch {
      // Ignore read errors
    }
  }

  return { name, version: version || "0.1.0", pythonVersion };
}

function buildMetadataBlock(projectDir: string): string {
  const meta = readProjectMetadata(projectDir);
  if (!meta) {
    return "";
  }

  const lines: string[] = [`Project: ${meta.name} v${meta.version}`];
  if (meta.pythonVersion) {
    lines.push(`Python: ${meta.pythonVersion}`);
  }
  return lines.join("\n");
}

function buildTrainingStalenessBlock(): string {
  return `<TRAINING_STALENESS_CRITICAL>
⚠️ Your training data is STALE. You CANNOT rely on your training data for:

- API signatures, library versions, framework syntax
- Configuration formats, environment variable names
- Code patterns, best practices, recommended approaches
- Documentation, examples, tutorials

**VERIFICATION IS MANDATORY:**

1. **Check live documentation** before using any API, framework, or library
2. **Verify code signatures** using srclight_get_signature before claiming behavior
3. **Read actual source files** before asserting code behavior
4. **Confirm configuration** against live schemas before asserting compliance
5. **Attempt exhaustive research** using available tools before making factual claims; if research fails, follow suggest-after-research fallback — NEVER present training-data claims as verified facts

**DO NOT TRUST:**

- Your memory about how something works
- Code comments (they may be outdated or wrong)
- Documentation snippets from training data
- "I've seen this before" or "I know this pattern"
- Second-hand information without live source verification

**ALWAYS VERIFY** before:
- Proposing a course of action
- Providing an technical answer
- Making claims about code behavior
- Suggesting solutions

**RESEARCH-FIRST RULE:**
- General knowledge questions still require research attempts — search the web, search documentation, search the codebase
- If research tools cannot verify a claim, do NOT present it as fact with a disclaimer
- For general knowledge: offer training-data answer as suggestion contingent on user acceptance
- For code/API claims: DECLINE to state — no suggestion, no fallback, no disclaimer
- There is NO exemption for "general explanation" or "brainstorming" — research before claiming

This is a CRITICAL rule. Violations result in incorrect guidance and broken implementations.
</TRAINING_STALENESS_CRITICAL>`;
}

function buildReferencesVerificationBlock(): string {
  return `<REFERENCES_VERIFICATION_MANDATE>
⚠️ You MUST NOT assume knowledge of any referenced file, schema, configuration, or artifact without FIRST verifying its contents with a tool call. This applies to ALL activities without exception: coding, spec development, plan creation, implementation, skill book updates, runbook authoring, correspondence, and any other work.

**YOU ARE FORBIDDEN FROM:**

- Assuming you know what a file contains without opening it first
- Claiming knowledge of a schema's fields without reading the schema
- Proceeding past a reference to a file, path, or configuration without verifying the reference exists
- Treating any information as "already known" without a visible tool-call artifact proving you checked
- Writing documentation, runbooks, or specs that describe files/configs/APIs you have not actually read
- Skipping verification because "I've seen this file before" or "I know this pattern"
- Claiming a referenced file or artifact exists without confirming via glob, read, or srclight

**SELF-AUDIT GATE (MANDATORY):**

Before making ANY claim about a file, schema, configuration, or referenced artifact, you MUST produce a tool-call artifact in the conversation proving you verified it. Acceptable artifacts:

- A \`read\` tool call showing the file contents
- A \`srclight_get_signature\` or \`srclight_get_symbol\` call confirming a function/class signature
- A \`glob\` or \`grep\` call confirming a file or pattern exists
- A \`bash\` command output confirming system state

**No tool-call artifact = the claim is FORBIDDEN.** You cannot state "the config has X field" without the read call that confirmed it. You cannot state "the function takes Y parameters" without the signature lookup that verified it. You cannot state "the file exists" without the glob or read that confirmed it.

**RESEARCH-FIRST REQUIREMENT:**
Before making ANY factual claim, the agent MUST attempt exhaustive research using available tools. This includes:
- Web search for general knowledge claims
- Code search (srclight, grep, glob) for codebase claims
- Documentation lookup for API/library claims
- File read for configuration claims

If research fails, follow the suggest-after-research fallback:
- For general knowledge: Offer the training-data answer as an explicit suggestion contingent on user acceptance
- For code/API claims: DECLINE to state the claim — no suggestion, no fallback, no disclaimer

**SINGLE EXCHANGE WINDOW:** The ONLY exception is a tool call from the immediately preceding exchange (last assistant turn in the same conversation). Any earlier reference requires re-verification.

**THIS IS UNCONDITIONAL:**

- No scope exemption: applies to coding, specs, plans, runbooks, skill updates, correspondence, everything
- No activity exemption: "just checking" is not verification-free
- No knowledge exemption: "I already know this" is the specific bypass this rule closes
- No size exemption: "this is too small to verify" is not valid — verify it

**Authority:** This mandate enforces the principles in guidelines 065-verification-honesty.md (proactive verification, evidence requirement) and 075-docs-verification.md (mandatory live documentation verification). This block does not duplicate those guidelines — it operationalizes their core rules at the system-prompt level, at the exact decision point where the agent decides whether to verify or assume.
</REFERENCES_VERIFICATION_MANDATE>`;
}

function buildLanguagePreferenceBlock(): string {
  return `<LANGUAGE_PREFERENCE>
All communications MUST use **formal/business/professional Southeastern United States English**.

This means:
- Use Southern US English spelling, vocabulary, and phrasing conventions
- Maintain a formal, professional, and business-appropriate register
- Prefer clarity and directness with Southern politeness conventions
- Avoid regional colloquialisms that sacrifice professionalism
- Use "y'all" only in informal context; prefer "you" or "your team" in formal writing
</LANGUAGE_PREFERENCE>`;
}

function buildWorktreeBlock(input: PluginInput): string {
  const mainRepoDir = input?.directory || "";
  const worktreeDir = input?.worktree || "";

  if (worktreeDir && worktreeDir !== mainRepoDir) {
    return `worktree.path: ${worktreeDir}\nAll file operations (read, edit, write, glob, grep) MUST use paths prefixed with worktree.path. Relative paths resolve to the main repo, not the worktree.`;
  }

  return "";
}



/**
 * Regex matching a bare issue reference: input that is solely an issue number
 * like `#591`. Does NOT match `fix #591`, `see #591 and #592`, or any
 * message with additional context.
 */
const BARE_ISSUE_RE = /^\s*#(\d+)\s*$/;

/**
 * Build a pipeline directive for bare issue references.
 * When a user sends just `#N`, the agent should follow a deterministic
 * audit→brainstorm→plan→HALT pipeline rather than guessing.
 */
function buildIssuePipelineDirective(issueNumber: string): string {
  return `<ISSUE_PIPELINE_TRIGGER>
The user provided a bare issue reference #${issueNumber}. Follow this mandatory pipeline:

1. **Read the issue**: Use github_issue_read with method=get AND method=get_comments for #${issueNumber}
2. **Audit the spec**: Invoke /skill spec-auditor --issue ${issueNumber}
3. **Brainstorm refinements**: Invoke /skill brainstorming
4. **Write a plan**: Invoke /skill writing-plans --task create
5. **HALT** — Never auto-execute. Wait for explicit authorization.

Critical rules:
- Never auto-execute any plan
- Follow each skill's own protocol
- Adapt for bug reports (audit still runs, brainstorming explores the bug)
- Fix audit findings before brainstorming
- Read ALL comments on the issue before acting
</ISSUE_PIPELINE_TRIGGER>`;
}

function extractValue(sessionOutput: string | null, key: string): string | null {
  if (!sessionOutput) return null;
  const escapedKey = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const match = sessionOutput.match(new RegExp(`${escapedKey}=\\s*(\\S+)`));
  return match ? match[1] : null;
}



/**
 * Secret patterns for redaction.
 * These regexes match secret values in various formats while preserving key names.
 */
const SECRET_PATTERNS: Array<{ pattern: RegExp; type: string }> = [
  { pattern: /\b(TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|API_KEY|PRIVATE_KEY|ACCESS_TOKEN)\s*[=:]\s*["']?([^\s"']+?)["']?(?=\s|$|[^\w])/gi, type: "assignment" },
  { pattern: /:\/\/([^:]+):([^@]+)@/g, type: "url_password" },
  { pattern: /\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}/g, type: "github_token" },
  { pattern: /\bglpat-[A-Za-z0-9\-]{20,}/g, type: "gitlab_token" },
];

/**
 * Redact secrets from text, replacing values with [REDACTED:TYPE] markers.
 * Key names are preserved — only secret values are replaced.
 *
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 */
function redactSecrets(text: string): string {
  let result = text;

  // URL-embedded passwords: user:password@ → user:[REDACTED:PASSWORD]@
  result = result.replace(/:\/\/([^:]+):([^@]+)@/g, (_match, user: string, _password: string) => {
    return `://${user}:[REDACTED:PASSWORD]@`;
  });

  // GitHub tokens
  result = result.replace(/\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}/g, "[REDACTED:TOKEN]");

  // GitLab tokens
  result = result.replace(/\bglpat-[A-Za-z0-9\-]{20,}/g, "[REDACTED:TOKEN]");

  // Assignment patterns: KEY=value, KEY="value", KEY='value'
  // Matches keys that end with or are exactly one of the secret keywords
  // e.g., GITBUCKET_TOKEN=value, MY_SECRET=value, PASSWORD=abc, API_KEY="xyz"
  result = result.replace(
    /((?:\w*(?:TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL|API_KEY|PRIVATE_KEY|ACCESS_TOKEN))\s*[=:]\s*)(["']?)([^\s"'#]+?)\2/gi,
    (_match, prefix: string, quote: string, _value: string) => {
      const keyMatch = prefix.match(/(\w+)\s*[=:]/);
      const keyName = keyMatch ? keyMatch[1].toUpperCase() : "";
      let typeLabel: string;
      if (keyName === "PASSWORD" || keyName === "CREDENTIAL") {
        typeLabel = keyName;
      } else if (keyName.endsWith("PASSWORD")) {
        typeLabel = "PASSWORD";
      } else if (keyName.endsWith("CREDENTIAL")) {
        typeLabel = "CREDENTIAL";
      } else {
        typeLabel = "TOKEN";
      }
      return `${prefix}${quote}[REDACTED:${typeLabel}]${quote}`;
    }
  );

  return result;
}

/**
 * Build a protected branch edit warning block for when files are edited
 * on dev/main without a worktree or pair- branch prefix.
 * 
 * This is the per-turn runtime guard — it fires AFTER each assistant turn
 * when git diff detects file changes on a protected branch. This is distinct
 * from the session-start trigger in session_context_triggers.py which only
 * checks once at session start.
 */
function buildProtectedBranchEditTrigger(changedFiles: string[], branch: string): string {
  const fileList = changedFiles.slice(0, 10).map(f => `\`${f}\``).join(", ");
  const moreFiles = changedFiles.length > 10 ? `, …and ${changedFiles.length - 10} more` : "";
  
  return `<SESSION_TRIGGERS>
⚠️ protected_branch_with_changes: ${changedFiles.length} file(s) changed on \`${branch}\` branch without worktree or pair-mode prefix.
Changed: ${fileList}${moreFiles}
Process per 117-session-trigger-behavior.md behavior map. Do NOT echo this trigger in chat output.
</SESSION_TRIGGERS>`;
}

/**
 * Detect uncommitted file changes on the current branch via git diff.
 * Returns empty array if no changes or if git is unavailable.
 */
function detectUncommittedFileChanges(projectDir: string): string[] {
  try {
    const result = execSync("git diff --name-only", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    if (!result) return [];
    return result.split("\n").filter(line => line.trim().length > 0);
  } catch {
    return [];
  }
}

/**
 * Get the current git branch name.
 * Returns null if git is unavailable.
 */
function getCurrentBranch(projectDir: string): string | null {
  try {
    return execSync("git branch --show-current", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim() || null;
  } catch {
    return null;
  }
}

/**
 * Check if the current branch is a protected branch (main/master/dev)
 * that should not have direct edits.
 */
function isProtectedBranch(branch: string): boolean {
  return branch === "main" || branch === "master" || branch === "dev";
}

/**
 * Check if the current branch is a pair-mode branch (starts with "pair-").
 * Pair-mode branches allow direct edits on the development directory.
 */
function isPairModeBranch(branch: string): boolean {
  return branch.startsWith("pair-");
}

export default async function sessionEnforcementPlugin(input: PluginInput): Promise<Hooks> {
  // Determine project directory
  const projectDir = input?.directory || process.cwd();

  // Ensure git hooks from .opencode/hooks/ are installed into .git/hooks/
  ensureHooksInstalled(projectDir);

  // Capture git config baseline for mutation watchdog
  gitConfigBaseline = captureGitConfigBaseline(projectDir);
  if (gitConfigBaseline) {
    try {
      baselineLocalConfig = execSync("git config --local --list", {
        cwd: projectDir,
        encoding: "utf8",
        input: "",
        timeout: 5000,
        stdio: ["pipe", "pipe", "pipe"],
      }).trim();
    } catch {
      baselineLocalConfig = "";
    }
  }

  return {
    // Inject session context into system prompt (from session-init + PluginInput augmentations)
    "experimental.chat.system.transform": async (sysInput, output) => {
      // --- Sub-agent session detection (REQ-1/REQ-5) ---
      // Query client.session.get() for parentID; if present, this session
      // is a sub-agent. Register in process-scoped Set for later use in
      // messages.transform. Graceful degradation: on failure, assume
      // primary session (REQ-4).
      const sessionID = sysInput?.sessionID;
      if (sessionID) {
        try {
          const sessionResult = await input.client.session.get({
            path: { id: sessionID },
          });
          if (sessionResult.data?.parentID) {
            subAgentSessions.add(sessionID);
          } else {
            subAgentSessions.delete(sessionID);
          }
        } catch {
          // REQ-4: Graceful degradation — assume primary session on API failure
          subAgentSessions.delete(sessionID);
        }
      }

      const scriptOutput = await runSessionInit(projectDir);
      if (scriptOutput) {
        output.system.push(scriptOutput);
      }

      // Inject worktree context when session is operating in a worktree
      const worktreeBlock = buildWorktreeBlock(input);
      if (worktreeBlock) {
        output.system.push(worktreeBlock);
      }

      // Inject project metadata (name, version, Python version)
      const metadataBlock = buildMetadataBlock(projectDir);
      if (metadataBlock) {
        output.system.push(metadataBlock);
      }

      // Inject training staleness warning (verifying everything is mandatory)
      output.system.push(buildTrainingStalenessBlock());

      // Inject references verification mandate (no assuming knowledge without tool-call artifact)
      output.system.push(buildReferencesVerificationBlock());

      // Inject language preference (Southeastern US English mandate)
      output.system.push(buildLanguagePreferenceBlock());

      // Inject identity section from session_context_identity.py
      const identityOutput = await runSessionContextIdentity(projectDir);
      if (identityOutput) {
        output.system.push(identityOutput);
      }


    },

    // Inject enforcement content into first user message (adapted from obra/superpowers)
      // AND detect bare #N issue references in last user message
      // AND inject trigger warnings into first user message
      // AND inject plugin diagnostics block into first user message
      //
      // FIRST-TURN GUARD: SESSION_TRIGGERS, EXTREMELY_IMPORTANT,
      // PLUGIN_DIAGNOSTICS, and LOCAL_MODE warnings are injected ONLY on
      // the first turn of PRIMARY sessions (isFirstTurn && !isSubAgent). Sub-agent
      // sessions inherit context from their parent, so these blocks are redundant
      // and waste context window space (REQ-1/REQ-2).
      //
      // Per-turn behaviors (unchanged, unconditional per REQ-3/REQ-6):
      // - Bare issue pipeline detection on lastUser
      // - Secret redaction on all assistant messages
      // - Protected branch edit warning
      "experimental.chat.messages.transform": async (_input, output) => {
        if (!output.messages || !output.messages.length) return;

        const userMessages = output.messages.filter(m => m.info?.role === "user");
        if (!userMessages.length) return;

        const firstUser = userMessages[0];
        const isFirstTurn = userMessages.length === 1;

        // --- Sub-agent detection (REQ-1) ---
        // Determine if this session has a parentID (is a sub-agent session).
        // Extract sessionID from the first user message's info to look up
        // in the subAgentSessions Set populated by system.transform.
        // REQ-5: No disk persistence — subAgentSessions is process-scoped only.
        // REQ-4: Graceful degradation — if sessionID is unavailable, assume
        // primary session (isSubAgent = false) so full injections are applied.
        const sessionID = firstUser?.info?.sessionID;
        const isSubAgent = sessionID ? subAgentSessions.has(sessionID) : false;

        // --- First-turn-only PRIMARY sessions: Skip all first-turn injections
        //     for sub-agent sessions (isFirstTurn && !isSubAgent required) ---
        // REQ-2: Sub-agent sessions inherit parent context, making these blocks
        //         redundant. Gating them saves significant context window space.
        const shouldInjectFirstTurn = isFirstTurn && !isSubAgent;

        if (shouldInjectFirstTurn) {
          // --- First-turn-only: Trigger warnings ---
          const triggersOutput = await runSessionContextTriggers(projectDir);

          const triggerBlock = triggersOutput ? `<SESSION_TRIGGERS>\n${triggersOutput}\n</SESSION_TRIGGERS>` : "";

          if (triggerBlock && firstUser.parts?.length) {
            firstUser.parts.unshift({ type: "text", text: triggerBlock });
          }

          // --- First-turn-only: Plugin diagnostics injection ---
          const diagnostics = collectDiagnostics(projectDir);
          const diagnosticBlock = buildDiagnosticBlock(diagnostics);
          if (diagnosticBlock && firstUser.parts?.length) {
            firstUser.parts.push({ type: "text", text: diagnosticBlock });
          }

          // --- First-turn-only: Local/submodule mode warnings ---
          const knownPlatform = extractValue(cachedIdentityOutput, "github.platform");
          const knownIdentitySource = extractValue(cachedIdentityOutput, "github.identity_source");

          const isLocalMode = knownPlatform === "local" || knownIdentitySource === "none";
          const isSubmoduleMode = knownIdentitySource === "submodule";

          if (isLocalMode) {
            const lastUser = userMessages[userMessages.length - 1];
            if (lastUser?.parts?.length) {
              lastUser.parts.push({
                type: "text",
                text: `<LOCAL_MODE>\n⚠️ Operating in local-only mode — no git remote configured.\n\n- github.platform: local\n- github.owner: (none)\n- github.repo: (none)\n- github.identity_source: none\n\nGitHub/GitBucket API calls are unavailable. Local issue tracking (.issues/) is available.\nDo NOT attempt to use GitHub MCP or GitBucket API tools — all issue operations route to local .issues/.\n</LOCAL_MODE>`
              });
            }
          } else if (isSubmoduleMode) {
            const parentRemoteCount = gitConfigBaseline?.remoteCount ?? 0;
            const lastUser = userMessages[userMessages.length - 1];
            if (lastUser?.parts?.length) {
              lastUser.parts.push({
                type: "text",
                text: `<LOCAL_MODE>\n⚠️ Operating in submodule-local mode — parent repo has ${parentRemoteCount} remote(s).\n\n- github.identity_source: submodule\n- All remote git operations (fetch, pull, push, remote branch management) must run from inside the submodule directory — not the project root.\n- The parent repo has ZERO remotes by design.\n- github.owner and github.repo are from the submodule remote for API routing ONLY\n- GitHub MCP calls route to the submodule's repository\n- Local git operations (branch, commit, stash) on the parent repo are permitted\n- Do NOT push from the parent repo — there is no remote to push to.\n- Do NOT add remotes to the parent repo.\n</LOCAL_MODE>`
              });
            }
          }
        }

      // --- Per-turn: Bare issue pipeline detection on LAST user message ---
      const lastUser = userMessages[userMessages.length - 1];
      if (lastUser?.parts?.length) {
        for (const part of lastUser.parts) {
          if (part.type === "text" && part.text) {
            const match = part.text.match(BARE_ISSUE_RE);
            if (match) {
              const directive = buildIssuePipelineDirective(match[1]);
              lastUser.parts.push({ type: "text", text: directive });
              break; // Only inject pipeline directive once per message
            }
          }
        }
      }

      // --- Per-turn: Secret redaction on ALL assistant messages ---
      const assistantMessages = output.messages.filter(m => m.info?.role === "assistant");
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (let i = 0; i < msg.parts.length; i++) {
          const part = msg.parts[i];
          if (part.type === "text" && part.text) {
            const redacted = redactSecrets(part.text);
            if (redacted !== part.text) {
              msg.parts[i] = { ...part, type: "text", text: redacted };
            }
          }
        }
      }

      // --- Per-turn: Git config mutation watchdog ---
      if (gitConfigBaseline) {
        try {
          const currentLocalConfig = execSync("git config --local --list", {
            cwd: projectDir,
            encoding: "utf8",
            input: "",
            timeout: 5000,
            stdio: ["pipe", "pipe", "pipe"],
          }).trim();

          const currentBaseline = captureGitConfigBaseline(projectDir);
          if (currentBaseline) {
            const configChanged = currentBaseline.configHash !== gitConfigBaseline.configHash;
            const localConfigChanged = currentBaseline.localConfigHash !== gitConfigBaseline.localConfigHash;

            if (configChanged || localConfigChanged) {
              const changedKeys = extractChangedSecurityKeys(baselineLocalConfig, currentLocalConfig);
              if (changedKeys.length > 0) {
                const mutationBlock = buildGitConfigMutationBlock(changedKeys);
                const nextUser = userMessages[userMessages.length - 1];
                if (nextUser?.parts?.length) {
                  nextUser.parts.push({ type: "text", text: mutationBlock });
                }
                gitConfigBaseline = currentBaseline;
                baselineLocalConfig = currentLocalConfig;
              }
            }
          }
        } catch {
          // Git unavailable or config unreadable — skip watchdog
        }
      }

      // --- Per-turn: --no-verify detection ---
      let hasRemotes: boolean;
      if (gitConfigBaseline) {
        hasRemotes = gitConfigBaseline.remoteCount > 0;
      } else {
        // Baseline capture failed — check remotes inline
        try {
          const remoteCheck = execSync("git remote -v", {
            cwd: projectDir,
            encoding: "utf8",
            input: "",
            timeout: 5000,
            stdio: ["pipe", "pipe", "pipe"],
          }).trim();
          hasRemotes = remoteCheck.length > 0;
        } catch {
          hasRemotes = false; // No remotes = local-only → permit --no-verify
        }
      }
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (const part of msg.parts) {
          if (part.type === "text" && part.text) {
            const noVerifyMatch = part.text.match(/(?:git\s+commit|git\s+push)\s+.*--no-verify/);
            if (noVerifyMatch && hasRemotes) {
              const blockedBlock = buildNoVerifyBlockedBlock();
              const nextUser = userMessages[userMessages.length - 1];
              if (nextUser?.parts?.length) {
                nextUser.parts.push({ type: "text", text: blockedBlock });
              }
              break;
            }
          }
        }
      }

      // --- Per-turn: Branch topology check ---
      // Detect degraded remote branch topology and inject BRANCH_TOPOLOGY warning.
      // This mirrors the session_context_triggers.py BRANCH_TOPOLOGY detection
      // but operates at the TypeScript plugin level for real-time detection.
      let branchTopologyBlock = "";
      try {
        const hasRemotesForTopology = gitConfigBaseline ? gitConfigBaseline.remoteCount > 0 : false;
        if (hasRemotesForTopology) {
          const currentBranchForTopology = getCurrentBranch(projectDir);
          const isFeatureForTopology = currentBranchForTopology &&
            currentBranchForTopology !== "main" &&
            currentBranchForTopology !== "master" &&
            currentBranchForTopology !== "dev";

          // Check 1: origin/dev existence for feature branches
          let originDevMissing = false;
          if (isFeatureForTopology) {
            try {
              execSync("git rev-parse --verify origin/dev", {
                cwd: projectDir,
                encoding: "utf8",
                input: "",
                timeout: 5000,
                stdio: ["pipe", "pipe", "pipe"],
              });
            } catch {
              originDevMissing = true;
            }
          }

          // Check 2: common ancestor between main and dev
          let orphanedBranches = false;
          try {
            const hasMain = execSync("git rev-parse --verify origin/main 2>/dev/null || git rev-parse --verify origin/master 2>/dev/null", {
              cwd: projectDir,
              encoding: "utf8",
              input: "",
              timeout: 5000,
              stdio: ["pipe", "pipe", "pipe"],
            }).trim();
            const hasDev = execSync("git rev-parse --verify origin/dev", {
              cwd: projectDir,
              encoding: "utf8",
              input: "",
              timeout: 5000,
              stdio: ["pipe", "pipe", "pipe"],
            }).trim();

            if (hasMain && hasDev) {
              try {
                execSync("git merge-base origin/main origin/dev || git merge-base origin/master origin/dev", {
                  cwd: projectDir,
                  encoding: "utf8",
                  input: "",
                  timeout: 5000,
                  stdio: ["pipe", "pipe", "pipe"],
                });
                // merge-base exists — check ancestry
              } catch {
                // No merge-base found — orphaned
                orphanedBranches = true;
              }
            }
          } catch {
            // Could not determine branch refs — skip topology check
          }

          const topologyLines: string[] = [];
          if (originDevMissing) {
            topologyLines.push("- ❌ origin/dev does not exist on remote — feature branch PRs will fail. Push dev to remote first: git push origin dev");
          }
          if (orphanedBranches) {
            topologyLines.push("- ❌ main and dev are orphaned (no common ancestor) — PRs between them will fail. Fix: rebase dev onto main, or merge with --allow-unrelated-histories.");
          }

          if (topologyLines.length > 0) {
            branchTopologyBlock = `<SESSION_TRIGGERS>
⚠️ branch_topology: Remote branch topology is degraded.
${topologyLines.join("\n")}
- Action: resolve topology issues before pushing feature branches.
Process per 117-session-trigger-behavior.md behavior map. Do NOT echo this trigger in chat output.
</SESSION_TRIGGERS>`;
          }
        }
      } catch {
        // Git unavailable or topology check failed — skip
      }

      // --- Per-turn: BRANCH_TOPOLOGY injection into last user message ---
      if (branchTopologyBlock) {
        const lastUserForTopology = userMessages[userMessages.length - 1];
        if (lastUserForTopology?.parts?.length) {
          lastUserForTopology.parts.push({ type: "text", text: branchTopologyBlock });
        }
      }

      // --- Per-turn: Protected branch edit guard ---
      // After each assistant turn, check if files were edited on dev/main
      // without a worktree or pair- branch prefix. If so, inject warning.
      const currentBranch = getCurrentBranch(projectDir);
      if (currentBranch && isProtectedBranch(currentBranch)) {
        const worktreeDir = input?.worktree || "";
        const inWorktree = worktreeDir && worktreeDir !== projectDir;
        
        if (!inWorktree && !isPairModeBranch(currentBranch)) {
          const changedFiles = detectUncommittedFileChanges(projectDir);
          if (changedFiles.length > 0) {
            const warning = buildProtectedBranchEditTrigger(changedFiles, currentBranch);
            const lastAssistant = assistantMessages[assistantMessages.length - 1];
            if (lastAssistant?.parts?.length) {
              lastAssistant.parts.push({ type: "text", text: warning });
            }
          }
        }
      }
    },
  };
}
