# WhatsApp 自動回覆 Bot 建置計劃

## 目標

在目前目錄建立一個可長期擴充的 Baileys Node.js／TypeScript bot，可透過 QR code 連接個人 WhatsApp，收到一般文字訊息後回覆兩次相同內容，例如 `hi` 回覆 `hi hi`。

## 階段

- [x] 階段 1：確認工作目錄、既有檔案與 Git 狀態
- [x] 階段 2：查核 Baileys 官方文件與目前 API
- [x] 階段 3：建立專案、實作連線與自動回覆
- [x] 階段 4：安裝依賴並執行非互動式驗證
- [x] 階段 5：整理操作說明、限制與交付結果
- [x] 階段 6：改用 raw QR payload 輸出及安全暫存檔
- [x] 階段 7：補充測試、文件並重新驗證
- [x] 階段 8：重新啟動並交付最新 raw QR 取得方式

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

## 範圍注意事項

- 目前目錄沒有既有專案檔案。
- 上層 Git repository 有其他目錄的未提交變更；本任務不會修改或還原那些變更。
- 不代替使用者執行 QR code 掃描或操作其手機。
- 本機 code、type、tests 及 build 均可由 agent 驗證；個人 WhatsApp 登入及真實訊息 round-trip 必須由使用者掃描 QR 並從另一帳號傳訊後才能確認。

## 完成狀態

- 專案建置、依賴安裝、架構、文件、typecheck、16 個單元測試及 production build 已完成。
- Live process 已確認能連接 WhatsApp Web endpoint、產生 QR、QR 過期後重連，且 Baileys internal logger 已安全靜音。
- 舊 process 已停止，正在改良 QR delivery；真實帳號連結及 `hi` → `hi hi` round-trip 仍屬使用者互動驗證。
- 修正後 process 已用既有 credentials 成功重啟並保持連線；沒有再要求 QR。真實訊息 round-trip 仍待使用者由另一帳號傳訊驗證。
