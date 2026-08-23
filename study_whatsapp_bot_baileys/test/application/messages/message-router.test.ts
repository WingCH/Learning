import assert from "node:assert/strict";
import test from "node:test";

import type { MessageHandler } from "../../../src/application/messages/message-handler.js";
import { MessageRouter } from "../../../src/application/messages/message-router.js";
import type { IncomingTextMessage } from "../../../src/application/messages/message.js";

const incomingMessage: IncomingTextMessage = {
  id: "message-1",
  chatJid: "85212345678@s.whatsapp.net",
  text: "hi",
  quotedText: null,
  isGroup: false,
};

test("使用第一個能夠處理訊息的 handler", async () => {
  const onSent = async (): Promise<void> => {};
  const skippedHandler: MessageHandler = {
    handle: async () => null,
  };
  const selectedHandler: MessageHandler = {
    handle: async () => ({
      text: "selected",
      quoteOriginal: false,
      onSent,
    }),
  };
  const unreachableHandler: MessageHandler = {
    handle: async () => {
      throw new Error("不應執行第三個 handler");
    },
  };
  const router = new MessageRouter([
    skippedHandler,
    selectedHandler,
    unreachableHandler,
  ]);

  const response = await router.dispatch(incomingMessage);

  assert.deepEqual(response, {
    text: "selected",
    quoteOriginal: false,
    onSent,
  });
});

test("沒有 handler 接受訊息時不產生回覆", async () => {
  const router = new MessageRouter([
    {
      handle: async () => null,
    },
  ]);

  const response = await router.dispatch(incomingMessage);

  assert.equal(response, null);
});
