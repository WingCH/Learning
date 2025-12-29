這份是你最終確認的 **「Flutter 橫向錦標賽對陣圖」** 需求總結。你可以用這份規格直接開始開發：

### 🎯 核心目標

建立一個 **橫向滾動、固定卡片尺寸、自動垂直置中排版** 的錦標賽晉級圖 (Tournament Bracket)。

---

### 1. 交互體驗 (Interaction)

* **操作方向**：**僅限左右滑動 (Horizontal Scrolling)**。
* 鎖定 Y 軸（不需要上下拖曳）。
* 鎖定縮放（不需要 Zoom In/Out）。


* **手感**：類似長畫卷或 `PageView`，用戶向右滑動查看下一輪比賽，滑走舊的，顯示新的。

### 2. 排版規則 (Layout Logic)

* **生長方向**：由左至右 (Left-to-Right)，層級分明 (例如：16強 → 8強 → 4強 → 決賽)。
* **卡片規格**：所有比賽卡片 (Nodes) 的 **寬度 (Width)** 和 **高度 (Height)** 均為 **固定數值**。
* **動態置中**：
* 每一輪之間有固定的水平間距。
* **關鍵邏輯**：下一輪卡片的 Y 軸位置，必須精準計算並放置在 **上一輪兩場來源比賽的垂直中心點**。



### 3. 視覺呈現 (Visuals)

* **連線樣式**：使用 **S 型貝茲曲線 (Bezier Curves)**。
* 線條需平滑連接「上一輪卡片的右側中點」與「下一輪卡片的左側中點」。


* **渲染方式**：接受 **一次性渲染 (Render All)**。
* 使用 `SingleChildScrollView` 載入整個樹狀結構，以確保連線邏輯完整且不斷裂。



### 4. 建議技術棧 (Tech Stack)

* **外層容器**：`SingleChildScrollView` (設定 `scrollDirection: Axis.horizontal`)。
* **佈局核心**：`CustomMultiChildLayout` (用於精確計算並擺放固定大小的卡片)。
* **繪圖核心**：`CustomPaint` (置於底層，負責繪製所有 S 型連線)。

---

這份總結是否準確無誤？如果沒問題，就可以按照這個規格去寫 `CustomMultiChildLayoutDelegate` 的數學邏輯了。