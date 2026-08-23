import assert from "node:assert/strict";
import test from "node:test";

import { loadAppConfig } from "../../src/config/app-config.js";

const requiredEnvironment = {
  OPENROUTER_API_KEY: "test-api-key",
} as const;

test("載入適合本機個人 bot 的安全預設設定", () => {
  const config = loadAppConfig(requiredEnvironment, "/tmp/whatsapp-bot");

  assert.equal(config.authDirectory, "/tmp/whatsapp-bot/.data/whatsapp-auth");
  assert.equal(
    config.qrOutputPath,
    "/tmp/whatsapp-bot/.data/latest-whatsapp-qr.txt",
  );
  assert.equal(config.replyToGroups, false);
  assert.equal(config.logLevel, "info");
  assert.equal(config.maxReconnectAttempts, 8);
  assert.equal(config.openRouter.model, "@preset/whatsapp-auto-reply");
  assert.equal(
    config.openRouter.endpoint,
    "https://openrouter.ai/api/v1/chat/completions",
  );
  assert.equal(config.openRouter.requestTimeoutMs, 30_000);
  assert.deepEqual(config.conversationHistory, {
    maxChats: 100,
    maxTurnsPerChat: 20,
    maxCharactersPerChat: 12_000,
  });
});

test("拒絕無效的 boolean 設定", () => {
  assert.throws(
    () =>
      loadAppConfig(
        {
          ...requiredEnvironment,
          REPLY_TO_GROUPS: "yes",
        },
        "/tmp/whatsapp-bot",
      ),
    /REPLY_TO_GROUPS 必須是 true 或 false/,
  );
});

test("拒絕大於上限的重連基礎延遲", () => {
  assert.throws(
    () =>
      loadAppConfig(
        {
          ...requiredEnvironment,
          RECONNECT_BASE_DELAY_MS: "5000",
          RECONNECT_MAX_DELAY_MS: "1000",
        },
        "/tmp/whatsapp-bot",
      ),
    /RECONNECT_BASE_DELAY_MS 不可大於 RECONNECT_MAX_DELAY_MS/,
  );
});

test("缺少 OpenRouter API key 時立即拒絕啟動", () => {
  assert.throws(
    () => loadAppConfig({}, "/tmp/whatsapp-bot"),
    /缺少必要設定：OPENROUTER_API_KEY/,
  );
});

test("拒絕非 HTTPS OpenRouter endpoint", () => {
  assert.throws(
    () => loadAppConfig({
      ...requiredEnvironment,
      OPENROUTER_ENDPOINT: "http://openrouter.example/api",
    }, "/tmp/whatsapp-bot"),
    /OPENROUTER_ENDPOINT 必須使用 https/,
  );
});
