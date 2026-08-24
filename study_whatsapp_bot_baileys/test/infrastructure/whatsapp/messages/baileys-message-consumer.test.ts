import assert from "node:assert/strict";
import test from "node:test";

import type {
  BaileysEventMap,
  proto,
  WAMessage,
  WAMessageKey,
  WASocket,
} from "@whiskeysockets/baileys";
import pino from "pino";

import { MessageRouter } from "../../../../src/application/messages/message-router.js";
import type { MessageHandler } from "../../../../src/application/messages/message-handler.js";
import { BaileysMessageConsumer } from "../../../../src/infrastructure/whatsapp/messages/baileys-message-consumer.js";
import { InMemoryMessageContentStore } from "../../../../src/infrastructure/whatsapp/messages/in-memory-message-content-store.js";
import { KeyedSerialTaskQueue } from "../../../../src/infrastructure/whatsapp/messages/keyed-serial-task-queue.js";
import { TypingIndicator } from "../../../../src/infrastructure/whatsapp/messages/typing-indicator.js";

test("一次批次標記所有 inbound notify messages 為已讀", async () => {
  const readBatches: WAMessageKey[][] = [];
  const socket = {
    readMessages: async (keys: WAMessageKey[]) => {
      readBatches.push(keys);
    },
    sendPresenceUpdate: async () => {},
  } as unknown as WASocket;
  const messages = [
    createMessage("text-inbound", "chat-a", false, {
      conversation: "hello",
    }),
    createMessage("image-inbound", "chat-a", false, {
      imageMessage: { mimetype: "image/jpeg" },
    }),
    createMessage("group-inbound", "group-a@g.us", false, {
      conversation: "group message",
    }),
    createMessage("own-message", "chat-a", true, {
      conversation: "sent by bot account",
    }),
  ];

  await createConsumer([]).handle(socket, upsert("notify", messages));

  assert.deepEqual(readBatches, [[
    messages[0]?.key,
    messages[1]?.key,
    messages[2]?.key,
  ]]);
});

test("history append event 不會重送 read receipt", async () => {
  let readCallCount = 0;
  const socket = {
    readMessages: async () => {
      readCallCount += 1;
    },
  } as unknown as WASocket;

  await createConsumer([]).handle(socket, upsert("append", [
    createMessage("history-message", "chat-a", false, {
      conversation: "old message",
    }),
  ]));

  assert.equal(readCallCount, 0);
});

test("read receipt 失敗不會阻止 AI 訊息送出", async () => {
  let sentMessageCount = 0;
  let onSentCount = 0;
  const socket = {
    readMessages: async () => {
      throw new Error("receipt transport unavailable");
    },
    sendPresenceUpdate: async () => {},
    sendMessage: async () => {
      sentMessageCount += 1;
      return createMessage("outbound", "chat-a", true, {
        conversation: "AI response",
      });
    },
  } as unknown as WASocket;
  const responseHandler: MessageHandler = {
    handle: async () => ({
      text: "AI response",
      quoteOriginal: false,
      onSent: async () => {
        onSentCount += 1;
      },
    }),
  };
  const consumer = createConsumer([responseHandler]);

  await consumer.handle(socket, upsert("notify", [
    createMessage("inbound", "chat-a", false, {
      conversation: "hello",
    }),
  ]));

  assert.equal(sentMessageCount, 1);
  assert.equal(onSentCount, 1);
});

function createConsumer(
  handlers: readonly MessageHandler[],
): BaileysMessageConsumer {
  return new BaileysMessageConsumer(
    new MessageRouter(handlers),
    new InMemoryMessageContentStore(100),
    false,
    new KeyedSerialTaskQueue(),
    new TypingIndicator(8_000, pino({ level: "silent" })),
    pino({ level: "silent" }),
  );
}

function createMessage(
  id: string,
  remoteJid: string,
  fromMe: boolean,
  message: proto.IMessage,
): WAMessage {
  return {
    key: { id, remoteJid, fromMe },
    message,
    messageTimestamp: 1,
  };
}

function upsert(
  type: BaileysEventMap["messages.upsert"]["type"],
  messages: WAMessage[],
): BaileysEventMap["messages.upsert"] {
  return { type, messages };
}
