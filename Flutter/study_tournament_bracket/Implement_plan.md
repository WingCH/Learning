沒問題，我已經將剛才討論關於 **`CustomMultiChildLayout` 的核心優勢（精準坐標控制、父子組件連動、動態 Size 計算）** 融入到這份錦標賽對陣圖的需求規格中。

這份更新後的規格書，明確了我們不是做一個普通的 PageView，而是一個 **基於坐標系計算 (Coordinate-based)** 的連貫滾動視圖。

---

# 📱 Flutter 橫向錦標賽對陣圖 - 最終技術規格 (v2.0)

### 🎯 核心目標

建立一個 **橫向滾動 (Horizontal Scroll)、高度連貫 (Continuous)** 的錦標賽晉級圖。利用 `CustomMultiChildLayout` 的坐標系統，實現卡片之間的自動置中與線條連接，確保視覺上無縫過渡。

---

### 1. 交互體驗 (Interaction & Continuity)

* **操作模式**：**單一畫卷式滾動 (Single Continuous Scroll)**。
* 用戶體驗類似查看一張超長的橫向地圖，而不是一頁頁翻頁。
* 拒絕分頁感 (No Pagination snapping)，保持流暢的滑動慣性。


* **軸向鎖定**：
* **X 軸**：自由滾動 (Scrollable)。
* **Y 軸**：內容自動垂直置中，用戶**無需**上下拖曳 (除非內容超出屏幕高度，則容器自動撐大)。
* **縮放**：鎖定 (No Zoom)。



### 2. 排版邏輯與數學 (Layout & Math Logic)

* **卡片規格 (Node Specs)**：
* **固定尺寸**：所有比賽卡片 (Match Card) 擁有固定的 `Width` 和 `Height`（簡化計算）。


* **坐標計算系統 (The Delegate Logic)**：
* **X 軸規則 (層級)**：
* 第 1 輪 (Round 1) 在最左邊 (x=0)。
* 第 2 輪 X = `(CardWidth + HorizontalGap) * 1`，以此類推。


* **Y 軸規則 (動態置中)**：
* **第一輪**：依序由上而下排列，間距固定。
* **後續輪次 (晉級者)**：必須使用 **「來源依賴算法」**。
* *公式*：下一輪卡片 Y 中心點 = `(來源卡片A.y + 來源卡片B.y) / 2`。




* **容器動態大小 (Dynamic Container Size)**：
* `CustomMultiChildLayout` 必須在 `performLayout` 結束時，計算出整個對陣圖的總寬度與總高度，並通過 `layout(totalWidth, totalHeight)` 撐開外層的 `SingleChildScrollView`。



### 3. 視覺與連線 (Visuals & Painting)

* **S 型貝茲曲線 (Bezier Curves)**：
* 利用 `CustomMultiChildLayout` 計算出的精準 `Offset` (坐標)，繪製連接線。
* **起點**：上一輪卡片的 `RightCenter`。
* **終點**：下一輪卡片的 `LeftCenter`。


* **渲染策略**：
* **Layout 與 Paint 分離**：`CustomMultiChildLayout` 負責定位置，`CustomPaint` (位於背景) 負責畫線。兩者共享同一套坐標數據 (Data Model)。



### 4. 推薦技術棧 (Tech Stack)

* **外層容器**：`SingleChildScrollView` (ScrollDirection: Horizontal)。
* **佈局核心**：**`CustomMultiChildLayout`**
* **原因**：我們需要「獲取 A 和 B 的位置來決定 C 的位置」，這是 `Column`/`Row` 做不到，但 `CustomMultiChildLayoutDelegate` 最擅長的事。
* **職責**：遍歷數據樹，計算每個 `LayoutId` (卡片) 的 `Offset`，並決定 Canvas 的最終 Size。


* **繪圖核心**：`CustomPaint`
* **職責**：讀取卡片位置數據，繪製貝茲曲線。



---

### 💡 為什麼這個版本更好？

這個版本修正了之前可能存在的誤區：我們不需要像 PageView 那樣處理 "每一頁的高度變化"，因為錦標賽圖通常是 **"整體呈現"** 的。

`CustomMultiChildLayout` 在這裡的變現方式是：

1. 它先算出第一輪 (最左邊) 佔據了多少高度 (例如 8 場比賽 = 1000px)。
2. 它算出第二輪、第三輪的位置。
3. 它最後告訴 `SingleChildScrollView`：「我總共有 1000px 高，2000px 寬」，Scroll View 就會自動適配，不需要我們手動去寫動畫縮放。
