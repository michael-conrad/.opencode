// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated
//
// Co-authored with AI: OpenCode (deepseek-v4-flash-free)

import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

interface PluginContext {
  project?: any;
  client: any;
  $?: any;
  directory?: string;
  worktree?: string;
}

interface RetryState {
  sessionID: string;
  model: string;
  originalModel: string;
  originalPrompt: string;
  attempt: number;
  exhausted: boolean;
  lastActivity: number;
  lastNonTimeoutError: boolean;
}

interface Config {
  baseDelayMs: number;
  maxDelayMs: number;
  maxRetries: number;
  nextModel: string | null;
  enabled: boolean;
  errorPatterns: string[];
  skipPatterns: string[];
  debugLogging: boolean;
  toastRetry: string;
  toastSuccess: string;
  toastFailure: string;
}

const DEFAULT_CONFIG: Config = {
  baseDelayMs: 3000,
  maxDelayMs: 30000,
  maxRetries: 3,
  nextModel: null,
  enabled: true,
  errorPatterns: [
    'timeout', 'network', 'gateway', 'dns', 'ssl',
    'connection error', 'enotfound', 'econnrefused', 'socket hang up',
  ],
  skipPatterns: [
    'partial_output', 'model_rejected', 'rejected', 'cancelled_by_user',
    'ProviderAuthError', '401', '403', '429',
    'authentication', 'unauthorized', 'invalid api key', 'invalid x-api-key',
  ],
  debugLogging: false,
  toastRetry: 'Retry {attempt}/{max} — {delay}ms',
  toastSuccess: 'Retry succeeded on attempt {attempt}',
  toastFailure: 'All {max} retries failed',
};

const logDebug = (client: any, message: string, config: Config): void => {
  if (config.debugLogging) {
    client.app.log({ body: { message: `[opencode-retry-timeout] ${message}` } });
  }
};

const showToast = (client: any, message: string, variant: string): void => {
  client.tui.showToast({ body: { message, variant } });
};

const extractError = (error: any): string => {
  if (typeof error === 'string') return error;
  return error?.data?.message ?? error?.data?.responseBody ?? error?.message ?? error?.name ?? String(error);
};

const calculateBackoff = (attempt: number, baseDelayMs: number, maxDelayMs: number): number => {
  const delay = Math.min(baseDelayMs * Math.pow(2, attempt), maxDelayMs);
  return Math.round(delay * (1 + Math.random() * 0.25));
};

const classifyError = (errorMsg: string, config: Config): { retryable: boolean; reason: string } => {
  const m = errorMsg.toLowerCase();
  for (const skip of config.skipPatterns) {
    if (m.includes(skip.toLowerCase())) {
      return { retryable: false, reason: `Skip: ${skip}` };
    }
  }
  for (const pat of config.errorPatterns) {
    if (m.includes(pat.toLowerCase())) {
      return { retryable: true, reason: `Match: ${pat}` };
    }
  }
  return { retryable: false, reason: 'No match' };
};

function transformUserPartToPartInput(part: any): any {
  const keepTypes = new Set(['text', 'file', 'agent', 'subtask']);
  if (part.type && !keepTypes.has(part.type)) return null;

  const serverFields = new Set(['id', 'sessionID', 'messageID']);
  const result: any = {};
  for (const [key, value] of Object.entries(part)) {
    if (!serverFields.has(key)) {
      result[key] = value;
    }
  }
  return result;
}

const getSessionMessages = async (client: any, sessionID: string): Promise<any[]> => {
  try {
    const raw = await client.session.messages({ path: { id: sessionID } });
    return Array.isArray(raw) ? raw : (raw?.data ?? []);
  } catch {
    return [];
  }
};

const findLastUserParts = (messages: any[]): any[] | null => {
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i]?.role === 'user') {
      const parts = messages[i].parts ?? [];
      const transformed = parts
        .map((p: any) => transformUserPartToPartInput(p))
        .filter((p: any) => p !== null);
      return transformed.length > 0 ? transformed : null;
    }
  }
  return null;
};

const loadConfigFile = async (configPath: string): Promise<Partial<Config> | { error: string } | null> => {
  try {
    const raw = await fs.promises.readFile(configPath, 'utf-8');
    return JSON.parse(raw) as Partial<Config>;
  } catch (err) {
    if (err instanceof SyntaxError) {
      return { error: 'Malformed JSON' };
    }
    return null;
  }
};

const resolveProjectConfigPath = (ctx: PluginContext): string => {
  if (ctx.$?.resolve) {
    return ctx.$.resolve('.opencode/opencode-retry-timeout.json');
  }
  if (ctx.directory) {
    return path.join(ctx.directory, '.opencode', 'opencode-retry-timeout.json');
  }
  return path.join(process.cwd(), '.opencode', 'opencode-retry-timeout.json');
};

const loadConfig = async (ctx: PluginContext): Promise<Config | null> => {
  const config: Config = { ...DEFAULT_CONFIG };
  const homePath = path.join(os.homedir(), '.config', 'opencode', 'opencode-retry-timeout.json');
  const projectPath = resolveProjectConfigPath(ctx);

  for (const cfgPath of [homePath, projectPath]) {
    const partial = await loadConfigFile(cfgPath);
    if (partial) {
      if ('error' in partial) {
        showToast(ctx.client, 'opencode-retry-timeout: malformed config ' + cfgPath, 'error');
        logDebug(ctx.client, 'Malformed config at ' + cfgPath + ': ' + partial.error, config);
        continue;
      }
      Object.assign(config, partial);
    }
  }

  return config;
};

export const OpenCodeRetryTimeout = async (
  ctx: PluginContext,
): Promise<{ event: (params: { event: any }) => Promise<void> }> => {
  let config: Config;

  try {
    const loaded = await loadConfig(ctx);
    config = loaded ?? { ...DEFAULT_CONFIG };
  } catch (err) {
    config = { ...DEFAULT_CONFIG };
    logDebug(ctx.client, `Config load error, using defaults: ${String(err)}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: config load failed, using defaults', 'error');
  }

  if (!config.enabled) {
    logDebug(ctx.client, 'Plugin disabled by config', config);
  }

  const retryStates = new Map<string, RetryState>();
  const sessionModels = new Map<string, string>();
  const retryingSessions = new Set<string>();

  return {
    event: async ({ event }: { event: any }): Promise<void> => {
      if (!event?.type) return;

      if (event.type === 'message.updated') {
        const { sessionID, message } = event.properties ?? {};
        if (sessionID && message) {
          if (message.info?.model?.providerID && message.info?.model?.modelID) {
            sessionModels.set(sessionID, `${message.info.model.providerID}/${message.info.model.modelID}`);
          } else if (message.info?.providerID && message.info?.modelID) {
            sessionModels.set(sessionID, `${message.info.providerID}/${message.info.modelID}`);
          }
        }
        return;
      }

      if (event.type === 'session.idle') {
        const { sessionID } = event.properties ?? {};
        if (!sessionID) return;

        const state = retryStates.get(sessionID);
        if (!state) return;

        const idleTime = Date.now() - state.lastActivity;
        if (!state.exhausted && !state.lastNonTimeoutError) {
          state.attempt = 0;
        }
        if (idleTime > 300000) {
          state.attempt = 0;
          state.exhausted = false;
        }
        return;
      }

      if (event.type === 'session.error') {
        await handleSessionError(ctx, event, config, retryStates, sessionModels, retryingSessions);
        return;
      }
    },
  };
};

const handleSessionError = async (
  ctx: PluginContext,
  event: any,
  config: Config,
  retryStates: Map<string, RetryState>,
  sessionModels: Map<string, string>,
  retryingSessions: Set<string>,
): Promise<void> => {
  if (!config.enabled) return;

  const { sessionID, error } = event.properties ?? {};

  if (!sessionID) {
    showToast(ctx.client, 'opencode-retry-timeout: missing sessionID', 'error');
    logDebug(ctx.client, 'Missing sessionID in session.error', config);
    return;
  }

  const errorMsg = extractError(error);
  logDebug(ctx.client, `Error: ${sessionID} — ${errorMsg}`, config);

  const decision = classifyError(errorMsg, config);
  logDebug(ctx.client, `Classify: ${sessionID} retryable=${decision.retryable} reason=${decision.reason}`, config);

  if (!decision.retryable) {
    const state = retryStates.get(sessionID);
    if (state) {
      state.lastNonTimeoutError = true;
    }
    showToast(ctx.client, `opencode-retry-timeout: ${decision.reason}`, 'error');
    return;
  }

  const state = retryStates.get(sessionID);

  if (state && Date.now() - state.lastActivity > 300000) {
    logDebug(ctx.client, `Stale session ${sessionID}: reset attempts`, config);
    state.attempt = 0;
    state.exhausted = false;
  }

  if (state?.exhausted) {
    logDebug(ctx.client, `Already exhausted ${sessionID}, skipping`, config);
    return;
  }

  if (retryingSessions.has(sessionID)) return;
  retryingSessions.add(sessionID);

  try {
    await executeRetry(ctx, sessionID, config, retryStates, sessionModels);
  } finally {
    retryingSessions.delete(sessionID);
  }
};

const executeRetry = async (
  ctx: PluginContext,
  sessionID: string,
  config: Config,
  retryStates: Map<string, RetryState>,
  sessionModels: Map<string, string>,
): Promise<void> => {
  const messagesData = await getSessionMessages(ctx.client, sessionID);

  if (!messagesData || messagesData.length === 0) {
    logDebug(ctx.client, `Empty messages for ${sessionID}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: no messages found', 'error');
    return;
  }

  for (let i = messagesData.length - 1; i >= 0; i--) {
    if (messagesData[i].role === 'assistant') {
      if (messagesData[i].time?.completed && messagesData[i].error) {
        showToast(ctx.client, 'opencode-retry-timeout: completed-with-error', 'error');
        logDebug(ctx.client, `Completed-with-error assistant detected for ${sessionID}`, config);
        return;
      }
      break;
    }
  }

  const lastUserParts = findLastUserParts(messagesData);
  if (!lastUserParts) {
    logDebug(ctx.client, `No user message found in ${sessionID}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: no user message found', 'error');
    return;
  }

  const model = sessionModels.get(sessionID) || 'default';

  let state = retryStates.get(sessionID);
  if (!state) {
    state = {
      sessionID,
      model,
      originalModel: model,
      originalPrompt: JSON.stringify(lastUserParts),
      attempt: 0,
      exhausted: false,
      lastActivity: Date.now(),
      lastNonTimeoutError: false,
    };
    retryStates.set(sessionID, state);
  } else {
    state.lastActivity = Date.now();
  }

  if (state.exhausted) return;

  let attempt = state.attempt;
  let success = false;

  while (attempt < config.maxRetries && !success) {
    const delay = calculateBackoff(attempt, config.baseDelayMs, config.maxDelayMs);

    let currentModel = state.originalModel;
    if (attempt >= 1 && config.nextModel) {
      currentModel = currentModel === config.nextModel ? state.originalModel : config.nextModel;
    }
    state.model = currentModel;
    state.attempt = attempt;
    state.lastActivity = Date.now();

    const retryToast = config.toastRetry
      .replace(/\{attempt\}/g, String(attempt + 1))
      .replace(/\{max\}/g, String(config.maxRetries))
      .replace(/\{delay\}/g, String(delay));
    showToast(ctx.client, retryToast, 'info');

    logDebug(
      ctx.client,
      `Retry ${attempt + 1}/${config.maxRetries} ${sessionID} delay=${delay}ms model=${currentModel}`,
      config,
    );

    await new Promise<void>((r) => setTimeout(r, delay));

    try {
      await ctx.client.session.revert({ path: { id: sessionID }, body: {} });
      logDebug(ctx.client, `Revert OK ${sessionID}`, config);
    } catch (revertErr) {
      const msg = extractError(revertErr);
      logDebug(ctx.client, `Revert failed ${sessionID}: ${msg}`, config);
      showToast(ctx.client, 'opencode-retry-timeout: revert failed', 'error');
      state.exhausted = true;
      state.lastActivity = Date.now();
      return;
    }

    try {
      await ctx.client.session.prompt({
        path: { id: sessionID },
        body: { parts: lastUserParts, model: currentModel },
      });

      success = true;
      const successToast = config.toastSuccess.replace(/\{attempt\}/g, String(attempt + 1));
      showToast(ctx.client, successToast, 'success');

      logDebug(ctx.client, `Success ${sessionID} on attempt ${attempt + 1}`, config);
      retryStates.delete(sessionID);
    } catch (promptErr) {
      const promptErrorMsg = extractError(promptErr);
      const promptDecision = classifyError(promptErrorMsg, config);

      attempt++;
      state.attempt = attempt;
      state.lastActivity = Date.now();

      if (!promptDecision.retryable) {
        logDebug(ctx.client, `Non-retryable error during retry ${sessionID}: ${promptErrorMsg}`, config);
        showToast(ctx.client, 'opencode-retry-timeout: non-retryable error during retry', 'error');
        state.exhausted = true;
        state.lastNonTimeoutError = true;
        return;
      }

      if (attempt >= config.maxRetries) {
        const failToast = config.toastFailure.replace(/\{max\}/g, String(config.maxRetries));
        showToast(ctx.client, failToast, 'error');
        state.exhausted = true;
        state.lastActivity = Date.now();
        logDebug(ctx.client, `Exhausted ${sessionID} after ${config.maxRetries} attempts`, config);
        return;
      }

      logDebug(ctx.client, `Retry ${attempt}/${config.maxRetries} ${sessionID}: ${promptErrorMsg}`, config);
    }
  }
};
