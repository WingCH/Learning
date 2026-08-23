import assert from "node:assert/strict";
import test from "node:test";

import { RepeatTextMessageHandler } from "../../../src/application/messages/repeat-text-message-handler.js";

const baseMessage = {
  id: "message-1",
  chatJid: "85212345678@s.whatsapp.net",
  isGroup: false,
} as const;

test("將一般文字重複兩次", async () => {
  const handler = new RepeatTextMessageHandler();

  const response = await handler.handle({
    ...baseMessage,
    text: "hi",
  });

  assert.deepEqual(response, {
    text: "hi hi",
    quoteOriginal: false,
  });
});

test("先移除文字前後空白再重複", async () => {
  const handler = new RepeatTextMessageHandler();

  const response = await handler.handle({
    ...baseMessage,
    text: "  hello world  ",
  });

  assert.equal(response?.text, "hello world hello world");
});

test("純空白訊息不產生回覆", async () => {
  const handler = new RepeatTextMessageHandler();

  const response = await handler.handle({
    ...baseMessage,
    text: "   ",
  });

  assert.equal(response, null);
});
