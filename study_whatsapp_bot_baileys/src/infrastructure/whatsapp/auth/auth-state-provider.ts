import type { AuthenticationState } from "@whiskeysockets/baileys";

export interface AuthSession {
  readonly state: AuthenticationState;
  readonly saveCredentials: () => Promise<void>;
}

export interface AuthStateProvider {
  load(): Promise<AuthSession>;
}
