import {
  isJidGroup,
  normalizeMessageContent,
  type proto,
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

  const normalizedMessage = normalizeMessageContent(message.message);
  const text = extractText(normalizedMessage);

  if (text === null || text.trim().length === 0) {
    return null;
  }

  return {
    id,
    chatJid: remoteJid,
    text: text.trim(),
    quotedText: extractQuotedText(normalizedMessage),
    isGroup: isJidGroup(remoteJid) === true,
  };
}

function extractQuotedText(message: proto.IMessage | undefined): string | null {
  const quotedMessage = message?.extendedTextMessage?.contextInfo?.quotedMessage;
  const quotedText = extractText(normalizeMessageContent(quotedMessage));
  return quotedText === null || quotedText.trim().length === 0
    ? null
    : quotedText.trim();
}

function extractText(message: proto.IMessage | undefined): string | null {
  return message?.conversation ??
    message?.extendedTextMessage?.text ??
    message?.imageMessage?.caption ??
    message?.videoMessage?.caption ??
    null;
}
