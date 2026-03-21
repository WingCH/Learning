//
//  VideoPreloader.swift
//  study_pip_lifecycle
//
//  Created by Wing CHAN on 1/8/26.
//

import AVKit

/// 視頻預驗證器
/// 用於在切換視頻前先驗證 URL 是否可播放，避免無效 URL 導致 PiP 中斷
final class VideoPreloader: NSObject {
    
    // MARK: - Properties
    
    private let logger = PiPLogger.shared
    
    /// 預驗證播放器
    private var preloadPlayer: AVPlayer?
    
    /// 當前正在預驗證的 player item
    private weak var preloadObservedItem: AVPlayerItem?
    
    /// 預驗證成功後的回調
    private var successHandler: ((AVPlayerItem) -> Void)?
    
    /// 預驗證失敗後的回調
    private var failureHandler: (() -> Void)?
    
    /// KVO context - preload status
    private static var preloadStatusContext = 0
    
    // MARK: - Public Methods
    
    /// 預驗證 URL 是否可播放
    /// - Parameters:
    ///   - url: 要驗證的 URL
    ///   - onSuccess: 驗證成功的回調，傳回一個新的 AVPlayerItem
    ///   - onFailure: 驗證失敗的回調（可選）
    func preloadAndValidate(url: URL, onSuccess: @escaping (AVPlayerItem) -> Void, onFailure: (() -> Void)?) {
        logger.log(.player, "[Preload] Starting preload for: \(url.absoluteString)")
        
        // 清除之前的預驗證
        cancel()
        
        // 保存回調
        successHandler = onSuccess
        failureHandler = onFailure
        
        // 創建預驗證 player（如果還沒有）
        if preloadPlayer == nil {
            preloadPlayer = AVPlayer()
            logger.log(.player, "[Preload] Created preload player")
        }
        
        // 創建 player item 並開始預驗證
        let playerItem = AVPlayerItem(url: url)
        preloadPlayer?.replaceCurrentItem(with: playerItem)
        
        // 添加 KVO 監聽
        preloadObservedItem = playerItem
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new],
            context: &VideoPreloader.preloadStatusContext
        )
        
        logger.log(.player, "[Preload] Waiting for status...")
    }
    
    /// 取消預驗證
    func cancel() {
        if let item = preloadObservedItem {
            item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &VideoPreloader.preloadStatusContext)
            preloadObservedItem = nil
        }
        successHandler = nil
        failureHandler = nil
        preloadPlayer?.replaceCurrentItem(with: nil)
        logger.log(.player, "[Preload] Cancelled")
    }
    
    // MARK: - KVO
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard context == &VideoPreloader.preloadStatusContext,
              let playerItem = object as? AVPlayerItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.handleStatusChange(status: playerItem.status, playerItem: playerItem)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleStatusChange(status: AVPlayerItem.Status, playerItem: AVPlayerItem) {
        logger.log(.player, "[Preload] Status changed: \(status.description)")
        
        switch status {
        case .readyToPlay:
            logger.log(.player, "[Preload] ✅ URL is valid, ready for main player")
            
            // 移除預驗證的 KVO
            if let item = preloadObservedItem {
                item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &VideoPreloader.preloadStatusContext)
                preloadObservedItem = nil
            }
            
            // 先取出 handler 並清空，防止 callback 內部啟動新流程時被覆蓋
            let handler = successHandler
            successHandler = nil
            failureHandler = nil
            
            // 調用成功回調
            if let handler = handler {
                // 嘗試從 asset 獲取 URL
                if let urlAsset = playerItem.asset as? AVURLAsset {
                    logger.log(.player, "[Preload] Creating new item from URL: \(urlAsset.url)")
                    let newItem = AVPlayerItem(url: urlAsset.url)
                    handler(newItem)
                } else {
                    // HLS 可能不是 AVURLAsset，直接用 playerItem
                    logger.log(.player, "[Preload] Asset is not AVURLAsset, using playerItem directly")
                    handler(playerItem)
                }
            }
            
        case .failed:
            if let error = playerItem.error {
                logger.log(.player, "[Preload] ❌ URL failed: \(error.localizedDescription)")
            } else {
                logger.log(.player, "[Preload] ❌ URL failed (unknown error)")
            }
            
            // 移除預驗證的 KVO
            if let item = preloadObservedItem {
                item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &VideoPreloader.preloadStatusContext)
                preloadObservedItem = nil
            }
            
            // 先取出 handler 並清空
            let handler = failureHandler
            successHandler = nil
            failureHandler = nil
            
            // 調用失敗回調
            handler?()
            
        case .unknown:
            break
            
        @unknown default:
            break
        }
    }
    
    deinit {
        cancel()
    }
}

