import { config as loadEnvironment } from "dotenv";
import { setTimeout as sleep } from "node:timers/promises";

import { CommandMessageHandler } from "./application/commands/command-message-handler.js";
import { ResetConversationCommand } from "./application/commands/reset-conversation-command.js";
import { AiTextMessageHandler } from "./application/messages/ai-text-message-handler.js";
import { MessageRouter } from "./application/messages/message-router.js";
import { loadAppConfig } from "./config/app-config.js";
import { createLogger } from "./infrastructure/logging/create-logger.js";
import { FileConversationHistoryStore } from "./infrastructure/conversation/file-conversation-history-store.js";
import { OpenRouterChatCompletionClient } from "./infrastructure/openrouter/openrouter-chat-completion-client.js";
import { OpenRouterConversationSummarizer } from "./infrastructure/openrouter/openrouter-conversation-summarizer.js";
import { RandomizedResponseDelayPolicy } from "./infrastructure/timing/randomized-response-delay-policy.js";
import { FileAuthStateProvider } from "./infrastructure/whatsapp/auth/file-auth-state-provider.js";
import { BaileysMessageConsumer } from "./infrastructure/whatsapp/messages/baileys-message-consumer.js";
import { InMemoryMessageContentStore } from "./infrastructure/whatsapp/messages/in-memory-message-content-store.js";
import { KeyedSerialTaskQueue } from "./infrastructure/whatsapp/messages/keyed-serial-task-queue.js";
import { TypingIndicator } from "./infrastructure/whatsapp/messages/typing-indicator.js";
import { RawQrCodePresenter } from "./infrastructure/whatsapp/qr/raw-qr-code-presenter.js";
import { WhatsAppClient } from "./infrastructure/whatsapp/whatsapp-client.js";

async function main(): Promise<void> {
  loadEnvironment({ quiet: true, override: false });
  const config = loadAppConfig(process.env, process.cwd());
  const logger = createLogger(config.botName, config.logLevel);

  const messageStore = new InMemoryMessageContentStore(
    config.maxMessageStoreEntries,
  );
  const openRouterClient = new OpenRouterChatCompletionClient(
    config.openRouter,
    globalThis.fetch,
    logger.child({ component: "openrouter-client" }),
  );
  const summaryClient = new OpenRouterChatCompletionClient(
    {
      ...config.openRouter,
      model: config.conversationHistory.summaryModel,
      appTitle: `${config.botName} Conversation Memory`,
    },
    globalThis.fetch,
    logger.child({ component: "openrouter-summary-client" }),
  );
  const conversationHistoryStore = await FileConversationHistoryStore.open(
    config.conversationHistory,
    new OpenRouterConversationSummarizer(summaryClient),
    logger.child({ component: "conversation-memory" }),
  );
  const messageRouter = new MessageRouter([
    new CommandMessageHandler([
      new ResetConversationCommand(conversationHistoryStore),
    ]),
    new AiTextMessageHandler(
      openRouterClient,
      conversationHistoryStore,
      new RandomizedResponseDelayPolicy(
        config.responseDelay,
        Math.random,
        Date.now,
        async (milliseconds) => sleep(milliseconds),
      ),
    ),
  ]);
  const messageConsumer = new BaileysMessageConsumer(
    messageRouter,
    messageStore,
    config.replyToGroups,
    new KeyedSerialTaskQueue(),
    new TypingIndicator(
      8_000,
      logger.child({ component: "typing-indicator" }),
    ),
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
