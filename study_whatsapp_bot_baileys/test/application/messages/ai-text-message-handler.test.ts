import assert from "node:assert/strict";
import test from "node:test";

import type { TextCompletionClient } from "../../../src/application/ai/text-completion-client.js";
import { AiTextMessageHandler } from "../../../src/application/messages/ai-text-message-handler.js";
import type { ResponseDelayPolicy } from "../../../src/application/messages/response-delay-policy.js";
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
  const handler = createHandler(client, historyStore);

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
  const handler = createHandler(client, createHistoryStore());

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
  const handler = createHandler(client, createHistoryStore());

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
  const handler = createHandler(client, createHistoryStore());

  await assert.rejects(
    handler.handle({ ...baseMessage, text: "Hello" }),
    /OpenRouter 回傳空白內容/,
  );
});

test("minimum delay 在 AI request 前開始，completion 後才等待", async () => {
  const events: string[] = [];
  const client: TextCompletionClient = {
    complete: async () => {
      events.push("api");
      return "response";
    },
  };
  const delayPolicy: ResponseDelayPolicy = {
    begin: () => {
      events.push("delay-begin");
      return {
        wait: async () => {
          events.push("delay-wait");
        },
      };
    },
  };
  const handler = new AiTextMessageHandler(
    client,
    createHistoryStore(),
    delayPolicy,
  );

  await handler.handle({ ...baseMessage, text: "Hello" });

  assert.deepEqual(events, ["delay-begin", "api", "delay-wait"]);
});

function createHistoryStore(): InMemoryConversationHistoryStore {
  return new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 10_000,
  });
}

function createHandler(
  client: TextCompletionClient,
  historyStore: InMemoryConversationHistoryStore,
): AiTextMessageHandler {
  return new AiTextMessageHandler(client, historyStore, {
    begin: () => ({ wait: async () => {} }),
  });
}
