import type { MessageHandler } from "./message-handler.js";
import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "./message.js";

export class RepeatTextMessageHandler implements MessageHandler {
  public async handle(
    message: IncomingTextMessage,
  ): Promise<OutgoingTextMessage | null> {
    const text = message.text.trim();
    if (text.length === 0) {
      return null;
    }

    return {
      text: `${text} ${text}`,
      quoteOriginal: false,
    };
  }
}
