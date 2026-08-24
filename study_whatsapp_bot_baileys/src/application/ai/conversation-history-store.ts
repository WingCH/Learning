import type { TextCompletionMessage } from "./text-completion-client.js";

export interface ConversationTurn {
  readonly messageId: string;
  readonly userContent: string;
  readonly assistantContent: string;
}

export interface ConversationHistoryStore {
  getMessages(chatJid: string): Promise<readonly TextCompletionMessage[]>;
  appendTurn(chatJid: string, turn: ConversationTurn): Promise<void>;
  clear(chatJid: string): Promise<void>;
}
