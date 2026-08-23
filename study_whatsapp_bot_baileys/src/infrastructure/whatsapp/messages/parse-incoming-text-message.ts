import {
  isJidGroup,
  type WAMessage,
} from "@whiskeysockets/baileys";

import type { IncomingTextMessage } from "../../../application/messages/message.js";

export function parseIncomingTextMessage(
  message: WAMessage,
): IncomingTextMessage | null {
  const { id, remoteJid } = message.key;
  if (message.key.fromMe || !id || !remoteJid) {
    return null;
  }

  const text =
    message.message?.conversation ??
    message.message?.extendedTextMessage?.text ??
    null;

  if (text === null || text.trim().length === 0) {
    return null;
  }

  return {
    id,
    chatJid: remoteJid,
    text: text.trim(),
    isGroup: isJidGroup(remoteJid) === true,
  };
}
