import type {
  ConversationHistoryStore,
  ConversationTurn,
} from "../../application/ai/conversation-history-store.js";
import type { TextCompletionMessage } from "../../application/ai/text-completion-client.js";

export interface InMemoryConversationHistoryConfig {
  readonly maxChats: number;
  readonly maxTurnsPerChat: number;
  readonly maxCharactersPerChat: number;
}

export class InMemoryConversationHistoryStore
  implements ConversationHistoryStore {
  private readonly turnsByChat = new Map<string, ConversationTurn[]>();

  public constructor(
    private readonly config: InMemoryConversationHistoryConfig,
  ) {
    validatePositiveInteger("maxChats", config.maxChats);
    validatePositiveInteger("maxTurnsPerChat", config.maxTurnsPerChat);
    validatePositiveInteger(
      "maxCharactersPerChat",
      config.maxCharactersPerChat,
    );
  }

  public async getMessages(
    chatJid: string,
  ): Promise<readonly TextCompletionMessage[]> {
    const turns = this.turnsByChat.get(chatJid);
    if (turns === undefined) {
      return [];
    }

    this.touch(chatJid, turns);
    return turns.flatMap((turn) => [
      { role: "user" as const, content: turn.userContent },
      { role: "assistant" as const, content: turn.assistantContent },
    ]);
  }

  public async appendTurn(
    chatJid: string,
    turn: ConversationTurn,
  ): Promise<void> {
    const turns = this.turnsByChat.get(chatJid) ?? [];
    if (turns.some((existingTurn) => existingTurn.messageId === turn.messageId)) {
      this.touch(chatJid, turns);
      return;
    }

    turns.push({ ...turn });
    while (turns.length > this.config.maxTurnsPerChat) {
      turns.shift();
    }
    while (
      turns.length > 0 &&
      countCharacters(turns) > this.config.maxCharactersPerChat
    ) {
      turns.shift();
    }

    if (turns.length === 0) {
      this.turnsByChat.delete(chatJid);
      return;
    }

    this.touch(chatJid, turns);
    while (this.turnsByChat.size > this.config.maxChats) {
      const leastRecentlyUsedChat = this.turnsByChat.keys().next().value;
      if (leastRecentlyUsedChat === undefined) {
        break;
      }
      this.turnsByChat.delete(leastRecentlyUsedChat);
    }
  }

  public async clear(chatJid: string): Promise<void> {
    this.turnsByChat.delete(chatJid);
  }

  private touch(chatJid: string, turns: ConversationTurn[]): void {
    this.turnsByChat.delete(chatJid);
    this.turnsByChat.set(chatJid, turns);
  }
}

function countCharacters(turns: readonly ConversationTurn[]): number {
  return turns.reduce(
    (total, turn) =>
      total + turn.userContent.length + turn.assistantContent.length,
    0,
  );
}

function validatePositiveInteger(name: string, value: number): void {
  if (!Number.isSafeInteger(value) || value <= 0) {
    throw new Error(`${name} 必須是正整數。`);
  }
}
