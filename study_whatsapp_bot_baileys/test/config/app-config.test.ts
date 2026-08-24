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
    filePath: "/tmp/whatsapp-bot/.data/conversation-memory.json",
    legacyFilePath:
      "/tmp/whatsapp-bot/.data/conversation-memory-legacy.json",
    maxChats: 100,
    compactionTriggerTurns: 20,
    compactionTriggerCharacters: 12_000,
    keepRecentTurns: 8,
    maxSummaryCharacters: 4_000,
    hardMaxTurnsPerChat: 40,
    hardMaxCharactersPerChat: 24_000,
    summaryModel: "@preset/whatsapp-auto-reply",
  });
  assert.deepEqual(config.responseDelay, {
    minimumMs: 2_000,
    maximumMs: 5_000,
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

test("拒絕不可能保留 recent turns 的 compaction 設定", () => {
  assert.throws(
    () => loadAppConfig({
      ...requiredEnvironment,
      CONVERSATION_COMPACTION_TRIGGER_TURNS: "8",
      CONVERSATION_COMPACTION_KEEP_RECENT_TURNS: "8",
    }, "/tmp/whatsapp-bot"),
    /KEEP_RECENT_TURNS 必須小於 trigger turns/,
  );
});

test("拒絕大於 hard max 的 summary 上限", () => {
  assert.throws(
    () => loadAppConfig({
      ...requiredEnvironment,
      CONVERSATION_MAX_SUMMARY_CHARACTERS: "30000",
      CONVERSATION_HARD_MAX_CHARACTERS_PER_CHAT: "24000",
    }, "/tmp/whatsapp-bot"),
    /summary 上限不可大於 character hard max/,
  );
});

test("拒絕 minimum 大於 maximum 的 AI response delay", () => {
  assert.throws(
    () => loadAppConfig({
      ...requiredEnvironment,
      AI_RESPONSE_DELAY_MIN_MS: "6000",
      AI_RESPONSE_DELAY_MAX_MS: "2000",
    }, "/tmp/whatsapp-bot"),
    /AI_RESPONSE_DELAY_MIN_MS 不可大於 AI_RESPONSE_DELAY_MAX_MS/,
  );
});
