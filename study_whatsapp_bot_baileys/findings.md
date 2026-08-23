# 查核結果

## 工作目錄

- 路徑：`/Users/wingchan/Project/Learning/study_whatsapp_bot_baileys`
- 初始狀態：沒有專案檔案。
- 此目錄位於較大的 Git repository 內；其他相鄰專案已有未提交變更，與本任務無關。

## 待查核

- Baileys 目前 npm package 名稱與 Node.js 版本需求。
- QR code／connection lifecycle 的官方建議寫法。
- `messages.upsert` 的訊息過濾與文字擷取方式。
- 認證狀態的保存方式及官方安全警告。

## Context7 初步結果

- Baileys 官方 repository 對應的 Context7 library ID 是 `/whiskeysockets/baileys`，來源信譽為 High。
- 另有官方 wiki site 的文件索引；後續會以官方 repository 與 `baileys.wiki` 交叉查核。

## Context7 API 查核

- package import 仍以 `@whiskeysockets/baileys` 的 `makeWASocket` 為核心。
- 使用 `connection.update` 監察連線；`loggedOut` 等不可恢復原因不應無限重連，可恢復錯誤應以 backoff 重連。
- auth credentials 更新時需訂閱 `creds.update` 並保存。
- 新訊息來自 `messages.upsert`；event 可包含多個訊息，因此必須逐一處理，而不是只取第一項。
- `type === 'notify'` 表示在線時新收到的訊息；`append`／`prepend` 可能是歷史資料，不應觸發自動回覆。
- `sendMessage(jid, { text }, { quoted: message })` 可回覆並引用原訊息。
- `useMultiFileAuthState` 適合本機範例／初期專案，但其是否屬 production 推薦仍需以官方 wiki 原文確認。
- Baileys 會直接把 raw pairing payload 放在 `connection.update.qr`；application 可以原樣輸出或交給其他 presenter，不需要從 ASCII QR 反向解析。
- `connection === 'open'` 代表 QR 已完成用途；`connection === 'close'` 或 application 主動 `socket.end()` 時亦應清除暫存 QR。

## Baileys 官方文件查核

- 新專案應使用 npm 的 stable `@whiskeysockets/baileys`，而不是沒有穩定性保證的 GitHub edge build。
- 最低需求為 Node.js 20；package 有 `preinstall` check。
- `printQRInTerminal` 已 deprecated；官方現在要求監聽 `connection.update` 的 `qr` 並自行用 `qrcode-terminal` render。
- 官方 Quickstart 明確要求：
  - `messages.upsert` 只處理 `type === 'notify'`。
  - 遍歷 event 內全部 `messages`。
  - 忽略 `message.key.fromMe`，避免 bot 回覆自己及形成循環。
  - 訂閱 `creds.update` 保存 session。
- `useMultiFileAuthState` 會把 credentials 與 Signal keys 儲存在本機；官方要求 auth folder 放在 source tree 外並加入 `.gitignore`，因為當中含長期 cryptographic keys。
- 初次執行需在手機 WhatsApp 進入「設定 → 連結裝置 → 連結裝置」掃描 QR；後續會重用已保存 credentials。
- 官方聲明 Baileys 是非官方 library，應遵守 WhatsApp Terms of Service，不能用於 bulk messaging、spam 或 stalkerware。

## 官方長期架構建議

- 官方 Session management 明確指出 `useMultiFileAuthState` 不推薦用於 production；它只適合 development／simple bot。production 應實作由 SQL 或 NoSQL database 支援的 `AuthenticationState`／`SignalKeyStore`。
- 目前先用 file auth 讓個人 bot 可以立即運作，但會包在 auth provider 邊界內，日後可換成 database adapter，而不用改動訊息處理或連線主流程。
- Signal credentials 與 keys 必須一起保存；keys 的 `set` 必須在 resolve 前完成 durable persistence。
- `makeCacheableSignalKeyStore` 可降低 Signal key store I/O，官方 production-oriented 範例有採用。
- 官方 Events 文件指出：多數 application 應優先用 `sock.ev.process`，在同一個 async tick 批次處理事件，以避免 partial state update；本專案會依此設計。
- typed event payload 由 `BaileysEventMap` 提供，適合保留 TypeScript 嚴格檢查。
- 一般文字目前需兼容 `message.conversation` 與 `message.extendedTextMessage.text`；解析邏輯應獨立成 module，方便日後加入其他 message type。

## Socket 設定與版本方向

- `auth` 是唯一真正必要的 `SocketConfig`；development 使用 file auth，production 換成 database-backed implementation。
- 使用 `Browsers` preset，而不是手寫 browser tuple。
- `markOnlineOnConnect: false` 可保留個人手機的 push notification，符合這個 personal account bot 的需求。
- 本 bot 不需要歷史訊息，因此設定 `syncFullHistory: false`，降低初次啟動時間與記憶體用量。
- `shouldIgnoreJid` 可在解密／event 層忽略 broadcast 與 newsletter，避免意外自動回覆 status／newsletter。
- `msgRetryCounterCache` 應放在 socket 重啟範圍之外，以免 reconnect 後失去 retry count。
- `getMessage` 是訊息 retry 可靠性的重要 callback；會抽象為 message store，第一版先提供 bounded in-memory store，日後可換 database。
- Baileys internal logger 不應直接繼承 application `info` level，因為它會輸出 WebSocket handshake／pairing 細節；依官方 production 範例使用獨立 `silent` logger，application lifecycle 另行記錄。
- Baileys v8 仍在 active development，API 與新 auth format 尚未定稿；新專案應使用官方推薦的 stable release，不預先採用 v8 edge API。模組邊界可降低日後 v8 migration 影響。

## 本機與 npm 狀態

- 本機 Node.js：`v23.11.0`；npm：`11.7.0`，符合 Baileys 的 Node.js `>=20.0.0` 要求。
- npm `@whiskeysockets/baileys` 目前 `latest` 回報 `7.0.0-rc14`，package 是 ESM；建立專案時會使用 `type: module` 並由 lockfile 固定實際 dependency graph。
- 相關 package 查核版本：`@hapi/boom` 10.0.1、`qrcode-terminal` 0.12.0、`pino` 10.3.1、`@cacheable/node-cache` 3.1.1。
- Baileys dist-tags：`latest` 是 `7.0.0-rc14`，`legacy` 是 `6.7.24`；官方 Installation 要求新專案採用 latest/stable 起點，因此鎖定 latest 並提交 `package-lock.json`。
- 最新 Vitest 4 不支援目前的 Node.js 23，因此測試採用 Node.js 內建 `node:test` 配合 `tsx --test`，避免引入不兼容的 test runner。
- 開發工具查核版本：TypeScript 7.0.2、tsx 4.23.12、`@types/node` 26.2.0、`@types/qrcode-terminal` 0.12.2。
- npm 將 `@img/sharp-wasm32` 與其 `@emnapi/runtime` 顯示為 top-level `extraneous`，但 `package-lock.json` 與 `sharp/package.json` 顯示兩者屬 sharp 的 optional platform dependency graph；`npm prune` 不會移除，並非本專案手動加入的 dependency。
- Raw QR 改良後已移除 `qrcode-terminal` 及 `@types/qrcode-terminal`；目前 audit 90 packages，0 vulnerabilities。

## Raw QR live 驗證

- Baileys v7 live payload 是單行 `https://wa.me/settings/linked_devices#...` 字串，可以直接交給 QR generator。
- 暫存檔 `.data/latest-whatsapp-qr.txt` 已確認非空、mode `0600`，並由 `.gitignore` 的 `.data/` 規則排除；最終格式不含 trailing newline，可逐字複製到 QR generator。
- 不把實際 payload 寫進 documentation／planning files，避免保存短期 pairing secret；process 會持續覆寫專用暫存檔。
- Live lifecycle 先收到 `515` restart-required，重連後出現 `WhatsApp 已連線，自動回覆已啟動`，表示 QR 掃描及 session credentials 保存已成功。
- Node.js `process.umask(0o077)` 可確保往後新建 files／directories 不授權 group／other；`fsPromises.chmod` 用於收緊既有 auth state。
- 檢查既有 session 發現 auth directory 為 `0755`、826 個 files 為 `0644`；已新增啟動時 permission hardening，並以 `lstat` 避免跟隨 auth directory 內的 symlink。
- Hardening 後 live read-back：auth directory 為 `0700`、826 個 files 全部為 `0600`；raw QR 暫存檔在連線成功後不存在，符合 lifecycle cleanup 設計。

## OpenRouter 第二階段

- 官方 preset 文件確認可在標準 `POST https://openrouter.ai/api/v1/chat/completions` request 中直接使用 `model: "@preset/whatsapp-auto-reply"`。
- 必要 headers 是 `Authorization: Bearer <OPENROUTER_API_KEY>` 與 `Content-Type: application/json`；`HTTP-Referer` 及 `X-OpenRouter-Title` 是 optional attribution headers。
- 非 streaming 成功回應遵循 OpenAI-compatible schema：`choices[0].message.content` 是主要 assistant text，response 同時可能提供 model 與 usage。
- 官方列出的 HTTP errors 包括 400、401、402、403、404、408、413、422、429、500、502、503。
- Provider 亦可能在 choice 中回傳 `finish_reason: "error"` 與 embedded `error`，即使已有 partial content；第一版會視為失敗，不把 partial output 傳到 WhatsApp。
- Preset 的價值是把 model、provider routing、system prompt 與 generation parameters 留在 OpenRouter 管理，application 只傳 preset ID 與 user message。
- 本機目前沒有 `OPENROUTER_API_KEY` shell variable，亦沒有 `.env`；live probe 需在實作完成後由使用者提供 key。
- Dotenv 官方 ESM 用法可在 application startup 載入 `.env`；`quiet: true` 避免額外 console noise，`override: false` 保留 deployment environment 的優先權。
- npm 最新 dotenv 是 17.4.2，支援 Node.js >=12，與本專案 Node.js >=20 相容。
- 既有 `MessageHandler`／`MessageRouter` seam 可直接容納 AI handler；OpenRouter client 會以 application port 注入，不需更改 WhatsApp consumer。
- 新 application 在沒有 key 時會以明確的 `缺少必要設定：OPENROUTER_API_KEY` 立即退出，不會連接 WhatsApp 或默默退回舊 repeat 行為。
- 使用者已在 gitignored `.env` 設定 key；檔案 read-back 為 mode `0600`，preset ID 符合 `@preset/whatsapp-auto-reply`，未輸出 secret。
- 固定無敏感 prompt 的最小 live probe 成功，preset 回傳 3 個字元的非空 completion，證明 authentication、preset routing 與 response parsing 正常。

## Quoted reply bug

- Production process 仍在運行且持續成功完成 OpenRouter requests；診斷期間沒有停止服務。
- Repository 沒有額外 `CONTEXT.md` 或 ADR 可供查核。
- 現有 parser 只輸出目前訊息 text，application input 亦只有 `userMessage`；quoted reply context 尚無任何 domain field 或 transport mapping。
- 正確 feedback seam 是 `parseIncomingTextMessage` fixture：建立帶 `extendedTextMessage.contextInfo.quotedMessage` 的真實形狀，斷言 parser 必須輸出 quoted text；此 test 可 deterministic 重現使用者描述的缺失。
- Targeted command `npx tsx --test test/infrastructure/whatsapp/messages/parse-incoming-text-message.test.ts` 已連續兩次得到相同 5 pass／1 fail；唯一 diff 是 expected `quotedText` 在 actual 缺失，符合 red-capable、deterministic、fast、agent-runnable 條件。
- 最小 fixture 只保留 current extended text、`contextInfo.quotedMessage.conversation` 與必要 message key；移除 quotedMessage 後便不再屬於此 bug，因此 remaining elements 均為 load-bearing。
- Baileys contract 確認 `IContextInfo.quotedMessage` 是完整 `proto.IMessage`；`normalizeMessageContent` 是 public export，可移除 ephemeral／view-once／edited 等 wrapper 後再解析文字或 caption。
- Hypotheses #1–#3 已由 source inspection 證實：parser 不讀 quote、domain 無 quoted field、OpenRouter port 只收單一 string。Hypothesis #4 以官方 `normalizeMessageContent` 處理 wrapper，不自行重建 Baileys normalization。

## Conversation history limitation

- 已確認目前 OpenRouter request 永遠只有一個 current `user` message；project 沒有 per-chat role history 或 conversation memory。
- `InMemoryMessageContentStore` 只為 Baileys `getMessage` retry 保存 raw content，沒有傳入 handler／OpenRouter，不能當作 AI memory。
- Socket 明確設定 `syncFullHistory: false`；即使開啟 history sync，也仍需 application 自行建立 store、role mapping、window／token policy，AI 才會看到歷史。
- 因此「AI 不知道再上面多條訊息」是現有 application feature gap，不是 quoted reply bug，亦不是 Baileys 強制只提供上一條訊息。
- Baileys 提供 `messaging-history.set`／HistorySync 等 primitives，但 application 必須自行保存及映射 `WAMessage`；existing linked session 不保證每次 restart 都重新交付完整歷史。
- 為避免未經界定地同步及保存整個 personal WhatsApp 歷史，今次採用有上限的 in-memory per-chat history；重啟前未保存的舊訊息不納入。
- Production logs 顯示同一 chat 可有多個 OpenRouter completion 同時進行，因此 history store 之外亦需要 keyed serial queue，否則 rapid messages 會看到相同 snapshot。
- 實作後真實 preset probe 已確認兩條 paths：multi-turn `messages[]` 能取回較早 turn 的固定 codeword；formatted quoted context 能取回被引用內容的另一固定 codeword。
- Conversation turn 在 WhatsApp send 成功前不會加入 store；同一 message ID 去重，queue failure 不會阻塞後續 task。
- Production 啟動工具被中斷後，read-only process audit 確認只有一個 `tsx src/index.ts` parent／worker pair；worker 有一條 port 443 established connection，沒有啟動第二個 WhatsApp instance。

## 新增需求

- 專案需要可長期擴充，不能只做單檔 demo。
- 架構需採用 Baileys 官方目前推薦做法。
- 使用者提供的截圖顯示 Codex terminal panel 寬度不足，ASCII QR 被換行／裁切，不能可靠掃描。
- 使用者要求取得 raw QR payload，自行使用其他工具生成 QR code。
- 最實用的交付方式是 terminal raw block 加上 `.data/latest-whatsapp-qr.txt`；檔案每次收到新 QR 便覆寫，讓使用者總能取得最新 payload。
