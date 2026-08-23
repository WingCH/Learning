import assert from "node:assert/strict";
import {
  chmod,
  mkdtemp,
  mkdir,
  rm,
  stat,
  symlink,
  writeFile,
} from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import { FileAuthStateProvider } from "../../../../src/infrastructure/whatsapp/auth/file-auth-state-provider.js";

test("把既有 auth directory 及 files 收緊為 private permissions", async () => {
  const temporaryDirectory = await mkdtemp(
    join(tmpdir(), "whatsapp-auth-provider-"),
  );
  const authDirectory = join(temporaryDirectory, "auth");
  const nestedDirectory = join(authDirectory, "nested");
  const authFile = join(nestedDirectory, "existing-key.json");
  const externalFile = join(temporaryDirectory, "external.txt");
  const authSymlink = join(authDirectory, "external-link");
  const previousUmask = process.umask();

  try {
    await mkdir(nestedDirectory, { recursive: true, mode: 0o755 });
    await writeFile(authFile, "{}", { mode: 0o644 });
    await writeFile(externalFile, "external", { mode: 0o644 });
    await chmod(authDirectory, 0o755);
    await chmod(nestedDirectory, 0o755);
    await chmod(authFile, 0o644);
    await chmod(externalFile, 0o644);
    await symlink(externalFile, authSymlink);

    await new FileAuthStateProvider(authDirectory).load();

    assert.equal((await stat(authDirectory)).mode & 0o777, 0o700);
    assert.equal((await stat(nestedDirectory)).mode & 0o777, 0o700);
    assert.equal((await stat(authFile)).mode & 0o777, 0o600);
    assert.equal((await stat(externalFile)).mode & 0o777, 0o644);
    assert.equal(process.umask(), 0o077);
  } finally {
    process.umask(previousUmask);
    await rm(temporaryDirectory, { recursive: true, force: true });
  }
});
