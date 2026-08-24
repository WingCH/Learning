import type { TextCompletionClient } from "../ai/text-completion-client.js";
import type { ConversationHistoryStore } from "../ai/conversation-history-store.js";
import type { MessageHandler } from "./message-handler.js";
import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "./message.js";
import type { ResponseDelayPolicy } from "./response-delay-policy.js";

export class AiTextMessageHandler implements MessageHandler {
  public constructor(
    private readonly textCompletionClient: TextCompletionClient,
    private readonly conversationHistoryStore: ConversationHistoryStore,
    private readonly responseDelayPolicy: ResponseDelayPolicy,
  ) {}

  public async handle(
    message: IncomingTextMessage,
  ): Promise<OutgoingTextMessage | null> {
    const userMessage = message.text.trim();
    if (userMessage.length === 0) {
      return null;
    }

    const responseDelay = this.responseDelayPolicy.begin();
    const history = await this.conversationHistoryStore.getMessages(
      message.chatJid,
    );
    const completion = (
      await this.textCompletionClient.complete({
        messages: [
          ...history,
          {
            role: "user",
            content: formatCurrentMessage(userMessage, message.quotedText),
          },
        ],
      })
    ).trim();
    if (completion.length === 0) {
      throw new Error("OpenRouter 回傳空白內容。");
    }
    await responseDelay.wait();

    return {
      text: completion,
      quoteOriginal: false,
      onSent: async () => {
        await this.conversationHistoryStore.appendTurn(message.chatJid, {
          messageId: message.id,
          userContent: userMessage,
          assistantContent: completion,
        });
      },
    };
  }
}

function formatCurrentMessage(
  currentMessage: string,
  quotedMessage: string | null,
): string {
  if (quotedMessage === null) {
    return currentMessage;
  }

  return [
    "The current WhatsApp message is a reply to a quoted message.",
    "Use both fields as conversation context:",
    JSON.stringify({ quotedMessage, currentMessage }),
  ].join("\n");
}
