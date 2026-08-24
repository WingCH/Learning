import assert from "node:assert/strict";
import test from "node:test";

import { InMemoryConversationHistoryStore } from "../../../src/infrastructure/conversation/in-memory-conversation-history-store.js";

test("保存 user／assistant turns 並按 chat 隔離", async () => {
  const store = createStore();
  await store.appendTurn("chat-a", {
    messageId: "message-1",
    userContent: "Question",
    assistantContent: "Answer",
  });

  assert.deepEqual(await store.getMessages("chat-a"), [
    { role: "user", content: "Question" },
    { role: "assistant", content: "Answer" },
  ]);
  assert.deepEqual(await store.getMessages("chat-b"), []);
});

test("超過 turn 上限時移除最舊 turn", async () => {
  const store = new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 2,
    maxCharactersPerChat: 10_000,
  });
  await appendTurn(store, "message-1", "one");
  await appendTurn(store, "message-2", "two");
  await appendTurn(store, "message-3", "three");

  assert.deepEqual(await store.getMessages("chat-a"), [
    { role: "user", content: "two" },
    { role: "assistant", content: "reply-two" },
    { role: "user", content: "three" },
    { role: "assistant", content: "reply-three" },
  ]);
});

test("超過 character budget 時移除最舊 turn", async () => {
  const store = new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 20,
  });
  await appendTurn(store, "message-1", "1234567890");
  await appendTurn(store, "message-2", "short");

  assert.deepEqual(await store.getMessages("chat-a"), [
    { role: "user", content: "short" },
    { role: "assistant", content: "reply-short" },
  ]);
});

test("相同 inbound message ID 不會重複加入 history", async () => {
  const store = createStore();
  await appendTurn(store, "message-1", "one");
  await appendTurn(store, "message-1", "duplicate");

  assert.deepEqual(await store.getMessages("chat-a"), [
    { role: "user", content: "one" },
    { role: "assistant", content: "reply-one" },
  ]);
});

test("超過 chat 上限時移除最久未使用的 chat", async () => {
  const store = new InMemoryConversationHistoryStore({
    maxChats: 2,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 10_000,
  });
  await store.appendTurn("chat-a", {
    messageId: "a-1",
    userContent: "a",
    assistantContent: "reply-a",
  });
  await store.appendTurn("chat-b", {
    messageId: "b-1",
    userContent: "b",
    assistantContent: "reply-b",
  });
  await store.getMessages("chat-a");
  await store.appendTurn("chat-c", {
    messageId: "c-1",
    userContent: "c",
    assistantContent: "reply-c",
  });

  assert.deepEqual(await store.getMessages("chat-b"), []);
  assert.equal((await store.getMessages("chat-a")).length, 2);
  assert.equal((await store.getMessages("chat-c")).length, 2);
});

test("clear 只移除指定 chat", async () => {
  const store = createStore();
  await appendTurn(store, "message-1", "one");
  await store.appendTurn("chat-b", {
    messageId: "message-b",
    userContent: "b",
    assistantContent: "reply-b",
  });

  await store.clear("chat-a");

  assert.deepEqual(await store.getMessages("chat-a"), []);
  assert.equal((await store.getMessages("chat-b")).length, 2);
});

function createStore(): InMemoryConversationHistoryStore {
  return new InMemoryConversationHistoryStore({
    maxChats: 10,
    maxTurnsPerChat: 10,
    maxCharactersPerChat: 10_000,
  });
}

async function appendTurn(
  store: InMemoryConversationHistoryStore,
  messageId: string,
  userContent: string,
): Promise<void> {
  await store.appendTurn("chat-a", {
    messageId,
    userContent,
    assistantContent: `reply-${userContent}`,
  });
}
