import type { MessageHandler } from "./message-handler.js";
import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "./message.js";

export class MessageRouter {
  public constructor(private readonly handlers: readonly MessageHandler[]) {}

  public async dispatch(
    message: IncomingTextMessage,
  ): Promise<OutgoingTextMessage | null> {
    for (const handler of this.handlers) {
      const response = await handler.handle(message);
      if (response !== null) {
        return response;
      }
    }

    return null;
  }
}
