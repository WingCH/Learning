import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "../messages/message.js";

export interface ChatCommandContext {
  readonly message: IncomingTextMessage;
  readonly arguments: readonly string[];
}

export interface ChatCommand {
  readonly name: string;
  readonly description: string;
  execute(context: ChatCommandContext): Promise<OutgoingTextMessage>;
}
