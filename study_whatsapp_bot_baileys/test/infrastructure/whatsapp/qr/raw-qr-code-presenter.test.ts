import assert from "node:assert/strict";
import { access, mkdtemp, readFile, rm, stat } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Writable } from "node:stream";
import test from "node:test";

import pino from "pino";

import { RawQrCodePresenter } from "../../../../src/infrastructure/whatsapp/qr/raw-qr-code-presenter.js";

test("輸出 raw payload 並以 0600 權限保存最新內容", async () => {
  const temporaryDirectory = await mkdtemp(
    join(tmpdir(), "whatsapp-qr-presenter-"),
  );
  const outputPath = join(temporaryDirectory, "latest-qr.txt");
  let terminalOutput = "";
  const terminal = new Writable({
    write(chunk, _encoding, callback) {
      terminalOutput += chunk.toString();
      callback();
    },
  });
  const presenter = new RawQrCodePresenter(
    outputPath,
    terminal,
    pino({ level: "silent" }),
  );

  try {
    await presenter.present("raw-payload-1");

    assert.equal(await readFile(outputPath, "utf8"), "raw-payload-1");
    assert.equal((await stat(outputPath)).mode & 0o777, 0o600);
    assert.match(terminalOutput, /WHATSAPP QR RAW BEGIN/);
    assert.match(terminalOutput, /raw-payload-1/);
    assert.match(terminalOutput, /WHATSAPP QR RAW END/);
  } finally {
    await rm(temporaryDirectory, { recursive: true, force: true });
  }
});

test("新 payload 覆寫舊內容，clear 會刪除暫存檔", async () => {
  const temporaryDirectory = await mkdtemp(
    join(tmpdir(), "whatsapp-qr-presenter-"),
  );
  const outputPath = join(temporaryDirectory, "latest-qr.txt");
  const terminal = new Writable({
    write(_chunk, _encoding, callback) {
      callback();
    },
  });
  const presenter = new RawQrCodePresenter(
    outputPath,
    terminal,
    pino({ level: "silent" }),
  );

  try {
    await presenter.present("raw-payload-1");
    await presenter.present("raw-payload-2");
    assert.equal(await readFile(outputPath, "utf8"), "raw-payload-2");

    await presenter.clear();
    await assert.rejects(access(outputPath), { code: "ENOENT" });
    await presenter.clear();
  } finally {
    await rm(temporaryDirectory, { recursive: true, force: true });
  }
});
