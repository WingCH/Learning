import type { MessageHandler } from "../messages/message-handler.js";
import type {
  IncomingTextMessage,
  OutgoingTextMessage,
} from "../messages/message.js";
import type { ChatCommand } from "./chat-command.js";

const helpCommandName = "help";
const commandNamePattern = /^[a-z][a-z0-9-]*$/;

export class CommandMessageHandler implements MessageHandler {
  private readonly commands = new Map<string, ChatCommand>();

  public constructor(commands: readonly ChatCommand[]) {
    for (const command of commands) {
      const normalizedName = normalizeCommandName(command.name);
      if (normalizedName === helpCommandName) {
        throw new Error("help 是 command registry 的保留名稱。");
      }
      if (this.commands.has(normalizedName)) {
        throw new Error(`重複 command：/${normalizedName}`);
      }
      this.commands.set(normalizedName, command);
    }
  }

  public async handle(
    message: IncomingTextMessage,
  ): Promise<OutgoingTextMessage | null> {
    const parsedCommand = parseCommand(message.text);
    if (parsedCommand === null) {
      return null;
    }

    if (parsedCommand.name === helpCommandName) {
      return immediateMessage(this.createHelpText());
    }

    const command = this.commands.get(parsedCommand.name);
    if (command === undefined) {
      return immediateMessage(
        `未知指令：/${parsedCommand.name}\n輸入 /help 查看可用指令。`,
      );
    }

    return command.execute({
      message,
      arguments: parsedCommand.arguments,
    });
  }

  private createHelpText(): string {
    const lines = [
      "可用指令：",
      "/help — 顯示此指令清單",
    ];
    for (const [name, command] of this.commands) {
      lines.push(`/${name} — ${command.description}`);
    }
    return lines.join("\n");
  }
}

interface ParsedCommand {
  readonly name: string;
  readonly arguments: readonly string[];
}

function parseCommand(text: string): ParsedCommand | null {
  const normalizedText = text.trim();
  if (!normalizedText.startsWith("/")) {
    return null;
  }

  const tokens = normalizedText.slice(1).split(/\s+/u);
  const name = tokens[0]?.toLowerCase() ?? "";
  if (!commandNamePattern.test(name)) {
    return {
      name: name || "(空白)",
      arguments: tokens.slice(1),
    };
  }
  return {
    name,
    arguments: tokens.slice(1),
  };
}

function normalizeCommandName(name: string): string {
  const normalizedName = name.trim().toLowerCase();
  if (!commandNamePattern.test(normalizedName)) {
    throw new Error(`Command name 無效：${name}`);
  }
  return normalizedName;
}

function immediateMessage(text: string): OutgoingTextMessage {
  return {
    text,
    quoteOriginal: false,
    onSent: async () => {},
  };
}
