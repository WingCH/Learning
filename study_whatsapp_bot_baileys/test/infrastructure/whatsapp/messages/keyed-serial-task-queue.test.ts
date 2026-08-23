import assert from "node:assert/strict";
import test from "node:test";

import { KeyedSerialTaskQueue } from "../../../../src/infrastructure/whatsapp/messages/keyed-serial-task-queue.js";

test("同一 chat 的 tasks 會依序執行", async () => {
  const queue = new KeyedSerialTaskQueue();
  const events: string[] = [];
  let releaseFirstTask!: () => void;
  const firstGate = new Promise<void>((resolve) => {
    releaseFirstTask = resolve;
  });

  const firstTask = queue.run("chat-a", async () => {
    events.push("first-start");
    await firstGate;
    events.push("first-end");
  });
  const secondTask = queue.run("chat-a", async () => {
    events.push("second-start");
  });

  await Promise.resolve();
  assert.deepEqual(events, ["first-start"]);
  releaseFirstTask();
  await Promise.all([firstTask, secondTask]);
  assert.deepEqual(events, ["first-start", "first-end", "second-start"]);
});

test("前一個 task 失敗後同一 chat 仍可繼續", async () => {
  const queue = new KeyedSerialTaskQueue();

  await assert.rejects(
    queue.run("chat-a", async () => {
      throw new Error("first failed");
    }),
    /first failed/,
  );
  const result = await queue.run("chat-a", async () => "second succeeded");

  assert.equal(result, "second succeeded");
});
