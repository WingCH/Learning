import assert from "node:assert/strict";
import test from "node:test";

import { loadAppConfig } from "../../src/config/app-config.js";

test("載入適合本機個人 bot 的安全預設設定", () => {
  const config = loadAppConfig({}, "/tmp/whatsapp-bot");

  assert.equal(config.authDirectory, "/tmp/whatsapp-bot/.data/whatsapp-auth");
  assert.equal(
    config.qrOutputPath,
    "/tmp/whatsapp-bot/.data/latest-whatsapp-qr.txt",
  );
  assert.equal(config.replyToGroups, false);
  assert.equal(config.logLevel, "info");
  assert.equal(config.maxReconnectAttempts, 8);
});

test("拒絕無效的 boolean 設定", () => {
  assert.throws(
    () =>
      loadAppConfig(
        {
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
          RECONNECT_BASE_DELAY_MS: "5000",
          RECONNECT_MAX_DELAY_MS: "1000",
        },
        "/tmp/whatsapp-bot",
      ),
    /RECONNECT_BASE_DELAY_MS 不可大於 RECONNECT_MAX_DELAY_MS/,
  );
});
