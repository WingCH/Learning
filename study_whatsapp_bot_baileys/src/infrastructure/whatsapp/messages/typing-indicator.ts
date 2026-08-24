import type { WASocket } from "@whiskeysockets/baileys";
import type { Logger } from "pino";

type TypingPresence = "composing" | "paused";
type PresenceSocket = Pick<WASocket, "sendPresenceUpdate">;

export class TypingIndicator {
  public constructor(
    private readonly refreshIntervalMs: number,
    private readonly logger: Logger,
  ) {
    if (!Number.isSafeInteger(refreshIntervalMs) || refreshIntervalMs <= 0) {
      throw new Error("Typing indicator refresh interval 必須是正整數。");
    }
  }

  public async run<T>(
    socket: PresenceSocket,
    chatJid: string,
    operation: () => Promise<T>,
  ): Promise<T> {
    let presenceTail: Promise<void> = Promise.resolve();
    const queuePresence = (presence: TypingPresence): Promise<void> => {
      const result = presenceTail.then(() =>
        this.sendPresence(socket, chatJid, presence),
      );
      presenceTail = result.then(
        () => undefined,
        () => undefined,
      );
      return result;
    };

    await queuePresence("composing");
    const refreshTimer = setInterval(() => {
      void queuePresence("composing");
    }, this.refreshIntervalMs);
    refreshTimer.unref();

    try {
      return await operation();
    } finally {
      clearInterval(refreshTimer);
      await queuePresence("paused");
    }
  }

  private async sendPresence(
    socket: PresenceSocket,
    chatJid: string,
    presence: TypingPresence,
  ): Promise<void> {
    try {
      await socket.sendPresenceUpdate(presence, chatJid);
    } catch (error: unknown) {
      this.logger.warn(
        { err: error, presence },
        "WhatsApp typing presence 送出失敗，繼續處理訊息。",
      );
    }
  }
}
