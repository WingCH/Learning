export interface IncomingTextMessage {
  readonly id: string;
  readonly chatJid: string;
  readonly text: string;
  readonly quotedText: string | null;
  readonly isGroup: boolean;
}

export interface OutgoingTextMessage {
  readonly text: string;
  readonly quoteOriginal: boolean;
  readonly onSent: () => Promise<void>;
}
