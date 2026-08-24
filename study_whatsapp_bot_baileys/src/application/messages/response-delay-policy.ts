export interface PendingResponseDelay {
  wait(): Promise<void>;
}

export interface ResponseDelayPolicy {
  begin(): PendingResponseDelay;
}
