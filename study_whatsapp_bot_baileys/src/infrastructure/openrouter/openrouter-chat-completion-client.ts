import type { Logger } from "pino";

import type {
  TextCompletionClient,
  TextCompletionRequest,
} from "../../application/ai/text-completion-client.js";

export interface OpenRouterClientConfig {
  readonly apiKey: string;
  readonly model: string;
  readonly endpoint: string;
  readonly requestTimeoutMs: number;
  readonly httpReferer: string | null;
  readonly appTitle: string;
}

export type FetchFunction = (
  input: string | URL | Request,
  init: RequestInit,
) => Promise<Response>;

export class OpenRouterChatCompletionClient implements TextCompletionClient {
  public constructor(
    private readonly config: OpenRouterClientConfig,
    private readonly fetchFunction: FetchFunction,
    private readonly logger: Logger,
  ) {}

  public async complete(request: TextCompletionRequest): Promise<string> {
    if (request.messages.length === 0) {
      throw new Error("OpenRouter request 必須包含至少一個 message。");
    }

    const abortController = new AbortController();
    const timeout = setTimeout(
      () => abortController.abort(),
      this.config.requestTimeoutMs,
    );
    const startedAt = Date.now();

    try {
      const response = await this.fetchFunction(this.config.endpoint, {
        method: "POST",
        headers: createHeaders(this.config),
        body: JSON.stringify({
          model: this.config.model,
          messages: request.messages,
          stream: false,
        }),
        signal: abortController.signal,
      });
      const responseBody = await parseResponseBody(response);

      if (!response.ok) {
        throw new Error(
          `OpenRouter HTTP ${response.status}：${extractErrorMessage(responseBody)}`,
        );
      }

      const completion = extractCompletion(responseBody);
      this.logger.info(
        {
          requestedModel: this.config.model,
          responseModel: extractResponseModel(responseBody),
          durationMs: Date.now() - startedAt,
        },
        "OpenRouter completion 已完成。",
      );
      return completion;
    } catch (error: unknown) {
      if (abortController.signal.aborted) {
        throw new Error(
          `OpenRouter request 超過 ${this.config.requestTimeoutMs}ms。`,
          { cause: error },
        );
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }
}

function createHeaders(config: OpenRouterClientConfig): Record<string, string> {
  const headers: Record<string, string> = {
    Authorization: `Bearer ${config.apiKey}`,
    "Content-Type": "application/json",
    "X-OpenRouter-Title": config.appTitle,
  };

  if (config.httpReferer !== null) {
    headers["HTTP-Referer"] = config.httpReferer;
  }
  return headers;
}

async function parseResponseBody(response: Response): Promise<unknown> {
  const responseText = await response.text();
  try {
    return JSON.parse(responseText) as unknown;
  } catch (error: unknown) {
    throw new Error(
      `OpenRouter HTTP ${response.status} 回傳無效 JSON。`,
      { cause: error },
    );
  }
}

function extractCompletion(responseBody: unknown): string {
  const response = asRecord(responseBody);
  const topLevelError = response?.error;
  if (topLevelError !== undefined) {
    throw new Error(`OpenRouter API error：${extractErrorMessage(responseBody)}`);
  }

  const choices = response?.choices;
  if (!Array.isArray(choices) || choices.length === 0) {
    throw new Error("OpenRouter response 沒有 completion choice。");
  }

  const firstChoice = asRecord(choices[0]);
  if (
    firstChoice === null ||
    firstChoice.finish_reason === "error" ||
    firstChoice.error !== undefined
  ) {
    throw new Error(
      `OpenRouter provider error：${extractErrorMessage(firstChoice)}`,
    );
  }

  const message = asRecord(firstChoice.message);
  const content = message?.content;
  if (typeof content !== "string" || content.trim().length === 0) {
    throw new Error("OpenRouter response 沒有有效 assistant text。");
  }
  return content.trim();
}

function extractErrorMessage(value: unknown): string {
  const record = asRecord(value);
  const error = asRecord(record?.error);
  const errorMessage = error?.message;
  if (typeof errorMessage === "string" && errorMessage.trim().length > 0) {
    return truncate(errorMessage.trim(), 500);
  }

  const message = record?.message;
  if (typeof message === "string" && message.trim().length > 0) {
    return truncate(message.trim(), 500);
  }
  return "未提供錯誤內容";
}

function extractResponseModel(value: unknown): string | null {
  const model = asRecord(value)?.model;
  return typeof model === "string" ? model : null;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null
    ? (value as Record<string, unknown>)
    : null;
}

function truncate(value: string, maxLength: number): string {
  return value.length <= maxLength
    ? value
    : `${value.slice(0, maxLength)}…`;
}
