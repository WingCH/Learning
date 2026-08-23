import { chmod, mkdir, unlink, writeFile } from "node:fs/promises";
import { dirname } from "node:path";

import type { Logger } from "pino";

import type { QrCodePresenter } from "./qr-code-presenter.js";

const rawQrStartMarker = "===== WHATSAPP QR RAW BEGIN =====";
const rawQrEndMarker = "===== WHATSAPP QR RAW END =====";

export class RawQrCodePresenter implements QrCodePresenter {
  public constructor(
    private readonly outputPath: string,
    private readonly terminal: NodeJS.WritableStream,
    private readonly logger: Logger,
  ) {}

  public async present(payload: string): Promise<void> {
    if (payload.length === 0) {
      throw new Error("WhatsApp QR payload 不可為空白。");
    }

    this.terminal.write(
      [
        "",
        rawQrStartMarker,
        payload,
        rawQrEndMarker,
        `最新 raw payload 檔案：${this.outputPath}`,
        `macOS 複製指令：pbcopy < \"${this.outputPath}\"`,
        "",
      ].join("\n"),
    );

    await mkdir(dirname(this.outputPath), { recursive: true });
    await writeFile(this.outputPath, payload, {
      encoding: "utf8",
      mode: 0o600,
    });
    await chmod(this.outputPath, 0o600);

    this.logger.info(
      { qrOutputPath: this.outputPath },
      "最新 WhatsApp raw QR payload 已更新。",
    );
  }

  public async clear(): Promise<void> {
    try {
      await unlink(this.outputPath);
      this.logger.debug(
        { qrOutputPath: this.outputPath },
        "已移除暫存 WhatsApp raw QR payload。",
      );
    } catch (error: unknown) {
      if (isMissingFileError(error)) {
        return;
      }
      throw error;
    }
  }
}

function isMissingFileError(error: unknown): boolean {
  return error instanceof Error &&
    "code" in error &&
    error.code === "ENOENT";
}
