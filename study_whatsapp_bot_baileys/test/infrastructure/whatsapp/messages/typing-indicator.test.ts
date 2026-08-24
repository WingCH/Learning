import assert from "node:assert/strict";
import test from "node:test";

import type { WASocket } from "@whiskeysockets/baileys";
import pino from "pino";

import { TypingIndicator } from "../../../../src/infrastructure/whatsapp/messages/typing-indicator.js";

test("operation 前送 composing，完成後送 paused", async () => {
  const events: string[] = [];
  const socket = presenceSocket(async (presence, jid) => {
    events.push(`${presence}:${jid}`);
  });
  const indicator = createIndicator(8_000);

  const result = await indicator.run(socket, "chat-a", async () => {
    events.push("operation");
    return "done";
  });

  assert.equal(result, "done");
  assert.deepEqual(events, [
    "composing:chat-a",
    "operation",
    "paused:chat-a",
  ]);
});

test("operation 失敗時仍在 finally 送 paused", async () => {
  const presences: string[] = [];
  const socket = presenceSocket(async (presence) => {
    presences.push(presence);
  });
  const indicator = createIndicator(8_000);

  await assert.rejects(
    indicator.run(socket, "chat-a", async () => {
      throw new Error("operation failed");
    }),
    /operation failed/,
  );

  assert.deepEqual(presences, ["composing", "paused"]);
});

test("presence transport 失敗不會阻止 operation", async () => {
  const socket = presenceSocket(async () => {
    throw new Error("presence unavailable");
  });
  const indicator = createIndicator(8_000);

  const result = await indicator.run(socket, "chat-a", async () => "done");

  assert.equal(result, "done");
});

test("長時間 operation 會定期刷新 composing，最後仍以 paused 結束", async () => {
  const presences: string[] = [];
  const socket = presenceSocket(async (presence) => {
    presences.push(presence);
  });
  const indicator = createIndicator(5);

  await indicator.run(socket, "chat-a", async () => {
    await new Promise((resolve) => setTimeout(resolve, 18));
  });

  assert.ok(
    presences.filter((presence) => presence === "composing").length >= 2,
  );
  assert.equal(presences.at(-1), "paused");
});

function createIndicator(refreshIntervalMs: number): TypingIndicator {
  return new TypingIndicator(
    refreshIntervalMs,
    pino({ level: "silent" }),
  );
}

function presenceSocket(
  sendPresenceUpdate: (
    presence: "composing" | "paused",
    jid: string,
  ) => Promise<void>,
): WASocket {
  return { sendPresenceUpdate } as unknown as WASocket;
}
