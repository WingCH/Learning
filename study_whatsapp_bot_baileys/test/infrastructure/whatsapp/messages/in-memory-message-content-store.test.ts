import assert from "node:assert/strict";
import test from "node:test";

import type { WAMessage } from "@whiskeysockets/baileys";

import { InMemoryMessageContentStore } from "../../../../src/infrastructure/whatsapp/messages/in-memory-message-content-store.js";

test("保存訊息內容供 Baileys message retry 讀取", async () => {
  const store = new InMemoryMessageContentStore(2);
  const message = createMessage("message-1", "hi");

  store.put(message);

  assert.deepEqual(await store.get(message.key), message.message);
});

test("超過上限時移除最舊的訊息", async () => {
  const store = new InMemoryMessageContentStore(2);
  const firstMessage = createMessage("message-1", "one");
  const secondMessage = createMessage("message-2", "two");
  const thirdMessage = createMessage("message-3", "three");

  store.put(firstMessage);
  store.put(secondMessage);
  store.put(thirdMessage);

  assert.equal(await store.get(firstMessage.key), undefined);
  assert.deepEqual(await store.get(secondMessage.key), secondMessage.message);
  assert.deepEqual(await store.get(thirdMessage.key), thirdMessage.message);
});

test("拒絕無效的容量設定", () => {
  assert.throws(
    () => new InMemoryMessageContentStore(0),
    /maxEntries 必須是正整數/,
  );
});

function createMessage(id: string, text: string): WAMessage {
  return {
    key: {
      id,
      remoteJid: "85212345678@s.whatsapp.net",
      fromMe: false,
    },
    message: {
      conversation: text,
    },
    messageTimestamp: 1,
  };
}
