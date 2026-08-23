import pino, { type Logger } from "pino";

import type { LogLevel } from "../../config/app-config.js";

export function createLogger(botName: string, logLevel: LogLevel): Logger {
  return pino({
    level: logLevel,
    base: {
      service: botName,
    },
  });
}
