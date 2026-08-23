import assert from "node:assert/strict";
import test from "node:test";

import type { TextCompletionClient } from "../../../src/application/ai/text-completion-client.js";
import { AiTextMessageHandler } from "../../../src/application/messages/ai-text-message-handler.js";
import { InMemoryConversationHistoryStore } from "../../../src/infrastructure/conversation/in-memory-conversation-history-store.js";

const baseMessage = {
  id: "message-1",
  chatJid: "85212345678@s.whatsapp.net",
  quotedText: null,
  isGroup: false,
} as const;

test("把 rolling history 與目前 inbound text 傳給 AI", async () => {
  const requests: Parameters<TextCompletionClient["complete"]>[0][] = [];
  const client: TextCompletionClient = {
    complete: async (request) => {
      requests.push(request);
      return "Model response";
    },
  };
  const historyStore = createHistoryStore();
  await historyStore.appendTurn(baseMessage.chatJid, {
    messageId: "previous-message",
    userContent: "Earlier question",
    assistantContent: "Earlier answer",
  });
  const handler = new AiTextMessageHandler(client, historyStore);

  const response = await handler.handle({
    ...baseMessage,
    text: "  Hello!  ",
  });

  assert.deepEqual(requests, [
    {
      messages: [
        { role: "user", content: "Earlier question" },
        { role: "assistant", content: "Earlier answer" },
        { role: "user", content: "Hello!" },
      ],
    },
  ]);
  assert.equal(response?.text, "Model response");
  assert.equal(response?.quoteOriginal, false);

  assert.deepEqual(await historyStore.getMessages(baseMessage.chatJid), [
    { role: "user", content: "Earlier question" },
    { role: "assistant", content: "Earlier answer" },
  ]);
  await response?.onSent();
  assert.deepEqual(await historyStore.getMessages(baseMessage.chatJid), [
    { role: "user", content: "Earlier question" },
    { role: "assistant", content: "Earlier answer" },
    { role: "user", content: "Hello!" },
    { role: "assistant", content: "Model response" },
  ]);
});

test("把 WhatsApp quoted reply 明確加入目前 user context", async () => {
  const requests: Parameters<TextCompletionClient["complete"]>[0][] = [];
  const client: TextCompletionClient = {
    complete: async (request) => {
      requests.push(request);
      return "Understood";
    },
  };
  const handler = new AiTextMessageHandler(client, createHistoryStore());

  await handler.handle({
    ...baseMessage,
    text: "咁即係點？",
    quotedText: "原本嗰句",
  });

  const currentContent = requests[0]?.messages[0]?.content;
  assert.match(currentContent ?? "", /quoted message/);
  assert.match(currentContent ?? "", /原本嗰句/);
  assert.match(currentContent ?? "", /咁即係點？/);
});

test("純空白 inbound text 不呼叫 AI", async () => {
  const client: TextCompletionClient = {
    complete: async () => {
      throw new Error("不應呼叫 OpenRouter");
    },
  };
  const handler = new AiTextMessageHandler(client, createHistoryStore());

  const response = await handler.handle({
    ...baseMessage,
    text: "   ",
  });

  assert.equal(response, null);
});

test("拒絕空白 model completion", async () => {
  const client: TextCompletionClient = {
    complete: async () => "   ",
  };
  const handler = new AiTextMessageHandler(client, createHistoryStore());

  await assert.rejects(
    handler.handle({ ...baseMessage, text: "Hello" }),
    /OpenRouter 回傳空白內容/,
  );
});

function createHistoryStore(): InMemoryConversationHistoryStore {
  return new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 10_000,
  });
}
