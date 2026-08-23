import { chmod, lstat, mkdir, readdir } from "node:fs/promises";
import { join } from "node:path";

import { useMultiFileAuthState } from "@whiskeysockets/baileys";

import type {
  AuthSession,
  AuthStateProvider,
} from "./auth-state-provider.js";

export class FileAuthStateProvider implements AuthStateProvider {
  public constructor(private readonly directory: string) {}

  public async load(): Promise<AuthSession> {
    process.umask(0o077);
    await mkdir(this.directory, { recursive: true, mode: 0o700 });
    await secureAuthDirectory(this.directory);

    const { state, saveCreds } = await useMultiFileAuthState(this.directory);

    return {
      state,
      saveCredentials: async () => {
        await saveCreds();
        await secureAuthDirectory(this.directory);
      },
    };
  }
}

async function secureAuthDirectory(directory: string): Promise<void> {
  await chmod(directory, 0o700);

  const entries = await readdir(directory);
  for (const entry of entries) {
    const entryPath = join(directory, entry);
    const entryStats = await lstat(entryPath);

    if (entryStats.isSymbolicLink()) {
      continue;
    }
    if (entryStats.isDirectory()) {
      await secureAuthDirectory(entryPath);
      continue;
    }
    if (entryStats.isFile()) {
      await chmod(entryPath, 0o600);
    }
  }
}
