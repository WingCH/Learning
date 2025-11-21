# iOS 影片播放黑畫面問題分析報告

## 問題描述
在 iOS 裝置上播放特定 MP4 影片 (`ios_cannot_display_video.mp4`) 時，出現有聲音但畫面空白（黑畫面/白畫面）的情況。該影片在 Android 上播放正常。

## 原因分析
經由 `ffprobe` 分析影片 metadata，發現問題影片的編碼規格為：
*   **Codec**: H.264
*   **Profile**: Baseline
*   **Level**: 4.2
*   **Resolution**: 1920x1080

**根本原因 (Root Cause)**：
iOS 的硬體解碼器對於 H.264 的支援有嚴格規範。**Baseline Profile** 通常設計用於低運算能力或低頻寬場景（如視訊會議），一般對應較低的 Level。將 Baseline Profile 用於高解析度 (1080p) 且高 Level (4.2) 是一種非常規的編碼組合，導致 iOS `AVPlayer` 無法正確解碼影像軌道，但音訊軌道 (AAC) 仍能正常播放。

## 解決方案
將影片重新轉檔為 iOS 支援度最佳的標準規格：**H.264 High Profile @ Level 4.0**。

### 執行步驟
使用 `ffmpeg` 工具執行以下轉檔指令：

```bash
ffmpeg -i assets/ios_cannot_display_video.mp4 \
  -c:v libx264 \
  -profile:v high \
  -level:v 4.0 \
  -pix_fmt yuv420p \
  -c:a copy \
  assets/ios_fixed_video.mp4
```

### 參數說明
*   `-c:v libx264`: 指定使用 H.264 編碼器。
*   `-profile:v high`: 設定 Profile 為 **High** (1080p 影片的標準 Profile)。
*   `-level:v 4.0`: 設定 Level 為 **4.0** (廣泛支援 1080p 播放)。
*   `-pix_fmt yuv420p`: 確保像素格式為 YUV420p (iOS 相容性最佳)。
*   `-c:a copy`: 音訊部分直接複製，不重新編碼。

## 驗證結果
轉檔後的影片 (`ios_fixed_video.mp4`) 在 iOS 模擬器/實機上均能正常播放影像與聲音，問題解決。
