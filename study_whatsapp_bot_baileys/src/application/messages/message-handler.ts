import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "./message.js";

export interface MessageHandler {
  handle(message: IncomingTextMessage): Promise<OutgoingTextMessage | null>;
}
