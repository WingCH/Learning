import assert from "node:assert/strict";
import test from "node:test";

import { ResetConversationCommand } from "../../../src/application/commands/reset-conversation-command.js";
import type { IncomingTextMessage } from "../../../src/application/messages/message.js";
import { InMemoryConversationHistoryStore } from "../../../src/infrastructure/conversation/in-memory-conversation-history-store.js";

const message: IncomingTextMessage = {
  id: "message-1",
  chatJid: "chat-a",
  text: "/reset",
  quotedText: null,
  isGroup: false,
};

test("確認訊息成功送出後才清除目前 chat", async () => {
  const store = createStore();
  await store.appendTurn("chat-a", {
    messageId: "earlier-message",
    userContent: "Question",
    assistantContent: "Answer",
  });
  await store.appendTurn("chat-b", {
    messageId: "other-message",
    userContent: "Other question",
    assistantContent: "Other answer",
  });
  const command = new ResetConversationCommand(store);

  const response = await command.execute({ message, arguments: [] });

  assert.equal(response.text, "對話記憶已清除。");
  assert.equal((await store.getMessages("chat-a")).length, 2);
  await response.onSent();
  assert.deepEqual(await store.getMessages("chat-a"), []);
  assert.equal((await store.getMessages("chat-b")).length, 2);
});

test("有多餘 arguments 時顯示用法而不清除", async () => {
  const store = createStore();
  await store.appendTurn("chat-a", {
    messageId: "earlier-message",
    userContent: "Question",
    assistantContent: "Answer",
  });
  const command = new ResetConversationCommand(store);

  const response = await command.execute({
    message,
    arguments: ["unexpected"],
  });
  await response.onSent();

  assert.equal(response.text, "用法：/reset");
  assert.equal((await store.getMessages("chat-a")).length, 2);
});

function createStore(): InMemoryConversationHistoryStore {
  return new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 10_000,
  });
}
