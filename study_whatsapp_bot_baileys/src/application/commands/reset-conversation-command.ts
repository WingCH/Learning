import type { ConversationHistoryStore } from "../ai/conversation-history-store.js";
import type { OutgoingTextMessage } from "../messages/message.js";
import type {
  ChatCommand,
  ChatCommandContext,
} from "./chat-command.js";

export class ResetConversationCommand implements ChatCommand {
  public readonly name = "reset";
  public readonly description = "清除目前 chat 的 AI 對話記憶";

  public constructor(
    private readonly conversationHistoryStore: ConversationHistoryStore,
  ) {}

  public async execute(
    context: ChatCommandContext,
  ): Promise<OutgoingTextMessage> {
    if (context.arguments.length > 0) {
      return {
        text: "用法：/reset",
        quoteOriginal: false,
        onSent: async () => {},
      };
    }

    return {
      text: "對話記憶已清除。",
      quoteOriginal: false,
      onSent: async () => {
        await this.conversationHistoryStore.clear(
          context.message.chatJid,
        );
      },
    };
  }
}
