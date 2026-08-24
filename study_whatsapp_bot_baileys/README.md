# 可擴充的個人 WhatsApp AI 自動訊息 Bot

這是一個使用 [Baileys](https://baileys.wiki/)、OpenRouter 及 TypeScript 建立的個人 WhatsApp bot。收到私人文字訊息後，bot 會把內容傳給 OpenRouter preset，再把 model response 作為普通 WhatsApp 訊息直接送出。

```text
收到：Hello! How are you today?
送出：<@preset/whatsapp-auto-reply 的 response>
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
cp .env.example .env
chmod 600 .env
# 編輯 .env，填入 OPENROUTER_API_KEY
npm run start:dev
```

Terminal 顯示 `WHATSAPP QR RAW BEGIN/END` raw payload 後：

1. 在手機開啟 WhatsApp。
2. 進入「設定 → 連結裝置 → 連結裝置」。
3. 複製 BEGIN／END 之間的單行 raw payload，使用你選擇的 QR generator 生成 QR code。
4. 亦可直接從 `.data/latest-whatsapp-qr.txt` 讀取目前最新 payload；macOS 可執行 `pbcopy < .data/latest-whatsapp-qr.txt`。
5. 使用手機掃描你生成的 QR code。
6. Terminal 顯示「WhatsApp 已連線」後，請另一個帳號傳送文字訊息測試 OpenRouter response。

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

- 只處理實時收到的 `notify` 訊息，不會處理 history backfill。
- 忽略由自己帳號發出的訊息，避免無限回覆循環。
- 處理一般文字、extended text，以及 image／video caption。
- 預設只回覆私人對話；群組訊息不會觸發 bot。
- 忽略 broadcast、status 及 newsletter。
- 每個 chat 會在 private file 保留有上限的 user／assistant sliding history，再連同目前訊息傳給 `@preset/whatsapp-auto-reply`。
- 使用 WhatsApp Reply 時，`contextInfo.quotedMessage` 的文字會明確加入目前 user context；支援 ephemeral／view-once normalization。
- 同一 chat 的 requests 會依序處理，快速連續訊息不會讀到相同的舊 history snapshot。
- History 只會在 WhatsApp 訊息成功送出後加入，失敗的 response 不會污染下一輪 context。
- 達到 turn／character threshold 時，較舊 turns 會在背景交給 AI 壓縮成 summary；OpenRouter request 會串接 summary、最新 turns 及目前訊息。
- 壓縮前先 atomic 保存原始 turn；AI 壓縮失敗時保留原始資料並於下次重試，hard limits 防止無限增長。
- Model response 會作為普通文字直接送出，不會引用原訊息或顯示 quoted reply。
- OpenRouter 失敗、逾時或回傳空白內容時不會把內部錯誤傳給聯絡人。
- 等待 command／OpenRouter／WhatsApp send 時會顯示「正在輸入…」，每 8 秒刷新，完成或失敗時送出 `paused` 清除狀態。
- AI response 設有隨機 minimum delivery time（預設 2–5 秒）；API 較快時等到 deadline，API 較慢時不再額外延遲。Commands 保持即時。
- 使用 bounded in-memory message store 支援 Baileys retry，不會無限佔用記憶體。

## Commands

Slash commands 會在 AI handler 前處理，不會傳送至 OpenRouter。Command name 大小寫不敏感。

| Command | 用途 |
|---|---|
| `/help` | 顯示由 command registry 自動產生的可用指令清單 |
| `/reset` | 清除目前 chat 的 summary 與 recent turns；其他 chats 不受影響 |

`/reset` 會先成功送出確認訊息，再 atomic 更新 conversation memory file。未知 slash command 會提示使用 `/help`，不會被當成一般 AI message。

## 設定

設定值由 environment variables 讀取。Application 啟動時會自動載入 project root 的 gitignored `.env`，但不會覆蓋 shell、process manager 或 deployment platform 已注入的值。

| 變數 | 預設值 | 用途 |
|---|---|---|
| `BOT_NAME` | `Personal WhatsApp Bot` | 顯示於 Linked Devices 及 log 的名稱 |
| `WHATSAPP_AUTH_DIR` | `.data/whatsapp-auth` | development file auth 路徑 |
| `WHATSAPP_QR_OUTPUT_PATH` | `.data/latest-whatsapp-qr.txt` | 最新 raw QR payload 暫存路徑 |
| `OPENROUTER_API_KEY` | 必填 | OpenRouter Bearer token；只放在 `.env` 或 deployment secret |
| `OPENROUTER_MODEL` | `@preset/whatsapp-auto-reply` | OpenRouter preset／model ID |
| `OPENROUTER_ENDPOINT` | `https://openrouter.ai/api/v1/chat/completions` | Chat Completions endpoint，必須為 HTTPS |
| `OPENROUTER_REQUEST_TIMEOUT_MS` | `30000` | 每次 OpenRouter request timeout |
| `OPENROUTER_HTTP_REFERER` | 空白 | 選填的 OpenRouter attribution URL |
| `CONVERSATION_MEMORY_PATH` | `.data/conversation-memory.json` | Versioned private conversation memory file |
| `CONVERSATION_HISTORY_MAX_CHATS` | `100` | 最多保留的 active chats；超出時按 LRU 移除 |
| `CONVERSATION_COMPACTION_TRIGGER_TURNS` | `20` | 達到此 turn 數時觸發 AI 壓縮 |
| `CONVERSATION_COMPACTION_TRIGGER_CHARACTERS` | `12000` | 達到此總字元數時觸發 AI 壓縮 |
| `CONVERSATION_COMPACTION_KEEP_RECENT_TURNS` | `8` | 每次壓縮後保留的最新 turns |
| `CONVERSATION_MAX_SUMMARY_CHARACTERS` | `4000` | 壓縮 summary 字元上限 |
| `CONVERSATION_HARD_MAX_TURNS_PER_CHAT` | `40` | AI 壓縮持續失敗時的安全 hard cap |
| `CONVERSATION_HARD_MAX_CHARACTERS_PER_CHAT` | `24000` | AI 壓縮持續失敗時的字元 hard cap |
| `OPENROUTER_SUMMARY_MODEL` | `@preset/whatsapp-auto-reply` | 背景 conversation summarizer 使用的 preset／model |
| `AI_RESPONSE_DELAY_MIN_MS` | `2000` | AI 自動訊息最短 delivery time |
| `AI_RESPONSE_DELAY_MAX_MS` | `5000` | AI 自動訊息最長隨機 minimum delivery time |
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
├── application/ai/                  # AI completion port
├── application/messages/            # 與 Baileys 無關的訊息規則及 router
├── config/                           # environment 設定與驗證
├── infrastructure/logging/           # structured logger
├── infrastructure/conversation/      # persistent、bounded、AI-compacted memory
├── infrastructure/openrouter/        # OpenRouter fetch adapter
├── infrastructure/whatsapp/auth/     # 可替換的 auth provider
├── infrastructure/whatsapp/messages/ # Baileys 訊息 adapter 及 store
├── infrastructure/whatsapp/          # socket lifecycle 及重連
└── index.ts                          # composition root
```

`AiTextMessageHandler` 只依賴 `TextCompletionClient` interface；OpenRouter transport、API schema 與 timeout 都留在 infrastructure adapter。日後若更換 AI provider，只需新增另一個 `TextCompletionClient` 實作。

## 私隱與費用

每則符合規則的 WhatsApp inbound text 都會傳送至 OpenRouter，並可能再由 OpenRouter 傳給 preset 所選的 model provider。使用 personal account 前，請確認訊息內容適合交由第三方 AI provider 處理，並留意 preset 所用 model 的 token 費用。API key、WhatsApp auth state 及 raw QR 均不可提交或分享。

Conversation history 保存於 gitignored `.data/conversation-memory.json`，directory 權限為 `0700`、file 權限為 `0600`，並以 same-directory temp file、flush 及 atomic rename 更新。Process restart 會載入該 file，summary 與 recent turns 因而保留。

此檔案是明文 JSON，內容可能包含私人對話；不要同步、分享或備份到不受信任的位置。它有 chat／turn／character／summary／hard-cap 多重界限，但 application 啟動前、又從未被保存的 WhatsApp 舊訊息不會自動補入。需要更嚴格的跨主機 production 儲存時，應把相同 `ConversationHistoryStore` interface 換成具加密、retention policy 及刪除流程的 database adapter。

## 從本機走向 production

官方文件明確指出 `useMultiFileAuthState` 適合 development／simple bot，不推薦 production。這個專案已透過 `AuthStateProvider` 隔離該實作；正式部署時應新增 SQL 或 NoSQL adapter，完整實作 Baileys `AuthenticationState`／`SignalKeyStore`，並確保每次 `keys.set` 都在 resolve 前持久保存。

同樣地，`MessageContentStore` 目前是 bounded in-memory 實作。需要跨 restart 的可靠 message retry、poll 或多 instance 部署時，應換成 database-backed store，並加入 distributed lock／single-session ownership，避免同一 WhatsApp session 被多個 process 同時連線。
