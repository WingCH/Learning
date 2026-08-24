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

## Persistent compressed memory

- 目前 bounds 是每 chat 20 turns（約 40 user／assistant messages）與 12,000 characters 先到先截，最多 100 chats；理論上約 4,000 messages／120 萬 characters，純字串約數 MB，加 object overhead 仍屬可控。
- Baileys retry store 另有 1,000 raw message entries，與 AI conversation memory 分開，沒有保存下載後 media buffers。
- 使用者要求 restart 保留 records，因此 OS temp directory 不合適；選用 project-private gitignored `.data/conversation-memory.json`，因為 `/tmp` 可被系統清理且共享風險較高。
- Current production worker 仍運行舊的 in-memory adapter；records 只存在該 process heap。需在 restart 前以不回傳內容的本機 inspector migration snapshot 保存。
- 深層 module interface 維持 `getContext`／`appendTurn` 類型的少量操作；OpenRouter summarizer 是 true-external internal seam，以 mock adapter 測試、production adapter 呼叫現有 Chat Completions client。
- Inspector migration 最終以 heap Map shape 定位 active store，首次成功 snapshot 捕捉 2 chats／6 turns／2,048 bytes；file mode `0600`、schema valid，Inspector 已關閉。
- Production 在 snapshot 全程保持運行；final cutover 前需重新執行 snapshot，避免漏掉這段期間新增的 turns。
- Node.js file persistence 採 same-directory temp file → `FileHandle.sync()` → close → `rename()` → chmod 的 atomic replacement pattern；`writeFile` 本身不是 atomic。
- V1 schema 保存 ordered chats：`chatJid`、optional summary、recent turns；array order同時代表 LRU，restart 可恢復 eviction order。
- Compaction 先 persist 未壓縮的新 turn，再呼叫 summarizer；成功後 persist summary + recent turns。Summary failure 保留原資料並於後續 turn 重試，只有超過 40 turns／24,000 characters hard cap 才移除最舊 turns。
- `ConversationHistoryStore` 兩方法 interface 保持不變；file adapter 取代 production in-memory adapter。`ConversationSummarizer` 是 internal true-external seam，OpenRouter adapter 與 test fake 形成兩個 adapters。
- Summary 在 completion context 中以 `system` role 明確標示為 earlier context；recent user／assistant turns 隨後串接，最後才是 current message。
- 真實 summary probe 成功：3 turns 觸發壓縮，V1 file 只留 1 recent turn，context 是 summary + 1 user／assistant pair；reopen context 完全相同、file mode `0600`。
- 全套 gates：45/45 tests、typecheck、build、diff whitespace、secret scan、debug-marker scan 全部通過。
- Final cutover snapshot 捕捉 2 chats／12 turns／3,945 bytes；新 process log 回讀並 migration 相同 2 chats／12 turns，證實 restart preservation。
- Production V1 read-back：mode `0600`、schema valid、2 chats、12 recent turns、0 summaries（尚未達 threshold）；legacy／temp files 已移除，inspector 已關閉。

## Slash commands

- Baileys command text 經既有 conversation／extendedText parser 會保留 `/` prefix，可在 `MessageRouter` 的 AI handler 前加入 command handler。
- Command registry 是 application-level 深層 module：負責 parse、case normalization、duplicate validation、unknown-command response 及 dynamic help；個別 command adapter 只實作 description 與 execute。
- `/reset` 採 send-success callback：確認訊息成功傳送後才呼叫 `ConversationHistoryStore.clear(chatJid)`，避免 send failure 時使用者以為已清除。
- Registry tests 證明普通文字會落入下一個 handler、`/help` 動態列出 commands、名稱大小寫不敏感、未知 slash command 不會到 AI、重複名稱會在 startup 被拒絕。
- Reset tests 證明 onSent 前 records 仍存在、onSent 後只清目前 chat，file adapter reopen 後仍維持清除，file mode 保持 `0600`。
- Command deployment restart read-back 前後完全一致：V1、2 chats、14 turns、0 summaries、mode `0600`；production 單一 parent／worker 已連線。

## Read receipt bug

- 官方 Baileys contract 要求以 `sock.readMessages([WAMessageKey, ...])` 明確標記已讀；現有 consumer 完全沒有呼叫此方法，因此藍剔缺失可由 source 直接解釋。
- Read receipt privacy 可設定 `all`／`none`；程式送 receipt 之外，personal WhatsApp account 的已讀標記 privacy 必須容許對方看到。
- 使用者要求所有新 inbound messages 都標記已讀，不限於觸發 AI 的 text；正確 seam 是 `messages.upsert` notify batch，在 parser／group filter 前收集 keys。
- Targeted consumer test 連續兩次 deterministic 失敗：expected text／image／group inbound keys，actual read batches 為空；自己發出的 key 正確不應包含。
- Read receipt 應在 event-level 一次 batch call；不能放在 per-message AI queue，否則 media／disabled group filters 會漏標。
- Fix 後 targeted tests 證明 notify batch 會包含 text／image／group inbound keys、排除 own message；append event 不送 receipt，receipt error 不阻塞 send／onSent。
- Read-receipt deployment restart 前後 V1 memory 均為 2 chats／14 turns／0 summaries、mode `0600`；production 單一 instance 已重新連線。
- 是否顯示藍剔仍受 WhatsApp account 的 Read Receipts privacy 控制；不自動修改全帳號 privacy setting。

## Typing indicator

- Baileys 使用 `sendPresenceUpdate("composing", jid)` 顯示正在輸入，並以 `paused` 清除；presence 約 10 秒過期。
- OpenRouter request timeout 可達 30 秒，單次 composing 不足；採 8 秒 refresh interval。
- Presence sends 需以 promise tail serialize，否則 interval 中正在執行的 composing 可能在 finally paused 之後完成，令 UI 卡在 typing。
- Typing indicator 只包住已通過 parser／group filter 的 per-chat operation；不處理的 media 不顯示 typing，但仍會按上一階段送 read receipt。
- 實作使用 serialized promise tail：initial composing、8 秒 refresh、operation、finally paused；即使 refresh in-flight，paused 仍保證最後執行。
- Tests 覆蓋 success order、operation throw cleanup、presence transport failure 及長操作至少一次 refresh。
- Typing deployment restart 前後 V1 memory 均為 2 chats／15 turns／0 summaries、mode `0600`；production 單一 instance 已連線。

## Randomized response delay

- 使用者要求 API 快速回傳時仍至少等待人性化隨機時間；選用可設定的均勻 2–5 秒 default range。
- Deadline 必須在 AI request 前建立，completion 後只等待 remaining duration；若 API latency 已超過 deadline，remaining 為 0，不再增加延遲。
- Delay policy 使用 `begin() → wait()` 小 interface，clock／random／sleep 隱藏於 production adapter並可注入 deterministic tests；commands 不經此 seam。
- Node `timers/promises.setTimeout` 可 await remaining milliseconds；只在 remaining > 0 時呼叫，避免不必要 zero-delay scheduling。
- Deterministic tests 覆蓋 random range 兩端、fast API remaining wait、slow API zero extra wait、invalid bounds／random source，以及 AI handler begin → API → wait ordering。
- Delay deployment restart 前後 V1 memory 均為 2 chats／15 turns／0 summaries、mode `0600`；production 單一 instance 已連線。

## 新增需求

- 專案需要可長期擴充，不能只做單檔 demo。
- 架構需採用 Baileys 官方目前推薦做法。
- 使用者提供的截圖顯示 Codex terminal panel 寬度不足，ASCII QR 被換行／裁切，不能可靠掃描。
- 使用者要求取得 raw QR payload，自行使用其他工具生成 QR code。
- 最實用的交付方式是 terminal raw block 加上 `.data/latest-whatsapp-qr.txt`；檔案每次收到新 QR 便覆寫，讓使用者總能取得最新 payload。
