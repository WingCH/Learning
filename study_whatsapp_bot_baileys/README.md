# 可擴充的個人 WhatsApp 自動回覆 Bot

這是一個使用 [Baileys](https://baileys.wiki/) 及 TypeScript 建立的個人 WhatsApp bot。第一階段功能是收到私人文字訊息後，把內容重複兩次回覆：

```text
收到：hi
回覆：hi hi
```

專案採用分層結構，WhatsApp 連線、認證保存、訊息解析、訊息路由及回覆規則彼此分開，方便日後加入 command、AI 回覆、database、queue 或其他整合。

> Baileys 是非官方 WhatsApp library，與 WhatsApp 沒有從屬關係。請遵守 WhatsApp Terms of Service，切勿用於 bulk messaging 或 spam。

## 系統需求

- Node.js 20.0.0 或以上
- 一個可操作「連結裝置」的 WhatsApp 個人帳號

目前專案鎖定 npm `latest` 的 Baileys 7 release candidate。Baileys v8 仍在開發，其 auth format 及 API 尚未定稿，因此沒有採用 edge build。

## 安裝與首次連線

```bash
npm install
npm run start:dev
```

Terminal 顯示 `WHATSAPP QR RAW BEGIN/END` raw payload 後：

1. 在手機開啟 WhatsApp。
2. 進入「設定 → 連結裝置 → 連結裝置」。
3. 複製 BEGIN／END 之間的單行 raw payload，使用你選擇的 QR generator 生成 QR code。
4. 亦可直接從 `.data/latest-whatsapp-qr.txt` 讀取目前最新 payload；macOS 可執行 `pbcopy < .data/latest-whatsapp-qr.txt`。
5. 使用手機掃描你生成的 QR code。
6. Terminal 顯示「WhatsApp 已連線」後，請另一個帳號傳送 `hi` 給你測試。

認證資料會儲存在 `.data/whatsapp-auth/`。這個目錄已加入 `.gitignore`，不可提交、分享或備份到不受信任的位置；當中的 Signal private keys 應視為與 SSH private key 同等敏感。

Raw QR payload 有時效，而且可用於連結裝置。每次 Baileys 發出新 payload，檔案都會被覆寫；成功連線、斷線或停止 bot 時會自動刪除。不要把 raw payload 傳給其他人。

如果你在手機解除連結，請先停止 bot，移除 `.data/whatsapp-auth/`，再重新執行並掃描新的 QR code。

## 日常開發

```bash
# 修改程式時自動重啟
npm run dev

# 型別檢查及非網絡單元測試
npm run check

# 產生 dist/
npm run build

# 執行已編譯版本
npm start
```

`npm run check` 不會連接 WhatsApp，也不需要真實 session。

## 目前訊息規則

- 只回覆實時收到的 `notify` 訊息，不會回覆 history backfill。
- 忽略由自己帳號發出的訊息，避免無限回覆循環。
- 只回覆 `conversation` 及 `extendedTextMessage` 形式的文字。
- 預設只回覆私人對話；群組訊息不會觸發 bot。
- 忽略 broadcast、status 及 newsletter。
- 自動訊息會作為普通文字直接送出，不會引用原訊息或顯示 quoted reply。
- 使用 bounded in-memory message store 支援 Baileys retry，不會無限佔用記憶體。

## 設定

設定值由 environment variables 讀取。可參考 `.env.example`；專案沒有自動載入 `.env`，執行時需要由 shell、process manager 或 deployment platform 注入。

| 變數 | 預設值 | 用途 |
|---|---|---|
| `BOT_NAME` | `Personal WhatsApp Bot` | 顯示於 Linked Devices 及 log 的名稱 |
| `WHATSAPP_AUTH_DIR` | `.data/whatsapp-auth` | development file auth 路徑 |
| `WHATSAPP_QR_OUTPUT_PATH` | `.data/latest-whatsapp-qr.txt` | 最新 raw QR payload 暫存路徑 |
| `LOG_LEVEL` | `info` | Pino log level |
| `REPLY_TO_GROUPS` | `false` | 是否回覆群組文字訊息 |
| `MAX_RECONNECT_ATTEMPTS` | `8` | 可恢復斷線的最大重連次數 |
| `RECONNECT_BASE_DELAY_MS` | `1000` | exponential backoff 起始延遲 |
| `RECONNECT_MAX_DELAY_MS` | `30000` | exponential backoff 最大延遲 |
| `MAX_MESSAGE_STORE_ENTRIES` | `1000` | in-memory message store 上限 |

例如需要暫時測試群組回覆：

```bash
REPLY_TO_GROUPS=true npm run start:dev
```

## 專案結構

```text
src/
├── application/messages/            # 與 Baileys 無關的訊息規則及 router
├── config/                           # environment 設定與驗證
├── infrastructure/logging/           # structured logger
├── infrastructure/whatsapp/auth/     # 可替換的 auth provider
├── infrastructure/whatsapp/messages/ # Baileys 訊息 adapter 及 store
├── infrastructure/whatsapp/          # socket lifecycle 及重連
└── index.ts                          # composition root
```

新增較高優先次序的規則時，實作 `MessageHandler`，再於 `src/index.ts` 把它放在 `RepeatTextMessageHandler` 前面。Router 會採用第一個回傳結果的 handler，repeat handler 因此可作為 fallback。

## 從本機走向 production

官方文件明確指出 `useMultiFileAuthState` 適合 development／simple bot，不推薦 production。這個專案已透過 `AuthStateProvider` 隔離該實作；正式部署時應新增 SQL 或 NoSQL adapter，完整實作 Baileys `AuthenticationState`／`SignalKeyStore`，並確保每次 `keys.set` 都在 resolve 前持久保存。

同樣地，`MessageContentStore` 目前是 bounded in-memory 實作。需要跨 restart 的可靠 message retry、poll 或多 instance 部署時，應換成 database-backed store，並加入 distributed lock／single-session ownership，避免同一 WhatsApp session 被多個 process 同時連線。
