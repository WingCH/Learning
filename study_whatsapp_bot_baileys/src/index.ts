import { MessageRouter } from "./application/messages/message-router.js";
import { RepeatTextMessageHandler } from "./application/messages/repeat-text-message-handler.js";
import { loadAppConfig } from "./config/app-config.js";
import { createLogger } from "./infrastructure/logging/create-logger.js";
import { FileAuthStateProvider } from "./infrastructure/whatsapp/auth/file-auth-state-provider.js";
import { BaileysMessageConsumer } from "./infrastructure/whatsapp/messages/baileys-message-consumer.js";
import { InMemoryMessageContentStore } from "./infrastructure/whatsapp/messages/in-memory-message-content-store.js";
import { RawQrCodePresenter } from "./infrastructure/whatsapp/qr/raw-qr-code-presenter.js";
import { WhatsAppClient } from "./infrastructure/whatsapp/whatsapp-client.js";

async function main(): Promise<void> {
  const config = loadAppConfig(process.env, process.cwd());
  const logger = createLogger(config.botName, config.logLevel);

  const messageStore = new InMemoryMessageContentStore(
    config.maxMessageStoreEntries,
  );
  const messageRouter = new MessageRouter([
    new RepeatTextMessageHandler(),
  ]);
  const messageConsumer = new BaileysMessageConsumer(
    messageRouter,
    messageStore,
    config.replyToGroups,
    logger.child({ component: "message-consumer" }),
  );
  const client = new WhatsAppClient(
    config,
    new FileAuthStateProvider(config.authDirectory),
    messageConsumer,
    messageStore,
    new RawQrCodePresenter(
      config.qrOutputPath,
      process.stdout,
      logger.child({ component: "qr-code-presenter" }),
    ),
    logger.child({ component: "whatsapp-client" }),
  );

  let isShuttingDown = false;
  const shutdown = async (signal: NodeJS.Signals): Promise<void> => {
    if (isShuttingDown) {
      return;
    }

    isShuttingDown = true;
    logger.info({ signal }, "正在停止 WhatsApp bot。");
    await client.stop();
  };

  process.once("SIGINT", () => {
    void shutdown("SIGINT");
  });
  process.once("SIGTERM", () => {
    void shutdown("SIGTERM");
  });

  await client.start();
}

main().catch((error: unknown) => {
  process.stderr.write(`WhatsApp bot 啟動失敗：${String(error)}\n`);
  process.exitCode = 1;
});
