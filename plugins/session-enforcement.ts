/**
 * Session Enforcement Plugin for OpenCode
 *
 * Injects session context into the LLM system prompt and enforces
 * runtime guards: inline work detection, evidence gate, git config
 * mutation watchdog, protected branch edits, secret redaction, session triggers,
 * and plugin diagnostics.
 *
 * Hook: system.transform — pushes English prose context (from session-init
 *   and PluginInput augmentations) into the LLM system prompt.
 * Hook: chat.messages.transform — injects runtime enforcement blocks and
 *   validation gates into user messages.
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
  return `### Git Configuration Mutation Warning

**Warning:** Security-relevant git configuration was mutated during this session!

Changed keys:
${keyList}

This is a Tier 1 mandate violation unless explicitly authorized by the developer. HALT and verify the mutation was authorized before proceeding. See 000-critical-rules.md for details on Git Configuration and Destructive Command Authorization.`;
}

// buildNoVerifyBlockedBlock() REMOVED per SPEC-FIX #823 — see removal comment above.

function buildInlineWorkDetectedBlock(editToolNames: string[], dispatchFound: boolean): string {
  const editList = editToolNames.map(t => `- \`${t}\``).join("\n");
  const dispatchNote = dispatchFound
    ? "A sub-agent dispatch was found, but file edits occurred BEFORE the dispatch in this turn."
    : "No sub-agent dispatch (task tool) was found in this turn.";
  return `### Inline Work Detected

**Warning:** The orchestrator performed file operations without sub-agent dispatch evidence.

File-editing tool calls detected in this turn:
${editList}

${dispatchNote}

The orchestrator MUST be a pure router — all file modifications MUST be dispatched through implementation-pipeline sub-agents. See 000-critical-rules.md Inline Work. Exemptions: pair- branches, .issues/ file edits, simple-work single-file changes. If this is an exempt case, disregard this warning.`;
}

function buildEvidenceGateBlock(): string {
  return `### Evidence Gate

**Warning:** Issue closure attempted without verification evidence. A github_issue_write call with state=closed was detected, but no per-SC verification evidence table exists in recent assistant messages. Every issue closure requires a verification evidence table confirming each success criterion was met with a tool-call artifact. See 000-critical-rules.md Verification Dishonesty and verification-before-completion skill. If the closure is exempt (not_planned, duplicate, rollback-reopen), disregard this warning.`;
}

const MODE_SWITCH_ANCHOR = [
  'skill() + task() gate every action. Both skill() and task() are mandatory \u2014 every workflow.',
  'Inline work poisons your output \u2014 unrecoverable.',
  'FAIL = FAIL \u2014 justifiable violations do not exist.',
].join('\n');

function isModeSwitchContent(text: string): boolean {
  return text.includes('Your operational mode has changed from plan to build.')
      || text.includes('# Plan Mode - System Reminder');
}

function handleModeSwitchParts(
  messages: { info: { role: string; agent?: string }; parts: { type?: string; text?: string; synthetic?: boolean }[] }[],
): void {
  const currentUser = messages.findLast(m => m.info?.role === 'user');
  if (!currentUser) return;

  // Phase 1: determine if this turn is a mode transition
  const lastAssistant = messages.findLast(m => m.info?.role === 'assistant');
  const isTransition = !lastAssistant ||
    lastAssistant.info?.agent !== currentUser.info?.agent;

  // Phase 2: process each synthetic text part matching mode-switch content
  for (const part of currentUser.parts) {
    if (!part.synthetic || part.type !== 'text') continue;
    if (!isModeSwitchContent(part.text || '')) continue;

    if (isTransition) {
      part.text = MODE_SWITCH_ANCHOR;
    } else {
      part.text = '';
      part.synthetic = false;
    }
  }
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

    return `### Plugin Diagnostics

**Warning:** The following plugin diagnostics were collected during session startup:

${entries}

**Must not proceed:** ERROR-level diagnostics detected. HALT immediately and resolve these errors.

**Mandatory actions:**
${actions}

Do NOT continue with any operations until ALL ERROR-level diagnostics are resolved.`;
  }

  return `### Plugin Diagnostics

**Warning:** The following plugin diagnostics were collected during session startup:

${entries}

Review these diagnostics. For errors, investigate the source script. For warnings, assess whether action is needed.`;
}

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

function runSessionInit(projectDir: string): string {
  try {
    const stdout = execSync("./.opencode/tools/session-init", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 30000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

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


/**
 * Build a formatted guidelines index block from INDEX.md for system prompt injection.
 * Reads the INDEX.md file and formats it as a compact routing reference.
 * Returns empty string if INDEX.md is missing or unreadable.
 */
function buildGuidelinesIndex(projectDir: string): string {
  const indexPath = path.join(projectDir, ".opencode", "guidelines", "INDEX.md");
  if (!fs.existsSync(indexPath)) return "";

  try {
    const content = fs.readFileSync(indexPath, "utf8");
    // Strip the heading and intro lines, keep only the table
    const tableMatch = content.match(/\|.*\|.*\|.*\|.*\|\n\|[-| ]+\|\n([\s\S]*)/);
    if (!tableMatch) return "";

    const tableBody = tableMatch[1].trim();
    return `### Guidelines Index (Progressive Disclosure)

Full guideline bodies are loaded on-demand by sub-agents when enforcement gates fire.
The orchestrator holds only this routing index. To load a specific guideline in a sub-agent,
use \`./.opencode/tools/guidelines read <filename>\`.

| Guideline | Tier | Trigger Pattern | Load When |
|-----------|------|-----------------|-----------|
${tableBody}`;
  } catch {
    return "";
  }
}

/**
 * Extract trigger patterns from a SKILL.md description field.
 * Descriptions contain "Triggers on:" followed by comma-separated keywords.
 */
function extractTriggerPatterns(description: string): string[] {
  const match = description.match(/Triggers\s+on:\s*([^]*?)(?:\n|$)/i);
  if (!match) return [];
  return match[1].split(",").map(t => t.trim()).filter(Boolean);
}

/**
 * Build a formatted skill index block for system prompt injection.
 * Reads all SKILL.md files, extracts name + description + trigger patterns.
 * Returns empty string if skills directory is missing.
 */
function buildSkillIndex(skillsDir: string): string {
  const { skills, errors } = loadSkillDescriptions(skillsDir);
  // Build a compact skill index table (name, description, trigger patterns)
  const skillRows = skills.map(s => {
    const triggers = extractTriggerPatterns(s.description);
    const triggersStr = triggers.length > 0 ? triggers.slice(0, 5).join(", ") : "—";
    return `| \`${s.name}\` | ${s.description} | ${triggersStr} |`;
  }).join("\n");

  if (skillRows.length === 0) return "";

  return `### Skill Index

| Skill | Description | Trigger Keywords |
|-------|-------------|------------------|
${skillRows}`;
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
 * Extract and strip YAML frontmatter from SKILL.md content.
 * Adapted from obra/superpowers/plugins/superpowers.js
 */
function extractFrontmatter(content: string): {
  frontmatter: Record<string, string>;
  body: string;
} {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { frontmatter: {}, body: content };

  const frontmatterStr = match[1];
  const body = match[2];
  const frontmatter: Record<string, string> = {};

  for (const line of frontmatterStr.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const value = line.slice(colonIdx + 1).trim().replace(/^["']|["']$/g, "");
      frontmatter[key] = value;
    }
  }

  return { frontmatter, body };
}

interface FrontmatterError {
  skillDir: string;
  issues: string[];
}

/**
 * Load skill descriptions from YAML frontmatter in SKILL.md files.
 * Adapted from obra/superpowers/plugins/superpowers.js skill discovery pattern.
 *
 * Source attribution: CSO (Content Search Optimization) principles from
 * https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 * Description format: "Use when..." with triggering conditions, NOT workflow summaries.
 *
 * Returns { skills, errors } where errors collects frontmatter validation issues.
 * See #601 for the original bug that motivated frontmatter validation.
 */
function loadSkillDescriptions(skillsDir: string): {
  skills: Array<{ name: string; description: string }>;
  errors: FrontmatterError[];
} {
  const skills: Array<{ name: string; description: string }> = [];
  const errors: FrontmatterError[] = [];

  try {
    const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillPath = path.join(skillsDir, entry.name, "SKILL.md");
      if (!fs.existsSync(skillPath)) continue;

      try {
        const content = fs.readFileSync(skillPath, "utf8");
        const validationIssues: string[] = [];

        const hasOpeningDelimiter = /^---\s*\n/m.test(content);
        const { frontmatter } = extractFrontmatter(content);

        if (!hasOpeningDelimiter) {
          validationIssues.push("Missing `---` opening delimiter");
        } else if (Object.keys(frontmatter).length === 0) {
          validationIssues.push("Delimiters present but no key:value pairs parsed (format error)");
        }

        if (hasOpeningDelimiter && !frontmatter.name) {
          validationIssues.push("Missing `name` field");
        }

        if (hasOpeningDelimiter && !frontmatter.description) {
          validationIssues.push("Missing `description` field — skill will be invisible to enforcement");
        } else if (frontmatter.description && !frontmatter.description.startsWith("Use when")) {
          validationIssues.push("Description does not start with \"Use when\" — CSO requirement for trigger discovery");
        }

        if (validationIssues.length > 0) {
          errors.push({ skillDir: entry.name, issues: validationIssues });
        }

        const name = frontmatter.name || entry.name;
        const description = frontmatter.description || "";
        if (description) {
          skills.push({ name, description });
        }
      } catch {
        // Skip unreadable skill files
      }
    }
  } catch {
    // Skills directory may not exist in all contexts
  }

  return { skills, errors };
}

/**
 * Build a structured warning string for frontmatter validation errors.
 * Returns empty string if no errors, so the caller can skip injection.
 * References #601 as the example bug that motivated this validation.
 */
function buildFrontmatterWarning(errors: FrontmatterError[]): string {
  if (errors.length === 0) return "";

  const perSkillListing = errors
    .map(e => `- **${e.skillDir}**: ${e.issues.join("; ")}`)
    .join("\n");

  return `### Frontmatter Validation

**Warning:** The following SKILL.md files have frontmatter issues that may make skills invisible to enforcement:

${perSkillListing}

**Fix template:** every SKILL.md MUST start with YAML frontmatter with name, description (starting with "Use when"), type, and license fields. See #601 for the original bug that motivated this validation.`;
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
 * Check if the current branch is a pair-mode branch (starts with "pair-").
 * Pair-mode branches allow direct edits on the development directory.
 */
function isPairModeBranch(branch: string): boolean {
  return branch.startsWith("pair-");
}

function getWorkingTreeStatus(projectDir: string): string {
  try {
    const status = execSync("git status --short", {
      cwd: projectDir,
      encoding: "utf8",
      input: "",
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    return status || "clean";
  } catch {
    return "unavailable";
  }
}

function buildPreImplementationGate(projectDir: string): string {
  const branch = getCurrentBranch(projectDir) || "unknown";
  const treeStatus = getWorkingTreeStatus(projectDir);
  const worktreePath = "none";
  return `### Pre-Implementation Gate

**Current state:** branch=${branch}, tree=${treeStatus}, worktree=${worktreePath}

**MANDATORY pre-implementation sequence (Tier 1 — HALT if not met):**
1. Invoke \`/skill approval-gate --task verify-authorization\`
2. Invoke \`/skill git-workflow --task pre-work\`
3. ALL file modifications go through \`/skill implementation-pipeline --task <step_label>\`
4. Direct edit/write tool calls in the orchestrator context are a CRITICAL VIOLATION`;
}

function buildCorePrinciplesBlock(): string {
  return `### Core Principles (Zero Tolerance)

1. **FAIL=FAIL** — No soft-passing, "functionally equivalent," or justifying FAIL→PASS.
2. **Auth gate** — Every change requires approved spec/plan. No exception, no matter how trivial.
3. **Mandatory skills** — \`/skill git-workflow\`, \`/skill implementation-pipeline\`, \`/skill verification-before-completion\`, \`/skill adversarial-audit\`. Not optional.
4. **TDD Red/Green** — Approval→pre-work→audit spec/plan→RED(test+audit; fail→fix, pass→commit)→GREEN(impl+audit; fail→fix+restart, pass→commit)→final spec/plan audit.
5. **Feedback ≠ Auth** — Feedback/clarification/technical input → update understanding, discuss, HALT. Never proceed to implementation.
6. **Dispatch via \`skill()\` + \`task()\` is the PRIMARY execution model** — Load every skill with \`skill()\`, dispatch execution with \`task()\`. The orchestrator routes and dispatches only; it never executes. A dispatcher that reads SKILL.md files and executes steps inline is not a dispatcher — it is an agent working without enforcement gates. Professional orchestrators dispatch; amateurs inline.
7. **Sub-agents are INTELLIGENT** — No bot-splaining, no tool-recipe dispatch. They read specs and use skills autonomously.
8. **Verify LIVE** — Never trust training data, memory, or metadata. Always verify via live docs, direct inspection, and verified test results.`;
}

function buildSubAgentPrinciplesBlock(): string {
  return `### Core Principles (Sub-Agent)

1. **FAIL=FAIL** — No soft-passing. Verify against live sources. Report PASS/FAIL truthfully.
2. **TDD discipline** — RED phase tests before GREEN phase implementation.
3. **Clean-room** — No inline fallback. If task context is contaminated (pre-determined findings, expected outcomes, orchestrator reasoning, tool recipes, line numbers), HALT and notify parent.
4. **Independent intelligence** — You are an autonomous agent. If the task contains excessive bot-splaining, rote instructions, or leading questions where your own analysis should apply, HALT and notify parent.
5. **Verify LIVE** — Never trust training data, memory, or metadata. Verify against live docs, direct inspection of source code/configs, and verified test results.
6. **Sub-agent role** — You are a sub-agent, not the orchestrator. Sub-agents execute single-step work units; orchestrators dispatch. A sub-agent that dispatches sub-agents is producing cascaded delegation instead of focused execution. If your assigned task requires sub-agent dispatch, return a \`NEEDS_ORCHESTRATOR\` status — the orchestrator will re-dispatch with the correct decomposition. Professional sub-agents execute their unit with focus; they do not become orchestrators.`;
}

function buildTier1EnforcementBlock(): string {
  return `### Tier 1 Mandate Enforcement Gate

The following mandates are NON-YIELDING — no developer authorization, emergency bypass, or override can waive them. This gate is injected by session-enforcement.ts and prescriptively enforces:

1. **No commits to \`main\` or \`dev\`** — Branch protection is a repository integrity concern. Always create a feature branch first.
2. **Human-only merge** — Agents must never merge PRs. Merge requires explicit human action.
3. **No \`/tmp/\` usage — \`./tmp/\` only** — Prevents system-level temp file leakage outside project scope.
4. **Path rules in worktree context** — When \`WORKTREE_REQUIRED\` is set, prefix ALL file operation paths with \`worktree.path\`. Relative paths silently target the main repo.
5. **Sub-agents must receive \`worktree.path\`** — Prevents sub-agents from mutating the main repo when the orchestrator is in worktree mode.
6. **Human-only branch deletion** — Unmerged branches must never be force-deleted by agents. Merged branches DELETE IMMEDIATELY.
7. **Agents must never self-authorize** — Authorization comes from developers, never from agent reasoning. Confirmation, feedback, and questions are not authorization.
8. **Git configuration and destructive commands require explicit authorization** — Remote mutations, config changes, force push, and destructive resets require explicit developer approval.
9. **Correctness over economy** — Fabrication or shortcutting verification to conserve context/tool-calls is prohibited. Sub-agent dispatch and tool calls are near-zero cost. A fast wrong answer is strictly worse than a slow correct one.

Violations of mandates 1-6 and 8 are detected at runtime by this plugin and flagged via enforcement blocks. See \`000-critical-rules.md\` Tier 1 table for full rationale and symbolic rule definitions.`;
}

export default async function sessionEnforcementPlugin(input: PluginInput): Promise<Hooks> {
  // Determine skills directory and project directory
  const projectDir = input?.directory || process.cwd();
  const skillsDir = path.join(projectDir, ".opencode", "skills");

  // Pre-load skill descriptions and frontmatter validation at plugin startup
  const { errors: frontmatterErrors } = loadSkillDescriptions(skillsDir);

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

      const scriptOutput = runSessionInit(projectDir);
      if (scriptOutput) {
        output.system.push(scriptOutput);
      }

      // Inject worktree context when session is operating in a worktree
      const worktreeBlock = buildWorktreeBlock(input);
      if (worktreeBlock) {
        output.system.push(worktreeBlock);
      }

      // Inject guidelines index (INDEX.md) instead of full guideline bodies
      const guidelinesIndex = buildGuidelinesIndex(projectDir);
      if (guidelinesIndex) {
        output.system.push(guidelinesIndex);
      }

      // Inject skill index (name + description + trigger patterns from SKILL.md frontmatter)
      const skillIndex = buildSkillIndex(skillsDir);
      if (skillIndex) {
        output.system.push(skillIndex);
      }

      // Inject frontmatter validation warning if any skills have broken frontmatter
      const warning = buildFrontmatterWarning(frontmatterErrors);
      if (warning) {
        output.system.push(warning);
      }

    },

    // Inject enforcement content into first user message (adapted from obra/superpowers)
      // AND detect bare #N issue references in last user message
      // AND inject trigger warnings into first user message
      // AND inject plugin diagnostics block into first user message
      //
      // FIRST-TURN GUARD: EXTREMELY_IMPORTANT, SESSION_TRIGGERS, and
      // PLUGIN_DIAGNOSTICS are injected ONLY on the first turn of PRIMARY
      // sessions (isFirstTurn && !isSubAgent). Sub-agent sessions inherit
      // context from their parent, so these blocks are redundant and waste
      // context window space (REQ-1/REQ-2).
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
          // --- Spec #432: Pre-Implementation Gate + Core Principles ---
          const gateBlock = buildPreImplementationGate(projectDir);
          const corePrinciplesBlock = buildCorePrinciplesBlock();
          const tier1Block = buildTier1EnforcementBlock();

          // Per spec #426: extract NESTED_OPENCODE_FATAL from triggers output
          // and inject it as a SEPARATE block (not inside Session Triggers)
          let triggerOutputForSessionBlock = triggersOutput || "";
          let nestedOpencodeBlock = "";
          const nestedFatalMatch = triggerOutputForSessionBlock.match(/### NESTED_OPENCODE_FATAL[\s\S]*?(?=\n### |\n\n### |\n*$)/);
          if (nestedFatalMatch) {
            nestedOpencodeBlock = nestedFatalMatch[0].trim();
            // Remove the nested opencode block from the session triggers output
            triggerOutputForSessionBlock = triggerOutputForSessionBlock.replace(nestedFatalMatch[0], "").trim();
          }
          // Also match if it's the only/last section (no trailing ###)
          if (!nestedOpencodeBlock) {
            const nestedFatalOnlyMatch = triggersOutput?.match(/### NESTED_OPENCODE_FATAL[\s\S]*/);
            if (nestedFatalOnlyMatch) {
              nestedOpencodeBlock = nestedFatalOnlyMatch[0].trim();
              triggerOutputForSessionBlock = triggerOutputForSessionBlock.replace(nestedFatalOnlyMatch[0], "").trim();
            }
          }

          const triggerBlock = triggerOutputForSessionBlock ? `### Session Triggers\n\n${triggerOutputForSessionBlock}` : "";

          const echoParts: string[] = [];
          if (gateBlock) {
            echoParts.push(gateBlock);
          }
          if (tier1Block) {
            echoParts.push(tier1Block);
          }
          if (corePrinciplesBlock) {
            echoParts.push(corePrinciplesBlock);
          }
          if (triggerBlock) {
            echoParts.push(triggerBlock);
          }
          if (echoParts.length > 0 && firstUser.parts?.length) {
            firstUser.parts.unshift({ type: "text", text: echoParts.join("\n\n") });
          }

          // Per spec #426 SC-10: Inject NESTED_OPENCODE_FATAL as a separate block
          // AFTER all other content in the first user message (not inside Session Triggers)
          if (nestedOpencodeBlock && firstUser.parts?.length) {
            firstUser.parts.push({ type: "text", text: nestedOpencodeBlock });
          }

          // --- First-turn-only: Plugin diagnostics injection ---
          const diagnostics = collectDiagnostics(projectDir);
          const diagnosticBlock = buildDiagnosticBlock(diagnostics);
          if (diagnosticBlock && firstUser.parts?.length) {
            firstUser.parts.push({ type: "text", text: diagnosticBlock });
          }

        }

        // --- Spec #432: First-turn-only SUB-AGENT sessions: Core Principles ---
        // Sub-agents receive a lighter 5-rule principles block as the first text
        // part injected into their first user message. No identity echo, no triggers.
        if (isFirstTurn && isSubAgent && firstUser.parts?.length) {
          const subAgentPrinciplesBlock = buildSubAgentPrinciplesBlock();
          firstUser.parts.unshift({ type: "text", text: subAgentPrinciplesBlock });
        }

      // --- Per-turn: Mode switch anchor replacement ---
      // Replaces core-injected build-switch.txt and plan.txt with compliance anchor
      // on transition turns; strips on non-transition re-injections.
      handleModeSwitchParts(output.messages);

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

      // --- Per-turn: --no-verify detection REMOVED ---
      // Removed per SPEC-FIX #823: The unconditional --no-verify detection gate
      // contradicts the guidelines (000-critical-rules.md §Hook Output Is Advisory,
      // Not Absolute and §--no-verify Exception for Local-Only Repos) which state
      // that --no-verify usage requires judgment and may be warranted for false
      // positive hook blocks, tag pushes, and developer-authorized overrides.
      // The 010-approval-gate.md Allowlist already governs when --no-verify is
      // permissible. This gate was producing Tier 1 violation warnings for
      // legitimate --no-verify usage (e.g., tag pushes blocked by the pre-push
      // hook false positive, structural branch pushes like issues-data), causing
      // repeated workflow failures.

      // --- Per-turn: Inline work detector (Gate 3) ---
      // Detect when the orchestrator performed file-editing tool calls without
      // a preceding sub-agent dispatch in the same turn. Exemptions: sub-agent
      // sessions, pair-* branches, .issues/ only changes.
      const currentBranchForInline = getCurrentBranch(projectDir);
      const isPairBranch = currentBranchForInline ? isPairModeBranch(currentBranchForInline) : false;
      if (!isSubAgent && !isPairBranch) {
        for (const msg of assistantMessages) {
          if (!msg.parts?.length) continue;
          const editToolNames: string[] = [];
          let dispatchFound = false;
          let dispatchIndex = -1;
          let issuesOnlyEdits = true;

          for (const part of msg.parts) {
            if (part.type === "text" && part.text) {
              // Detect sub-agent dispatch (task tool)
              if (part.text.includes("subagent_type") || part.text.includes('"task"') && part.text.includes("dispatch")) {
                dispatchFound = true;
                if (dispatchIndex === -1) dispatchIndex = msg.parts.indexOf(part);
              }
              // Detect file-editing tool calls
              const editMatch = part.text.match(/"name"\s*:\s*"(edit|write|create_or_update_file)"/);
              if (editMatch) {
                editToolNames.push(editMatch[1]);
                // Check if the edit targets .issues/ files
                const filePathMatch = part.text.match(/"filePath"\s*:\s*"([^"]+)"/);
                if (filePathMatch && !filePathMatch[1].startsWith(".issues/")) {
                  issuesOnlyEdits = false;
                }
              }
              // Also detect tool call patterns in assistant text (older format)
              const toolCallMatch = part.text.match(/(edit|write)\(filePath/);
              if (toolCallMatch) {
                editToolNames.push(toolCallMatch[1]);
                const filePathMatch = part.text.match(/filePath["']?\s*[:=]\s*["']([^"']+)/);
                if (filePathMatch && !filePathMatch[1].startsWith(".issues/")) {
                  issuesOnlyEdits = false;
                }
              }
            }
          }

          if (editToolNames.length > 0 && !issuesOnlyEdits) {
            // If dispatch was found, check if edits came before the dispatch
            const editsBeforeDispatch = dispatchFound && dispatchIndex > -1
              ? editToolNames.length > 0 // edits exist, check if any were before dispatch
              : true;

            if (!dispatchFound || editsBeforeDispatch) {
              const block = buildInlineWorkDetectedBlock(editToolNames, dispatchFound);
              const nextUser = userMessages[userMessages.length - 1];
              if (nextUser?.parts?.length) {
                nextUser.parts.push({ type: "text", text: block });
              }
            }
          }
        }
      }

      // --- Per-turn: Evidence gate (Gate 4) ---
      // Detect issue closure attempts without verification evidence table.
      // Exemptions: not_planned, duplicate, rollback-reopen state reasons.
      for (const msg of assistantMessages) {
        if (!msg.parts?.length) continue;
        for (const part of msg.parts) {
          if (part.type === "text" && part.text) {
            // Detect github_issue_write with state=closed
            const closureMatch = part.text.match(/state.*closed|state.*:.*"closed"/i);
            if (closureMatch) {
              // Check for exempt state reasons
              const exemptReason = part.text.match(/state_reason.*(?:not_planned|duplicate)/i);
              if (!exemptReason) {
                // Check if a verification evidence table exists in recent messages
                const allAssistantText = assistantMessages
                  .map(m => m.parts?.filter(p => p.type === "text" && p.text).map(p => p.text).join(" ") || "")
                  .join(" ");
                const hasEvidence = allAssistantText.includes("PASS") &&
                  (allAssistantText.includes("Success Criteria") || allAssistantText.includes("verification") || allAssistantText.includes("evidence"));

                if (!hasEvidence) {
                  // Also check for rollback-reopen marker
                  const rollbackReopen = part.text.match(/\[ROLLBACK-REOPEN\]/i);
                  if (!rollbackReopen) {
                    const block = buildEvidenceGateBlock();
                    const nextUser = userMessages[userMessages.length - 1];
                    if (nextUser?.parts?.length) {
                      nextUser.parts.push({ type: "text", text: block });
                    }
                  }
                }
              }
            }
          }
        }
      }


    },
  };
}
