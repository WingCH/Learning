import assert from "node:assert/strict";
import test from "node:test";

import pino from "pino";

import {
  type FetchFunction,
  OpenRouterChatCompletionClient,
  type OpenRouterClientConfig,
} from "../../../src/infrastructure/openrouter/openrouter-chat-completion-client.js";

const baseConfig: OpenRouterClientConfig = {
  apiKey: "test-api-key",
  model: "@preset/whatsapp-auto-reply",
  endpoint: "https://openrouter.ai/api/v1/chat/completions",
  requestTimeoutMs: 1_000,
  httpReferer: "https://example.com/",
  appTitle: "Test WhatsApp Bot",
};

test("使用 preset 與 inbound message 呼叫 Chat Completions", async () => {
  const capturedInputs: Array<string | URL | Request> = [];
  const capturedInits: RequestInit[] = [];
  const fetchFunction: FetchFunction = async (input, init) => {
    capturedInputs.push(input);
    capturedInits.push(init);
    return jsonResponse({
      model: "openai/example-model",
      choices: [
        {
          finish_reason: "stop",
          message: {
            role: "assistant",
            content: "Hello from model",
          },
        },
      ],
    }, 200);
  };
  const client = createClient(baseConfig, fetchFunction);

  const completion = await client.complete(userRequest("Hello!"));

  assert.equal(completion, "Hello from model");
  assert.equal(
    capturedInputs[0],
    "https://openrouter.ai/api/v1/chat/completions",
  );
  const init = capturedInits[0];
  assert.ok(init);
  const headers = new Headers(init.headers);
  assert.equal(headers.get("Authorization"), "Bearer test-api-key");
  assert.equal(headers.get("Content-Type"), "application/json");
  assert.equal(headers.get("HTTP-Referer"), "https://example.com/");
  assert.equal(headers.get("X-OpenRouter-Title"), "Test WhatsApp Bot");
  assert.deepEqual(JSON.parse(String(init.body)), {
    model: "@preset/whatsapp-auto-reply",
    messages: [{ role: "user", content: "Hello!" }],
    stream: false,
  });
});

test("沒有 attribution URL 時省略 HTTP-Referer", async () => {
  const capturedInits: RequestInit[] = [];
  const client = createClient(
    { ...baseConfig, httpReferer: null },
    async (_input, init) => {
      capturedInits.push(init);
      return jsonResponse({
        choices: [
          {
            finish_reason: "stop",
            message: { role: "assistant", content: "Hello" },
          },
        ],
      }, 200);
    },
  );

  await client.complete(userRequest("Hello"));

  const init = capturedInits[0];
  assert.ok(init);
  assert.equal(new Headers(init.headers).has("HTTP-Referer"), false);
});

test("非 2xx response 只暴露安全的 status 與 API message", async () => {
  const client = createClient(
    baseConfig,
    async () => jsonResponse({ error: { message: "Invalid API key" } }, 401),
  );

  await assert.rejects(
    client.complete(userRequest("secret user message")),
    /OpenRouter HTTP 401：Invalid API key/,
  );
});

test("拒絕 embedded provider error 及 partial output", async () => {
  const client = createClient(
    baseConfig,
    async () => jsonResponse({
      choices: [
        {
          finish_reason: "error",
          message: { role: "assistant", content: "partial output" },
          error: { message: "Provider disconnected" },
        },
      ],
    }, 200),
  );

  await assert.rejects(
    client.complete(userRequest("Hello")),
    /OpenRouter provider error：Provider disconnected/,
  );
});

test("拒絕沒有 assistant text 的成功 response", async () => {
  const client = createClient(
    baseConfig,
    async () => jsonResponse({
      choices: [
        {
          finish_reason: "stop",
          message: { role: "assistant", content: "" },
        },
      ],
    }, 200),
  );

  await assert.rejects(
    client.complete(userRequest("Hello")),
    /沒有有效 assistant text/,
  );
});

test("超過 request timeout 時中止 fetch", async () => {
  const fetchFunction: FetchFunction = async (_input, init) =>
    new Promise((_resolve, reject) => {
      init.signal?.addEventListener(
        "abort",
        () => reject(new DOMException("Aborted", "AbortError")),
        { once: true },
      );
    });
  const client = createClient(
    { ...baseConfig, requestTimeoutMs: 5 },
    fetchFunction,
  );

  await assert.rejects(
    client.complete(userRequest("Hello")),
    /OpenRouter request 超過 5ms/,
  );
});

function createClient(
  config: OpenRouterClientConfig,
  fetchFunction: FetchFunction,
): OpenRouterChatCompletionClient {
  return new OpenRouterChatCompletionClient(
    config,
    fetchFunction,
    pino({ level: "silent" }),
  );
}

function userRequest(content: string) {
  return {
    messages: [{ role: "user" as const, content }],
  };
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
