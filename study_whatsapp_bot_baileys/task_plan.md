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

## Commit 紀錄

- `35e554aa feat(main): 建立可擴充的 WhatsApp 自動訊息 Bot`
