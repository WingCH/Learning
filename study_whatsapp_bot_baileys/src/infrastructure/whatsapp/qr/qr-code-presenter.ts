export interface QrCodePresenter {
  present(payload: string): Promise<void>;
  clear(): Promise<void>;
}
