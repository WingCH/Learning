import type {
  BaileysEventMap,
  WASocket,
} from "@whiskeysockets/baileys";
import type { Logger } from "pino";

import type { MessageRouter } from "../../../application/messages/message-router.js";
import type { MessageContentStore } from "./message-content-store.js";
import { parseIncomingTextMessage } from "./parse-incoming-text-message.js";
import type { KeyedSerialTaskQueue } from "./keyed-serial-task-queue.js";
import type { TypingIndicator } from "./typing-indicator.js";

export class BaileysMessageConsumer {
  public constructor(
    private readonly router: MessageRouter,
    private readonly messageStore: MessageContentStore,
    private readonly replyToGroups: boolean,
    private readonly taskQueue: KeyedSerialTaskQueue,
    private readonly typingIndicator: TypingIndicator,
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

    await this.markInboundMessagesRead(socket, event.messages);

    for (const rawMessage of event.messages) {
      try {
        const message = parseIncomingTextMessage(rawMessage);
        if (message === null || (message.isGroup && !this.replyToGroups)) {
          continue;
        }

        await this.taskQueue.run(message.chatJid, async () =>
          this.typingIndicator.run(socket, message.chatJid, async () => {
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
          }),
        );
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

  private async markInboundMessagesRead(
    socket: WASocket,
    messages: BaileysEventMap["messages.upsert"]["messages"],
  ): Promise<void> {
    const keys = messages
      .filter((message) =>
        message.key.fromMe !== true &&
        Boolean(message.key.id) &&
        Boolean(message.key.remoteJid),
      )
      .map((message) => message.key);
    if (keys.length === 0) {
      return;
    }

    try {
      await socket.readMessages(keys);
      this.logger.debug(
        { messageCount: keys.length },
        "已送出 WhatsApp read receipts。",
      );
    } catch (error: unknown) {
      this.logger.warn(
        { err: error, messageCount: keys.length },
        "WhatsApp read receipts 送出失敗，繼續處理訊息。",
      );
    }
  }
}
