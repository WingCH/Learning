import NodeCache from "@cacheable/node-cache";
import type { Boom } from "@hapi/boom";
import makeWASocket, {
  Browsers,
  type BaileysEventMap,
  type CacheStore,
  DisconnectReason,
  fetchLatestBaileysVersion,
  isJidBroadcast,
  isJidNewsletter,
  makeCacheableSignalKeyStore,
  type WASocket,
} from "@whiskeysockets/baileys";
import pino, { type Logger } from "pino";

import type { AppConfig } from "../../config/app-config.js";
import type { AuthStateProvider } from "./auth/auth-state-provider.js";
import type { BaileysMessageConsumer } from "./messages/baileys-message-consumer.js";
import type { MessageContentStore } from "./messages/message-content-store.js";
import type { QrCodePresenter } from "./qr/qr-code-presenter.js";

const terminalDisconnectReasons = new Set<number>([
  DisconnectReason.badSession,
  DisconnectReason.connectionReplaced,
  DisconnectReason.forbidden,
  DisconnectReason.loggedOut,
  DisconnectReason.multideviceMismatch,
]);

export class WhatsAppClient {
  private readonly messageRetryCache: CacheStore;
  private socket: WASocket | null = null;
  private connectTask: Promise<void> | null = null;
  private reconnectTimer: NodeJS.Timeout | null = null;
  private reconnectAttempts = 0;
  private stopping = false;

  public constructor(
    private readonly config: AppConfig,
    private readonly authStateProvider: AuthStateProvider,
    private readonly messageConsumer: BaileysMessageConsumer,
    private readonly messageStore: MessageContentStore,
    private readonly qrCodePresenter: QrCodePresenter,
    private readonly logger: Logger,
  ) {
    this.messageRetryCache = new NodeCache({ useClones: false }) as CacheStore;
  }

  public async start(): Promise<void> {
    this.stopping = false;
    await this.connect();
  }

  public async stop(): Promise<void> {
    this.stopping = true;

    if (this.reconnectTimer !== null) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    const socket = this.socket;
    this.socket = null;
    await Promise.all([
      this.clearQrCode(),
      socket?.end(undefined) ?? Promise.resolve(),
    ]);
  }

  private async connect(): Promise<void> {
    if (this.stopping) {
      return;
    }

    if (this.connectTask !== null) {
      await this.connectTask;
      return;
    }

    this.connectTask = this.createSocket();
    try {
      await this.connectTask;
    } finally {
      this.connectTask = null;
    }
  }

  private async createSocket(): Promise<void> {
    const baileysLogger = pino({ level: "silent" });
    const session = await this.authStateProvider.load();
    const { version } = await fetchLatestBaileysVersion();

    this.logger.info({ version }, "正在連接 WhatsApp。");

    const socket = makeWASocket({
      version,
      auth: {
        creds: session.state.creds,
        keys: makeCacheableSignalKeyStore(session.state.keys, baileysLogger),
      },
      browser: Browsers.macOS(this.config.botName),
      logger: baileysLogger,
      markOnlineOnConnect: false,
      syncFullHistory: false,
      msgRetryCounterCache: this.messageRetryCache,
      shouldIgnoreJid: (jid) =>
        isJidBroadcast(jid) || isJidNewsletter(jid),
      getMessage: async (key) => this.messageStore.get(key),
    });

    this.socket = socket;
    socket.ev.process(async (events) => {
      try {
        if (events["creds.update"] !== undefined) {
          await session.saveCredentials();
        }

        const connectionUpdate = events["connection.update"];
        if (connectionUpdate !== undefined) {
          await this.handleConnectionUpdate(socket, connectionUpdate);
        }

        const messagesUpsert = events["messages.upsert"];
        if (messagesUpsert !== undefined && socket === this.socket) {
          await this.messageConsumer.handle(socket, messagesUpsert);
        }
      } catch (error: unknown) {
        this.logger.error({ err: error }, "處理 Baileys event batch 失敗。");
      }
    });
  }

  private async handleConnectionUpdate(
    socket: WASocket,
    update: BaileysEventMap["connection.update"],
  ): Promise<void> {
    if (socket !== this.socket) {
      return;
    }

    if (update.qr !== undefined) {
      this.logger.info(
        "已收到新的 WhatsApp raw QR payload。請使用最新 payload 自行生成 QR code。",
      );
      try {
        await this.qrCodePresenter.present(update.qr);
      } catch (error: unknown) {
        this.logger.error(
          { err: error },
          "輸出 WhatsApp raw QR payload 失敗。",
        );
      }
    }

    if (update.connection === "open") {
      await this.clearQrCode();
      this.reconnectAttempts = 0;
      this.logger.info("WhatsApp 已連線，自動回覆已啟動。");
      return;
    }

    if (update.connection !== "close") {
      return;
    }

    this.socket = null;
    await this.clearQrCode();
    const statusCode = getDisconnectStatusCode(update.lastDisconnect?.error);

    if (statusCode !== null && terminalDisconnectReasons.has(statusCode)) {
      this.logger.error(
        { statusCode },
        "WhatsApp session 無法自動恢復。若已登出，請移除 auth directory 後重新掃描 QR code。",
      );
      return;
    }

    this.scheduleReconnect(statusCode);
  }

  private scheduleReconnect(statusCode: number | null): void {
    if (this.stopping || this.reconnectTimer !== null) {
      return;
    }

    if (this.reconnectAttempts >= this.config.maxReconnectAttempts) {
      this.logger.error(
        { statusCode, reconnectAttempts: this.reconnectAttempts },
        "已達 WhatsApp 最大重連次數，請檢查網絡及 session 狀態後重新啟動。",
      );
      return;
    }

    this.reconnectAttempts += 1;
    const delayMs = Math.min(
      this.config.reconnectBaseDelayMs * 2 ** (this.reconnectAttempts - 1),
      this.config.reconnectMaxDelayMs,
    );

    this.logger.warn(
      {
        statusCode,
        reconnectAttempt: this.reconnectAttempts,
        delayMs,
      },
      "WhatsApp 連線已中斷，稍後重連。",
    );

    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = null;
      void this.connect().catch((error: unknown) => {
        this.logger.error({ err: error }, "重新建立 WhatsApp socket 失敗。");
        this.scheduleReconnect(null);
      });
    }, delayMs);
  }

  private async clearQrCode(): Promise<void> {
    try {
      await this.qrCodePresenter.clear();
    } catch (error: unknown) {
      this.logger.error(
        { err: error },
        "清除暫存 WhatsApp raw QR payload 失敗。",
      );
    }
  }
}

function getDisconnectStatusCode(error: Error | undefined): number | null {
  const statusCode = (error as Boom | undefined)?.output?.statusCode;
  return typeof statusCode === "number" ? statusCode : null;
}
