export type TextCompletionRole = "user" | "assistant";

export interface TextCompletionMessage {
  readonly role: TextCompletionRole;
  readonly content: string;
}

export interface TextCompletionRequest {
  readonly messages: readonly TextCompletionMessage[];
}

export interface TextCompletionClient {
  complete(request: TextCompletionRequest): Promise<string>;
}
