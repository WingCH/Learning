import assert from "node:assert/strict";
import test from "node:test";

import type { proto, WAMessage } from "@whiskeysockets/baileys";

import { parseIncomingTextMessage } from "../../../../src/infrastructure/whatsapp/messages/parse-incoming-text-message.js";

test("解析一般 conversation 文字", () => {
  const parsedMessage = parseIncomingTextMessage(
    createMessage({ conversation: "hi" }),
  );

  assert.deepEqual(parsedMessage, {
    id: "message-1",
    chatJid: "85212345678@s.whatsapp.net",
    text: "hi",
    isGroup: false,
  });
});

test("解析回覆或帶格式的 extendedTextMessage 文字", () => {
  const parsedMessage = parseIncomingTextMessage(
    createMessage({
      extendedTextMessage: {
        text: "hello world",
      },
    }),
  );

  assert.equal(parsedMessage?.text, "hello world");
});

test("忽略自己發出的訊息", () => {
  const message = createMessage({ conversation: "hi" });
  message.key.fromMe = true;

  assert.equal(parseIncomingTextMessage(message), null);
});

test("標示群組訊息供 consumer 決定是否回覆", () => {
  const message = createMessage({ conversation: "hi" });
  message.key.remoteJid = "12345-67890@g.us";

  assert.equal(parseIncomingTextMessage(message)?.isGroup, true);
});

test("忽略沒有文字內容的訊息", () => {
  assert.equal(
    parseIncomingTextMessage(
      createMessage({
        imageMessage: {
          mimetype: "image/jpeg",
        },
      }),
    ),
    null,
  );
});

function createMessage(message: proto.IMessage): WAMessage {
  return {
    key: {
      id: "message-1",
      remoteJid: "85212345678@s.whatsapp.net",
      fromMe: false,
    },
    message,
    messageTimestamp: 1,
  };
}
