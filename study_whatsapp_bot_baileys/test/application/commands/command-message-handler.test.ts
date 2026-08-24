import assert from "node:assert/strict";
import test from "node:test";

import type {
  ChatCommand,
  ChatCommandContext,
} from "../../../src/application/commands/chat-command.js";
import { CommandMessageHandler } from "../../../src/application/commands/command-message-handler.js";
import type { IncomingTextMessage } from "../../../src/application/messages/message.js";

const baseMessage: IncomingTextMessage = {
  id: "message-1",
  chatJid: "chat-a",
  text: "hello",
  quotedText: null,
  isGroup: false,
};

test("普通文字交給下一個 message handler", async () => {
  const handler = new CommandMessageHandler([]);

  assert.equal(await handler.handle(baseMessage), null);
});

test("/help 由 registry metadata 自動產生清單", async () => {
  const handler = new CommandMessageHandler([
    command("reset", "清除目前 chat 的 AI 對話記憶"),
  ]);

  const response = await handler.handle({ ...baseMessage, text: "/help" });

  assert.match(response?.text ?? "", /\/help — 顯示此指令清單/);
  assert.match(response?.text ?? "", /\/reset — 清除目前 chat/);
});

test("command name 大小寫不敏感並傳遞 arguments", async () => {
  const contexts: ChatCommandContext[] = [];
  const handler = new CommandMessageHandler([
    {
      ...command("echo", "測試 arguments"),
      execute: async (context) => {
        contexts.push(context);
        return response("ok");
      },
    },
  ]);

  await handler.handle({ ...baseMessage, text: "  /ECHO one two  " });

  assert.deepEqual(contexts[0]?.arguments, ["one", "two"]);
});

test("未知 slash command 不會落入 AI handler", async () => {
  const handler = new CommandMessageHandler([]);

  const result = await handler.handle({ ...baseMessage, text: "/missing" });

  assert.match(result?.text ?? "", /未知指令：\/missing/);
  assert.match(result?.text ?? "", /\/help/);
});

test("registry 拒絕重複 command name", () => {
  assert.throws(
    () => new CommandMessageHandler([
      command("reset", "first"),
      command("RESET", "second"),
    ]),
    /重複 command：\/reset/,
  );
});

function command(name: string, description: string): ChatCommand {
  return {
    name,
    description,
    execute: async () => response(name),
  };
}

function response(text: string) {
  return {
    text,
    quoteOriginal: false,
    onSent: async () => {},
  };
}
