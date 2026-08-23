import type {
  proto,
  WAMessage,
  WAMessageKey,
} from "@whiskeysockets/baileys";

import type { MessageContentStore } from "./message-content-store.js";

export class InMemoryMessageContentStore implements MessageContentStore {
  private readonly messages = new Map<string, proto.IMessage>();

  public constructor(private readonly maxEntries: number) {
    if (!Number.isSafeInteger(maxEntries) || maxEntries <= 0) {
      throw new Error("maxEntries 必須是正整數。");
    }
  }

  public async get(key: WAMessageKey): Promise<proto.IMessage | undefined> {
    const storeKey = createStoreKey(key);
    return storeKey === null ? undefined : this.messages.get(storeKey);
  }

  public put(message: WAMessage): void {
    if (message.message === null || message.message === undefined) {
      return;
    }

    const storeKey = createStoreKey(message.key);
    if (storeKey === null) {
      return;
    }

    this.messages.delete(storeKey);
    this.messages.set(storeKey, message.message);

    while (this.messages.size > this.maxEntries) {
      const oldestKey = this.messages.keys().next().value;
      if (oldestKey === undefined) {
        break;
      }
      this.messages.delete(oldestKey);
    }
  }
}

function createStoreKey(key: WAMessageKey): string | null {
  if (!key.remoteJid || !key.id) {
    return null;
  }

  return `${key.remoteJid}:${key.id}`;
}
