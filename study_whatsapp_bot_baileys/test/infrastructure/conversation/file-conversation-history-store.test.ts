import assert from "node:assert/strict";
import {
  access,
  chmod,
  mkdtemp,
  readFile,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import pino from "pino";

import type {
  ConversationSummarizer,
  ConversationSummaryRequest,
} from "../../../src/application/ai/conversation-summarizer.js";
import type { ConversationHistoryConfig } from "../../../src/config/app-config.js";
import { FileConversationHistoryStore } from "../../../src/infrastructure/conversation/file-conversation-history-store.js";

test("把 legacy RAM snapshot 遷移成 private version 1 file", async () => {
  await withTemporaryStore(async ({ config, directory }) => {
    await writeFile(config.legacyFilePath, JSON.stringify({
      version: 0,
      capturedAt: "2026-08-24T00:00:00.000Z",
      chats: [
        {
          chatJid: "chat-a",
          turns: [turn("message-1", "Question", "Answer")],
        },
      ],
    }), { mode: 0o600 });
    await chmod(config.legacyFilePath, 0o600);

    const store = await openStore(config, fixedSummarizer("unused"));

    assert.deepEqual(await store.getMessages("chat-a"), [
      { role: "user", content: "Question" },
      { role: "assistant", content: "Answer" },
    ]);
    assert.equal((await stat(config.filePath)).mode & 0o777, 0o600);
    await assert.rejects(access(config.legacyFilePath), { code: "ENOENT" });
    const persisted = JSON.parse(await readFile(config.filePath, "utf8"));
    assert.equal(persisted.version, 1);
    assert.equal(persisted.chats.length, 1);
    assert.equal((await stat(directory)).mode & 0o777, 0o700);
  });
});

test("成功送出的 turns 會在 reopen 後保留", async () => {
  await withTemporaryStore(async ({ config }) => {
    const store = await openStore(config, fixedSummarizer("unused"));
    await store.appendTurn("chat-a", turn("message-1", "Question", "Answer"));

    const reopened = await openStore(config, fixedSummarizer("unused"));

    assert.deepEqual(await reopened.getMessages("chat-a"), [
      { role: "user", content: "Question" },
      { role: "assistant", content: "Answer" },
    ]);
  });
});

test("超過 threshold 時壓縮舊 turns 並保留最新 turns", async () => {
  await withTemporaryStore(async ({ config }) => {
    const requests: ConversationSummaryRequest[] = [];
    const summarizer: ConversationSummarizer = {
      summarize: async (request) => {
        requests.push(request);
        return "Facts from older turns";
      },
    };
    const compactingConfig = {
      ...config,
      compactionTriggerTurns: 3,
      keepRecentTurns: 1,
    };
    const store = await openStore(compactingConfig, summarizer);
    await store.appendTurn("chat-a", turn("message-1", "one", "reply-one"));
    await store.appendTurn("chat-a", turn("message-2", "two", "reply-two"));
    await store.appendTurn("chat-a", turn("message-3", "three", "reply-three"));

    assert.equal(requests.length, 1);
    assert.equal(requests[0]?.turns.length, 2);
    const context = await store.getMessages("chat-a");
    assert.equal(context[0]?.role, "system");
    assert.match(context[0]?.content ?? "", /Facts from older turns/);
    assert.deepEqual(context.slice(1), [
      { role: "user", content: "three" },
      { role: "assistant", content: "reply-three" },
    ]);

    const reopened = await openStore(
      compactingConfig,
      fixedSummarizer("must not run during open"),
    );
    assert.deepEqual(await reopened.getMessages("chat-a"), context);
  });
});

test("summary failure 時保留資料並以 hard limit 防止無限增長", async () => {
  await withTemporaryStore(async ({ config }) => {
    const failingSummarizer: ConversationSummarizer = {
      summarize: async () => {
        throw new Error("summary unavailable");
      },
    };
    const boundedConfig = {
      ...config,
      compactionTriggerTurns: 2,
      keepRecentTurns: 1,
      hardMaxTurnsPerChat: 3,
    };
    const store = await openStore(boundedConfig, failingSummarizer);
    for (let index = 1; index <= 4; index += 1) {
      await store.appendTurn(
        "chat-a",
        turn(`message-${index}`, `question-${index}`, `answer-${index}`),
      );
    }

    const context = await store.getMessages("chat-a");
    assert.equal(context.length, 6);
    assert.equal(context[0]?.content, "question-2");
    const reopened = await openStore(boundedConfig, failingSummarizer);
    assert.deepEqual(await reopened.getMessages("chat-a"), context);
  });
});

test("corrupt version file 會拒絕啟動而不是覆寫", async () => {
  await withTemporaryStore(async ({ config }) => {
    await writeFile(config.filePath, "{not-json", { mode: 0o600 });

    await assert.rejects(
      openStore(config, fixedSummarizer("unused")),
      /無法讀取 conversation memory/,
    );
    assert.equal(await readFile(config.filePath, "utf8"), "{not-json");
  });
});

test("clear 會 atomic persist 並在 reopen 後維持清除狀態", async () => {
  await withTemporaryStore(async ({ config }) => {
    const store = await openStore(config, fixedSummarizer("unused"));
    await store.appendTurn("chat-a", turn("message-a", "a", "reply-a"));
    await store.appendTurn("chat-b", turn("message-b", "b", "reply-b"));

    await store.clear("chat-a");

    const reopened = await openStore(config, fixedSummarizer("unused"));
    assert.deepEqual(await reopened.getMessages("chat-a"), []);
    assert.equal((await reopened.getMessages("chat-b")).length, 2);
    assert.equal((await stat(config.filePath)).mode & 0o777, 0o600);
  });
});

async function withTemporaryStore(
  testBody: (context: {
    config: ConversationHistoryConfig;
    directory: string;
  }) => Promise<void>,
): Promise<void> {
  const directory = await mkdtemp(join(tmpdir(), "conversation-memory-"));
  const config = createConfig(directory);
  try {
    await testBody({ config, directory });
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
}

function createConfig(directory: string): ConversationHistoryConfig {
  return {
    filePath: join(directory, "conversation-memory.json"),
    legacyFilePath: join(directory, "conversation-memory-legacy.json"),
    maxChats: 10,
    compactionTriggerTurns: 20,
    compactionTriggerCharacters: 12_000,
    keepRecentTurns: 8,
    maxSummaryCharacters: 4_000,
    hardMaxTurnsPerChat: 40,
    hardMaxCharactersPerChat: 24_000,
    summaryModel: "@preset/test-summary",
  };
}

function fixedSummarizer(summary: string): ConversationSummarizer {
  return {
    summarize: async () => summary,
  };
}

function turn(
  messageId: string,
  userContent: string,
  assistantContent: string,
) {
  return { messageId, userContent, assistantContent };
}

async function openStore(
  config: ConversationHistoryConfig,
  summarizer: ConversationSummarizer,
): Promise<FileConversationHistoryStore> {
  return FileConversationHistoryStore.open(
    config,
    summarizer,
    pino({ level: "silent" }),
  );
}
