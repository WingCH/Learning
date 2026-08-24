# WhatsApp 自動回覆 Bot 建置計劃

## 目標

在目前目錄建立一個可長期擴充的 Baileys Node.js／TypeScript bot，可透過 QR code 連接個人 WhatsApp；收到一般文字訊息後呼叫 OpenRouter `@preset/whatsapp-auto-reply`，再把 assistant response 作為普通 WhatsApp 訊息送出。

## 階段

- [x] 階段 1：確認工作目錄、既有檔案與 Git 狀態
- [x] 階段 2：查核 Baileys 官方文件與目前 API
- [x] 階段 3：建立專案、實作連線與自動回覆
- [x] 階段 4：安裝依賴並執行非互動式驗證
- [x] 階段 5：整理操作說明、限制與交付結果
- [x] 階段 6：改用 raw QR payload 輸出及安全暫存檔
- [x] 階段 7：補充測試、文件並重新驗證
- [x] 階段 8：重新啟動並交付最新 raw QR 取得方式
- [x] 階段 9：查核 OpenRouter preset 與 Chat Completions contract
- [x] 階段 10：建立 OpenRouter client、handler 與安全設定
- [x] 階段 11：補充 tests／README 並執行非網絡驗證
- [x] 階段 12：使用真實 preset 做最小 live probe 並重啟 bot
- [x] 階段 13：建立 quoted reply 缺失的 deterministic regression test
- [x] 階段 14：查核 Baileys quotedMessage contract 並驗證原因
- [x] 階段 15：傳遞 quoted context 至 OpenRouter 並完成全部驗證
- [x] 階段 16：受控重啟 production process 並驗證連線
- [x] 階段 17：無停機 snapshot 現有 in-memory conversation records
- [x] 階段 18：設計 versioned file memory 與 AI compaction module
- [x] 階段 19：實作 persistence、migration、compaction 與 hard limits
- [x] 階段 20：完成 tests、真實 summary probe、recovery／security gates
- [x] 階段 21：一次受控 restart、確認 record migration 與 production read-back
- [x] 階段 22：建立 extensible slash-command registry 與 handlers
- [x] 階段 23：實作 `/help`、`/reset` 與 persistent clear tests
- [x] 階段 24：完成 gates 後一次受控 restart 並確認 memory record 保留
- [x] 階段 25：建立 missing read-receipt regression test
- [x] 階段 26：批次 mark 所有 inbound notify messages 為已讀
- [x] 階段 27：完成 gates、受控 restart 與真實藍剔驗證
- [x] 階段 28：建立可刷新及必定 cleanup 的 typing indicator module
- [x] 階段 29：驗證 presence success／failure／long-running refresh paths
- [x] 階段 30：受控 restart 並確認 production connection／memory
- [x] 階段 31：建立 configurable randomized minimum response delay
- [x] 階段 32：驗證 fast／slow API、bounds、commands 不延遲及 typing integration
- [x] 階段 33：受控 restart 並確認 production connection／memory

## 重要決策

- 使用 TypeScript，令事件 payload 與訊息內容處理具備型別檢查。
- 採用分層／模組化結構，分開 WhatsApp client lifecycle、訊息解析、訊息處理規則、設定及程式入口。
- 第一個回覆規則會實作為可替換的 handler，方便日後加入 command、AI、database、queue 或其他 transport。
- 使用 stable Baileys；v8 尚在開發中，不採用未定稿的 edge API。
- 遵循官方多數 application 的建議，以 `sock.ev.process` 批次處理事件。
- 測試使用 Node.js 內建 `node:test` 與 `tsx --test`，避免 test runner 對本機 Node.js 23 的版本不兼容。
- 認證狀態只存於本機並加入 `.gitignore`，不得提交 WhatsApp session credentials。
- 只處理別人傳入的文字訊息，避免回覆自己的訊息造成循環。
- 重複內容以普通文字訊息直接送出，不引用原訊息。
- 初次連線需要使用者本人在 WhatsApp 的「連結裝置」掃描 QR code。
- QR presentation 與 socket lifecycle 分離；terminal 只輸出 raw payload，並將最新 payload 寫入 gitignored、權限為 `0600` 的暫存檔。
- 成功連線、停止 process 或 terminal disconnect 時刪除暫存 QR，避免留下已過期的 pairing payload。
- 第二階段使用 OpenRouter Chat Completions endpoint，model 固定由設定傳入，預設為 `@preset/whatsapp-auto-reply`。
- 每個實時私人文字訊息以單一 `user` message 傳給 preset；將第一個有效 assistant text 作為普通 WhatsApp 訊息直接送出。
- OpenRouter transport 置於獨立 adapter，API key 只來自 environment／gitignored `.env`，不可出現在 log、error body、test fixture 或 commit。
- API timeout、非 2xx、embedded provider error、空 choices／空 content 均視為失敗；不向聯絡人發送內部錯誤內容。
- 啟動時透過 dotenv 載入 gitignored `.env`，使用 `quiet: true`、`override: false`；部署環境直接注入的 variable 優先。
- Production process 在診斷、實作與測試期間保持運行；所有 gates 通過後才做一次必要的受控重啟。
- WhatsApp quoted reply 必須把 `contextInfo.quotedMessage` 的文字連同目前訊息傳給 AI；沒有 quote 時維持原本單一 user content。
- 每個 chat 使用 bounded sliding user／assistant history；預設最多 20 turns、12,000 characters，並限制 active chats 數量。
- 同一 chat 的 AI request 與 WhatsApp send 必須 serialize，避免快速連續訊息同時讀到相同舊 history。
- History 只在 WhatsApp send 成功後 commit assistant turn；send failure 不可污染下一輪 context。
- 第一版不啟用 full history sync：既有 session 未保存的舊訊息不保證可由 Baileys 補回；今次建立的是重啟後新訊息的 bounded in-memory context。
- Conversation memory 改為 `.data/conversation-memory.json` versioned private file；directory `0700`、file `0600`、atomic temp-write + rename。
- `ConversationHistoryStore` 保持小 interface；persistence schema、migration、LRU、threshold、compaction、hard-limit fallback 隱藏在深層 module implementation。
- Compaction 預設在 20 turns 或 12,000 characters 觸發，AI 壓縮 previous summary + oldest turns，保留最新 8 turns；summary 上限 4,000 characters。
- Compaction failure 不得丟失剛保存的 turns：先 atomic persist 原始 turn，再嘗試壓縮；失敗留待下一輪重試，hard cap 防止無限制增長。
- 所有 gates 通過前保持 production 運行；restart 只做一次，且 cutover 前必須先保存現有 process 內 records。
- Slash commands 由 command registry 在 AI handler 前處理；未知 command 不可送往 OpenRouter。
- `/help` 必須由 registry metadata 自動產生，新增 command 不需修改 help 文案。
- `/reset` 只清除目前 chat，並在確認訊息成功送出後才 atomic persist；其他 chats、auth 及 API key 不受影響。
- 每個 `notify` batch 的所有非自己發出、具有有效 key 的 messages 都要呼叫 `readMessages(keys)`，包括不觸發 AI 的 media／group messages。
- Read receipt failure 只記 warning，不可阻塞 command、OpenRouter 或 WhatsApp response。
- 可處理訊息進入 per-chat queue 後送 `composing`，operation 完成或失敗時在 `finally` 送 `paused`。
- Baileys presence 約 10 秒過期，因此長於 8 秒的 operation 需刷新 `composing`；所有 presence sends 必須 serialize，確保 `paused` 最後送出。
- Presence failure 只記 warning，不可阻塞 command、OpenRouter、sendMessage 或 memory commit。
- AI response 每次抽取均勻隨機 minimum delay，預設 2,000–5,000ms；計時從 AI handler 開始，API 較慢時不額外延遲。
- Random delay 只套用 AI handler；slash commands 保持即時。Delay 等候期間 typing indicator 繼續運作。

## 錯誤紀錄

| 錯誤 | 嘗試 | 處理方式 |
|---|---:|---|
| `AGENTS.md` 指定的 skill 路徑不存在 | 1 | 改用可用的 `/Users/wingchan/.codex/skills/planning-with-files/SKILL.md` |
| `isJidGroup` 回傳 `boolean \| undefined`，不符合 application model 的 `boolean` | 1 | 已以 `=== true` 將 adapter 結果明確正規化為 boolean |
| 初次 `npm test` 只執行 3 個 config tests，沒有涵蓋 nested test directory | 1 | npm 使用的 shell 沒有遞迴展開 `**`；已改用 Node test runner 自動 discovery |
| `npm ls --depth=0` 將 sharp 的 WebAssembly optional platform packages 顯示為 `extraneous` | 1 | `npm prune` 後仍存在；lockfile 顯示它們由 sharp optional dependency graph 安裝，audit／typecheck／build 不受影響，保留 package manager 管理的內容 |
| 新增 parser test helper 時把 optional `WAMessage["message"]` 直接指定給 exact optional property | 1 | helper 輸入改為確定存在的 `proto.IMessage`，保留 strict typing |
| Live smoke test 發現 Baileys internal logger 繼承 application `info` level，輸出低層 handshake payload | 1 | 停止未登入的 process；依官方 production 範例改用獨立 `silent` Pino logger，只保留 application lifecycle log |
| Codex terminal panel 會裁切／換行大型 ASCII QR，使用者無法可靠掃描 | 1 | 停止舊 process；改為 raw payload + 最新 QR 暫存檔，不再 render ASCII QR |
| Raw QR 暫存檔最初包含 trailing newline，直接 `pbcopy` 可能令部分 generator 編碼額外字元 | 1 | 檔案改為只保存 payload bytes；換行只存在 terminal presentation |
| Live session auth directory／files 使用預設 `0755`／`0644`，同機其他 account 可讀 | 1 | File auth provider 設定 umask `0077`，並將既有 directories／files 收緊為 `0700`／`0600`，略過 symlink |
| OpenRouter request test 用 callback 寫入 nullable variable，TypeScript 無法跨 async callback 收窄 | 1 | 改用 typed capture array 並以 `assert.ok` 收窄第一項 |
| Quoted reply regression test 連續兩次失敗，actual 缺少 `quotedText` | 1 | 預期中的 red phase；證明 parser → domain seam deterministic 重現使用者症狀 |
| 一個 `apply_patch` 同時 delete／add 同一 test file 被拒絕 | 1 | 分成兩個 patch：先刪除，再以更新後內容新增；沒有重試相同無效 patch |
| Queue test 的 resolver 只在 Promise executor 賦值，TypeScript 把 guarded callback 收窄為 `never` | 1 | 使用 definite assignment，resolver 在 synchronous executor 內必定初始化；runtime test 已證明路徑正常 |
| Inspector 以 class prototype query 找不到 tsx-loaded store instance | 1 | 改查 heap `Map` instances，按 ConversationTurn shape 定位唯一 active map |
| 首次 Map probe 因個別 heap object getter／iteration 拋錯 | 1 | 對每個 candidate 獨立 try/catch，只回傳符合 shape 的 count／size |
| Inspector callback dynamic import `node:fs` 不受支援 | 1 | Inspector 只 return payload 到本機 migration process，由 migration process atomic 寫 private file |
| 並行讀取 skills + production status 的 orchestration script 語法錯誤 | 1 | 沒有執行任何 nested command；拆成獨立 read-only calls 後成功 |
| Read-receipt regression 連續兩次得到 actual `[]` | 1 | 預期中的 red phase；證明 notify consumer 完全沒有送出 read receipt batch |

## 範圍注意事項

- 目前目錄沒有既有專案檔案。
- 上層 Git repository 有其他目錄的未提交變更；本任務不會修改或還原那些變更。
- 不代替使用者執行 QR code 掃描或操作其手機。
- 本機 code、type、tests 及 build 均可由 agent 驗證；個人 WhatsApp 登入及真實訊息 round-trip 必須由使用者掃描 QR 並從另一帳號傳訊後才能確認。
- 不在 debug output 或 planning files 保存 message content、JID、API key 或 auth payload。

## 完成狀態

- 專案建置、依賴安裝、架構、文件、typecheck、16 個單元測試及 production build 已完成。
- Live process 已確認能連接 WhatsApp Web endpoint、產生 QR、QR 過期後重連，且 Baileys internal logger 已安全靜音。
- 舊 process 已停止，正在改良 QR delivery；真實帳號連結及 `hi` → `hi hi` round-trip 仍屬使用者互動驗證。
- 修正後 process 已用既有 credentials 成功重啟並保持連線；沒有再要求 QR。真實訊息 round-trip 仍待使用者由另一帳號傳訊驗證。
- 第二階段 code、27 個 tests、build、真實 OpenRouter preset probe 及 WhatsApp bot 重啟均已完成；bot 現正保持連線，等待真實 inbound message round-trip。
- Quoted reply 與 bounded multi-turn context fix 已部署；production 只有一個 process，worker 已建立 WhatsApp port 443 connection。等待使用者做真實 quoted／multi-turn round-trip。
- Current RAM history 已無停機 snapshot 至 private legacy file；cutover 前會再捕捉一次增量後的完整 Map，再 migrate 至 versioned persistent store。
- Persistent compressed memory 已部署；final snapshot 2 chats／12 turns 全數 migration，V1 file read-back 保留相同 records，production 已重新連線。
- Slash command framework 已部署；受控 restart 前後 memory 均為 2 chats／14 turns／0 summaries，production 已重新連線。
- Read-receipt fix 已部署並重新連線；memory 仍為 2 chats／14 turns／0 summaries。程式已送 receipts，等待外部帳號確認藍剔 visibility。
- Typing indicator 已部署；restart 前後 memory 均為 2 chats／15 turns／0 summaries，production 已重新連線，等待使用者視覺確認「正在輸入…」。
- Randomized 2–5 秒 minimum AI response delay 已部署；restart 前後 memory 均為 2 chats／15 turns／0 summaries，production 已重新連線。

## Commit 紀錄

- `35e554aa feat(main): 建立可擴充的 WhatsApp 自動訊息 Bot`
- `0cb025a5 feat(main): 接入 OpenRouter 並支援多輪對話`
