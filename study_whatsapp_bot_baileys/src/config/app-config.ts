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
  };

  if (config.reconnectBaseDelayMs > config.reconnectMaxDelayMs) {
    throw new Error(
      "RECONNECT_BASE_DELAY_MS 不可大於 RECONNECT_MAX_DELAY_MS。",
    );
  }

  return config;
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
