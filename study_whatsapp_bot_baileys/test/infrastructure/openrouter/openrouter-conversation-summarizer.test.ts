import assert from "node:assert/strict";
import test from "node:test";

import type { TextCompletionClient } from "../../../src/application/ai/text-completion-client.js";
import { OpenRouterConversationSummarizer } from "../../../src/infrastructure/openrouter/openrouter-conversation-summarizer.js";

test("把 previous summary 與舊 turns 當作不可信資料交給 AI 壓縮", async () => {
  const requests: Parameters<TextCompletionClient["complete"]>[0][] = [];
  const client: TextCompletionClient = {
    complete: async (request) => {
      requests.push(request);
      return "Updated summary";
    },
  };
  const summarizer = new OpenRouterConversationSummarizer(client);

  const summary = await summarizer.summarize({
    previousSummary: "Previous facts",
    turns: [
      {
        messageId: "must-not-be-sent",
        userContent: "Question",
        assistantContent: "Answer",
      },
    ],
  });

  assert.equal(summary, "Updated summary");
  assert.match(requests[0]?.messages[0]?.content ?? "", /untrusted data/);
  const input = requests[0]?.messages[1]?.content ?? "";
  assert.match(input, /Previous facts/);
  assert.match(input, /Question/);
  assert.match(input, /Answer/);
  assert.doesNotMatch(input, /must-not-be-sent/);
});
