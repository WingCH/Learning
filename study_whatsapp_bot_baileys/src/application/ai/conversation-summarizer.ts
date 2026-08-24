import type { ConversationTurn } from "./conversation-history-store.js";

export interface ConversationSummaryRequest {
  readonly previousSummary: string | null;
  readonly turns: readonly ConversationTurn[];
}

export interface ConversationSummarizer {
  summarize(request: ConversationSummaryRequest): Promise<string>;
}
