import type {
  BaileysEventMap,
  WASocket,
} from "@whiskeysockets/baileys";
import type { Logger } from "pino";

import type { MessageRouter } from "../../../application/messages/message-router.js";
import type { MessageContentStore } from "./message-content-store.js";
import { parseIncomingTextMessage } from "./parse-incoming-text-message.js";
import type { KeyedSerialTaskQueue } from "./keyed-serial-task-queue.js";

export class BaileysMessageConsumer {
  public constructor(
    private readonly router: MessageRouter,
    private readonly messageStore: MessageContentStore,
    private readonly replyToGroups: boolean,
    private readonly taskQueue: KeyedSerialTaskQueue,
    private readonly logger: Logger,
  ) {}

  public async handle(
    socket: WASocket,
    event: BaileysEventMap["messages.upsert"],
  ): Promise<void> {
    for (const message of event.messages) {
      this.messageStore.put(message);
    }

    if (event.type !== "notify") {
      return;
    }

    for (const rawMessage of event.messages) {
      try {
        const message = parseIncomingTextMessage(rawMessage);
        if (message === null || (message.isGroup && !this.replyToGroups)) {
          continue;
        }

        await this.taskQueue.run(message.chatJid, async () => {
          const response = await this.router.dispatch(message);
          if (response === null) {
            return;
          }

          const sendOptions = response.quoteOriginal
            ? { quoted: rawMessage }
            : undefined;

          await socket.sendMessage(
            message.chatJid,
            { text: response.text },
            sendOptions,
          );
          await response.onSent();

          this.logger.info(
            {
              chatJid: message.chatJid,
              messageId: message.id,
              isGroup: message.isGroup,
            },
            "已發送自動訊息。",
          );
        });
      } catch (error: unknown) {
        this.logger.error(
          {
            err: error,
            chatJid: rawMessage.key.remoteJid,
            messageId: rawMessage.key.id,
          },
          "處理 WhatsApp 訊息失敗。",
        );
      }
    }
  }
}
