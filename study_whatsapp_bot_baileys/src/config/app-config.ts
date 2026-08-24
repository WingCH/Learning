import { resolve } from "node:path";

export type LogLevel =
  | "fatal"
  | "error"
  | "warn"
  | "info"
  | "debug"
  | "trace"
  | "silent";

export interface AppConfig {
  readonly botName: string;
  readonly authDirectory: string;
  readonly qrOutputPath: string;
  readonly logLevel: LogLevel;
  readonly replyToGroups: boolean;
  readonly maxReconnectAttempts: number;
  readonly reconnectBaseDelayMs: number;
  readonly reconnectMaxDelayMs: number;
  readonly maxMessageStoreEntries: number;
  readonly openRouter: OpenRouterConfig;
  readonly conversationHistory: ConversationHistoryConfig;
  readonly responseDelay: ResponseDelayConfig;
}

export interface ResponseDelayConfig {
  readonly minimumMs: number;
  readonly maximumMs: number;
}

export interface OpenRouterConfig {
  readonly apiKey: string;
  readonly model: string;
  readonly endpoint: string;
  readonly requestTimeoutMs: number;
  readonly httpReferer: string | null;
  readonly appTitle: string;
}

export interface ConversationHistoryConfig {
  readonly filePath: string;
  readonly legacyFilePath: string;
  readonly maxChats: number;
  readonly compactionTriggerTurns: number;
  readonly compactionTriggerCharacters: number;
  readonly keepRecentTurns: number;
  readonly maxSummaryCharacters: number;
  readonly hardMaxTurnsPerChat: number;
  readonly hardMaxCharactersPerChat: number;
  readonly summaryModel: string;
}

const logLevels = new Set<LogLevel>([
  "fatal",
  "error",
  "warn",
  "info",
  "debug",
  "trace",
  "silent",
]);

const defaults = {
  botName: "Personal WhatsApp Bot",
  authDirectory: ".data/whatsapp-auth",
  qrOutputPath: ".data/latest-whatsapp-qr.txt",
  logLevel: "info",
  replyToGroups: false,
  maxReconnectAttempts: 8,
  reconnectBaseDelayMs: 1_000,
  reconnectMaxDelayMs: 30_000,
  maxMessageStoreEntries: 1_000,
  openRouterModel: "@preset/whatsapp-auto-reply",
  openRouterEndpoint: "https://openrouter.ai/api/v1/chat/completions",
  openRouterRequestTimeoutMs: 30_000,
  conversationMemoryPath: ".data/conversation-memory.json",
  conversationMemoryLegacyPath: ".data/conversation-memory-legacy.json",
  conversationHistoryMaxChats: 100,
  conversationCompactionTriggerTurns: 20,
  conversationCompactionTriggerCharacters: 12_000,
  conversationKeepRecentTurns: 8,
  conversationMaxSummaryCharacters: 4_000,
  conversationHardMaxTurnsPerChat: 40,
  conversationHardMaxCharactersPerChat: 24_000,
  responseDelayMinimumMs: 2_000,
  responseDelayMaximumMs: 5_000,
} as const;

export function loadAppConfig(
  environment: NodeJS.ProcessEnv,
  workingDirectory: string,
): AppConfig {
  const authDirectory = environment.WHATSAPP_AUTH_DIR?.trim() || defaults.authDirectory;
  const qrOutputPath =
    environment.WHATSAPP_QR_OUTPUT_PATH?.trim() || defaults.qrOutputPath;

  const config: AppConfig = {
    botName: environment.BOT_NAME?.trim() || defaults.botName,
    authDirectory: resolve(workingDirectory, authDirectory),
    qrOutputPath: resolve(workingDirectory, qrOutputPath),
    logLevel: parseLogLevel(environment.LOG_LEVEL),
    replyToGroups: parseBoolean(
      "REPLY_TO_GROUPS",
      environment.REPLY_TO_GROUPS,
      defaults.replyToGroups,
    ),
    maxReconnectAttempts: parsePositiveInteger(
      "MAX_RECONNECT_ATTEMPTS",
      environment.MAX_RECONNECT_ATTEMPTS,
      defaults.maxReconnectAttempts,
    ),
    reconnectBaseDelayMs: parsePositiveInteger(
      "RECONNECT_BASE_DELAY_MS",
      environment.RECONNECT_BASE_DELAY_MS,
      defaults.reconnectBaseDelayMs,
    ),
    reconnectMaxDelayMs: parsePositiveInteger(
      "RECONNECT_MAX_DELAY_MS",
      environment.RECONNECT_MAX_DELAY_MS,
      defaults.reconnectMaxDelayMs,
    ),
    maxMessageStoreEntries: parsePositiveInteger(
      "MAX_MESSAGE_STORE_ENTRIES",
      environment.MAX_MESSAGE_STORE_ENTRIES,
      defaults.maxMessageStoreEntries,
    ),
    openRouter: {
      apiKey: parseRequiredString(
        "OPENROUTER_API_KEY",
        environment.OPENROUTER_API_KEY,
      ),
      model:
        environment.OPENROUTER_MODEL?.trim() || defaults.openRouterModel,
      endpoint: parseHttpsUrl(
        "OPENROUTER_ENDPOINT",
        environment.OPENROUTER_ENDPOINT?.trim() || defaults.openRouterEndpoint,
      ),
      requestTimeoutMs: parsePositiveInteger(
        "OPENROUTER_REQUEST_TIMEOUT_MS",
        environment.OPENROUTER_REQUEST_TIMEOUT_MS,
        defaults.openRouterRequestTimeoutMs,
      ),
      httpReferer: parseOptionalHttpUrl(
        "OPENROUTER_HTTP_REFERER",
        environment.OPENROUTER_HTTP_REFERER,
      ),
      appTitle: environment.BOT_NAME?.trim() || defaults.botName,
    },
    conversationHistory: {
      filePath: resolve(
        workingDirectory,
        environment.CONVERSATION_MEMORY_PATH?.trim() ||
          defaults.conversationMemoryPath,
      ),
      legacyFilePath: resolve(
        workingDirectory,
        defaults.conversationMemoryLegacyPath,
      ),
      maxChats: parsePositiveInteger(
        "CONVERSATION_HISTORY_MAX_CHATS",
        environment.CONVERSATION_HISTORY_MAX_CHATS,
        defaults.conversationHistoryMaxChats,
      ),
      compactionTriggerTurns: parsePositiveInteger(
        "CONVERSATION_COMPACTION_TRIGGER_TURNS",
        environment.CONVERSATION_COMPACTION_TRIGGER_TURNS ??
          environment.CONVERSATION_HISTORY_MAX_TURNS_PER_CHAT,
        defaults.conversationCompactionTriggerTurns,
      ),
      compactionTriggerCharacters: parsePositiveInteger(
        "CONVERSATION_COMPACTION_TRIGGER_CHARACTERS",
        environment.CONVERSATION_COMPACTION_TRIGGER_CHARACTERS ??
          environment.CONVERSATION_HISTORY_MAX_CHARACTERS_PER_CHAT,
        defaults.conversationCompactionTriggerCharacters,
      ),
      keepRecentTurns: parsePositiveInteger(
        "CONVERSATION_COMPACTION_KEEP_RECENT_TURNS",
        environment.CONVERSATION_COMPACTION_KEEP_RECENT_TURNS,
        defaults.conversationKeepRecentTurns,
      ),
      maxSummaryCharacters: parsePositiveInteger(
        "CONVERSATION_MAX_SUMMARY_CHARACTERS",
        environment.CONVERSATION_MAX_SUMMARY_CHARACTERS,
        defaults.conversationMaxSummaryCharacters,
      ),
      hardMaxTurnsPerChat: parsePositiveInteger(
        "CONVERSATION_HARD_MAX_TURNS_PER_CHAT",
        environment.CONVERSATION_HARD_MAX_TURNS_PER_CHAT,
        defaults.conversationHardMaxTurnsPerChat,
      ),
      hardMaxCharactersPerChat: parsePositiveInteger(
        "CONVERSATION_HARD_MAX_CHARACTERS_PER_CHAT",
        environment.CONVERSATION_HARD_MAX_CHARACTERS_PER_CHAT,
        defaults.conversationHardMaxCharactersPerChat,
      ),
      summaryModel:
        environment.OPENROUTER_SUMMARY_MODEL?.trim() ||
        environment.OPENROUTER_MODEL?.trim() ||
        defaults.openRouterModel,
    },
    responseDelay: {
      minimumMs: parseNonNegativeInteger(
        "AI_RESPONSE_DELAY_MIN_MS",
        environment.AI_RESPONSE_DELAY_MIN_MS,
        defaults.responseDelayMinimumMs,
      ),
      maximumMs: parseNonNegativeInteger(
        "AI_RESPONSE_DELAY_MAX_MS",
        environment.AI_RESPONSE_DELAY_MAX_MS,
        defaults.responseDelayMaximumMs,
      ),
    },
  };

  if (config.reconnectBaseDelayMs > config.reconnectMaxDelayMs) {
    throw new Error(
      "RECONNECT_BASE_DELAY_MS 不可大於 RECONNECT_MAX_DELAY_MS。",
    );
  }
  validateConversationHistoryConfig(config.conversationHistory);
  if (config.responseDelay.minimumMs > config.responseDelay.maximumMs) {
    throw new Error(
      "AI_RESPONSE_DELAY_MIN_MS 不可大於 AI_RESPONSE_DELAY_MAX_MS。",
    );
  }

  return config;
}

function validateConversationHistoryConfig(
  config: ConversationHistoryConfig,
): void {
  if (config.filePath === config.legacyFilePath) {
    throw new Error("Conversation memory file 不可與 legacy migration file 相同。");
  }
  if (config.keepRecentTurns >= config.compactionTriggerTurns) {
    throw new Error(
      "CONVERSATION_COMPACTION_KEEP_RECENT_TURNS 必須小於 trigger turns。",
    );
  }
  if (config.compactionTriggerTurns > config.hardMaxTurnsPerChat) {
    throw new Error("Conversation compaction turn trigger 不可大於 hard max。");
  }
  if (
    config.compactionTriggerCharacters > config.hardMaxCharactersPerChat
  ) {
    throw new Error(
      "Conversation compaction character trigger 不可大於 hard max。",
    );
  }
  if (config.maxSummaryCharacters > config.hardMaxCharactersPerChat) {
    throw new Error("Conversation summary 上限不可大於 character hard max。");
  }
}

function parseRequiredString(
  name: string,
  value: string | undefined,
): string {
  const normalizedValue = value?.trim();
  if (!normalizedValue) {
    throw new Error(`缺少必要設定：${name}。`);
  }
  return normalizedValue;
}

function parseHttpsUrl(name: string, value: string): string {
  const parsedUrl = parseUrl(name, value);
  if (parsedUrl.protocol !== "https:") {
    throw new Error(`${name} 必須使用 https。`);
  }
  return parsedUrl.toString();
}

function parseOptionalHttpUrl(
  name: string,
  value: string | undefined,
): string | null {
  const normalizedValue = value?.trim();
  if (!normalizedValue) {
    return null;
  }

  const parsedUrl = parseUrl(name, normalizedValue);
  if (parsedUrl.protocol !== "https:" && parsedUrl.protocol !== "http:") {
    throw new Error(`${name} 必須使用 http 或 https。`);
  }
  return parsedUrl.toString();
}

function parseUrl(name: string, value: string): URL {
  try {
    return new URL(value);
  } catch (error: unknown) {
    throw new Error(`${name} 必須是有效 URL。`, { cause: error });
  }
}

function parseLogLevel(value: string | undefined): LogLevel {
  const normalizedValue = value?.trim().toLowerCase() || defaults.logLevel;

  if (!logLevels.has(normalizedValue as LogLevel)) {
    throw new Error(`LOG_LEVEL 無效：${normalizedValue}`);
  }

  return normalizedValue as LogLevel;
}

function parseBoolean(
  name: string,
  value: string | undefined,
  fallback: boolean,
): boolean {
  if (value === undefined || value.trim() === "") {
    return fallback;
  }

  const normalizedValue = value.trim().toLowerCase();
  if (normalizedValue === "true") {
    return true;
  }
  if (normalizedValue === "false") {
    return false;
  }

  throw new Error(`${name} 必須是 true 或 false。`);
}

function parsePositiveInteger(
  name: string,
  value: string | undefined,
  fallback: number,
): number {
  if (value === undefined || value.trim() === "") {
    return fallback;
  }

  const parsedValue = Number(value);
  if (!Number.isSafeInteger(parsedValue) || parsedValue <= 0) {
    throw new Error(`${name} 必須是正整數。`);
  }

  return parsedValue;
}

function parseNonNegativeInteger(
  name: string,
  value: string | undefined,
  fallback: number,
): number {
  if (value === undefined || value.trim() === "") {
    return fallback;
  }

  const parsedValue = Number(value);
  if (!Number.isSafeInteger(parsedValue) || parsedValue < 0) {
    throw new Error(`${name} 必須是非負整數。`);
  }
  return parsedValue;
}
