import type {
  proto,
  WAMessage,
  WAMessageKey,
} from "@whiskeysockets/baileys";

export interface MessageContentStore {
  get(key: WAMessageKey): Promise<proto.IMessage | undefined>;
  put(message: WAMessage): void;
}
