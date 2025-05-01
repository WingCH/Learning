# iOS 本地網路權限示例

這個簡化的專案專門演示如何觸發 iOS 中的本地網路權限彈窗。自 iOS 14 開始，Apple 對應用程式存取本地區域網路引入了隱私權限控制。本應用展示了最簡單的方法來觸發此權限請求。

## 功能概述

此示例應用只包含一個功能 - 使用 URLSession 向本地 IP 發送 HTTP 請求，這會觸發本地網路權限請求彈窗。

## 權限配置

為了讓應用正確請求本地網路權限，本專案在 Info.plist 中添加了以下設定：

- `NSLocalNetworkUsageDescription`：解釋應用為何需要存取本地網路的說明文字

## 如何使用

1. 在真實設備上運行應用
2. 點擊「發送本地請求」按鈕
3. 觀察系統彈出本地網路權限請求對話框
4. 查看回應結果（通常在本地網路中沒有真實服務時會返回錯誤）

## 參考資料

- [Apple 文檔：Preparing for Local Network Privacy Restrictions](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocalnetworkusagedescription)
- [Getting ready for iOS 14 local network privacy restrictions](https://nilcoalescing.com/blog/GettingReadyForNewiOS14LocalNetworkPrivacyRestrictions) 