//
//  ViewController.swift
//  study_pip_lifecycle
//
//  Created by Wing CHAN on 1/8/26.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 日誌記錄器
    private let logger = PiPLogger.shared
    
    /// 視頻播放器
    private var player: AVPlayer?
    
    /// 播放器圖層
    private var playerLayer: AVPlayerLayer?
    
    /// 畫中畫控制器
    private var pipController: AVPictureInPictureController?
    
    /// KVO context - status
    private static var playerItemStatusContext = 0
    
    /// KVO context - playbackLikelyToKeepUp
    private static var playbackLikelyToKeepUpContext = 0
    
    /// 當前正在監聽的 player item
    private weak var observedPlayerItem: AVPlayerItem?
    
    /// Case 1 按鈕：播放有效連結
    private lazy var case1Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Case 1: 播放有效的 m3u8", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(case1ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Case 2 按鈕：播放無效連結
    private lazy var case2Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Case 2: 播放無效的 m3u8", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(case2ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Case 3 按鈕：PiP 運行中切換另一條 URL
    private lazy var case3Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Case 3: 播放另一條 URL", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(case3ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Case 4 按鈕：先播放本地 dummy 快速啟動 PiP
    private lazy var case4Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Case 4: 先 dummy 再播放有效m3u8", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(case4ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 狀態標籤
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "準備就緒"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        logger.log(.setup, "viewDidLoad started")
        setupUI()
        setupAudioSession()
        setupPlayer()
        logger.log(.setup, "viewDidLoad completed")
    }
    
    deinit {
        // 確保移除 KVO observer
        removePlayerItemObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    // MARK: - Setup
    
    /// 設定 UI 元件
    private func setupUI() {
        view.addSubview(case1Button)
        view.addSubview(case2Button)
        view.addSubview(case3Button)
        view.addSubview(case4Button)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            // Case 1 按鈕
            case1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            case1Button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            case1Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            case1Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            case1Button.heightAnchor.constraint(equalToConstant: 50),
            
            // Case 2 按鈕
            case2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            case2Button.topAnchor.constraint(equalTo: case1Button.bottomAnchor, constant: 16),
            case2Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            case2Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            case2Button.heightAnchor.constraint(equalToConstant: 50),
            
            // Case 3 按鈕
            case3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            case3Button.topAnchor.constraint(equalTo: case2Button.bottomAnchor, constant: 16),
            case3Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            case3Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            case3Button.heightAnchor.constraint(equalToConstant: 50),
            
            // Case 4 按鈕
            case4Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            case4Button.topAnchor.constraint(equalTo: case3Button.bottomAnchor, constant: 16),
            case4Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            case4Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            case4Button.heightAnchor.constraint(equalToConstant: 50),
            
            // 狀態標籤
            statusLabel.topAnchor.constraint(equalTo: case4Button.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // 檢查 PiP 支援
        let isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
        logger.log(.setup, "PiP supported: \(isPiPSupported)")
        
        if !isPiPSupported {
            statusLabel.text = "此設備不支援畫中畫"
            case1Button.isEnabled = false
            case2Button.isEnabled = false
            case3Button.isEnabled = false
            case4Button.isEnabled = false
        }
    }
    
    /// 設定音頻 session（只需設定一次）
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            logger.log(.audioSession, "Audio session configured")
        } catch {
            logger.error(.audioSession, error)
        }
    }
    
    /// 設定 Player 和 PiP Controller（前置工作，不載入視頻）
    private func setupPlayer() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            return
        }
        
        // 創建空的播放器
        player = AVPlayer()
        logger.log(.player, "AVPlayer created (empty)")
        
        // 創建播放器圖層
        let layer = AVPlayerLayer(player: player)
        layer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        view.layer.addSublayer(layer)
        playerLayer = layer
        logger.log(.player, "AVPlayerLayer added to view")
        
        // 創建 PiP 控制器
        pipController = AVPictureInPictureController(playerLayer: layer)
        pipController?.delegate = self
        if #available(iOS 14.2, *) {
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
        
        // 設定為直播模式（隱藏進度條）
        pipController?.requiresLinearPlayback = true
        logger.log(.controller, "AVPictureInPictureController created (linear playback mode)")
        
        statusLabel.text = "準備就緒，點擊按鈕開始"
    }
    
    /// 載入視頻
    /// - Parameter url: 視頻 URL
    /// - Note: 如果 PiP 正在運行，會保持 PiP 並切換視頻；否則會在載入完成後啟動 PiP
    private func loadVideo(url: URL) {
        let isPiPActive = pipController?.isPictureInPictureActive ?? false
        
        logger.log(.player, "Loading video: \(url.absoluteString)")
        logger.log(.controller, "PiP active: \(isPiPActive)")
        
        // 如果 PiP 沒有運行，停止現有播放
        if !isPiPActive {
            player?.pause()
        }
        
        // 移除舊的監聽器
        removePlayerItemObserver()
        
        // 替換播放內容
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        logger.log(.player, "Player item replaced")
        
        // 添加新的監聽器
        addPlayerItemObserver(playerItem)
        
        // 開始播放
        player?.play()
        logger.log(.player, "Player started")
        
        statusLabel.text = "載入視頻中..."
    }
    
    /// 添加 player item 狀態監聽器
    private func addPlayerItemObserver(_ playerItem: AVPlayerItem) {
        observedPlayerItem = playerItem
        
        // 監聽 status
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new, .initial],
            context: &ViewController.playerItemStatusContext
        )
        
        // 監聽 isPlaybackLikelyToKeepUp
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
            options: [.new, .initial],
            context: &ViewController.playbackLikelyToKeepUpContext
        )
        
        logger.log(.player, "Added observers for player item")
    }
    
    /// 移除 player item 狀態監聽器
    private func removePlayerItemObserver() {
        if let item = observedPlayerItem {
            item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &ViewController.playerItemStatusContext)
            item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), context: &ViewController.playbackLikelyToKeepUpContext)
            observedPlayerItem = nil
            logger.log(.player, "Removed observers for player item")
        }
    }
    
    /// KVO 回調
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let playerItem = object as? AVPlayerItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        // 處理 status 變化
        if context == &ViewController.playerItemStatusContext {
            DispatchQueue.main.async { [weak self] in
                self?.handlePlayerItemStatusChange(status: playerItem.status)
            }
            return
        }
        
        // 處理 isPlaybackLikelyToKeepUp 變化
        if context == &ViewController.playbackLikelyToKeepUpContext {
            DispatchQueue.main.async { [weak self] in
                self?.handlePlaybackLikelyToKeepUpChange(isLikelyToKeepUp: playerItem.isPlaybackLikelyToKeepUp)
            }
            return
        }
        
        // 不是我們的 context，交給 super
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    /// 處理 isPlaybackLikelyToKeepUp 變化
    private func handlePlaybackLikelyToKeepUpChange(isLikelyToKeepUp: Bool) {
        logger.log(.player, "isPlaybackLikelyToKeepUp: \(isLikelyToKeepUp)")
    }
    
    /// 處理 player item 狀態變化
    private func handlePlayerItemStatusChange(status: AVPlayerItem.Status) {
        logger.log(.player, "Player item status changed: \(status.description)")
        
        switch status {
        case .readyToPlay:
            logger.log(.player, "Video ready to play")
            startPiP()
            
        case .failed:
            if let error = player?.currentItem?.error {
                logger.error(.player, error)
                statusLabel.text = "視頻載入失敗: \(error.localizedDescription)"
            } else {
                logger.log(.player, "Video failed to load (unknown error)")
                statusLabel.text = "視頻載入失敗"
            }
            
        case .unknown:
            // 還在載入中
            break
            
        @unknown default:
            break
        }
    }
    
    /// 啟動 PiP
    private func startPiP() {
        guard let pipController = pipController else {
            logger.log(.controller, "PiP controller is nil")
            statusLabel.text = "PiP 控制器未初始化"
            return
        }
        
        logger.state(
            isPossible: pipController.isPictureInPicturePossible,
            isActive: pipController.isPictureInPictureActive,
            playerStatus: player?.currentItem?.status.description
        )
        
        // 如果 PiP 已經在運行，只需更新狀態
        if pipController.isPictureInPictureActive {
            logger.log(.action, "PiP already active, video updated")
            statusLabel.text = "PiP 播放中（視頻已更新）"
            return
        }
        
        if pipController.isPictureInPicturePossible {
            logger.log(.action, "Starting PiP")
            pipController.startPictureInPicture()
            statusLabel.text = "PiP 啟動中..."
        } else {
            logger.log(.state, "PiP not possible yet")
            statusLabel.text = "PiP 等待視頻載入..."
        }
    }
    
    // MARK: - Actions
    
    /// Case 1: 播放有效連結
    @objc private func case1ButtonTapped() {
        logger.log(.action, "=== Case 1: Valid URL ===")
        
        let validURL = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
        loadVideo(url: validURL)
    }
    
    /// Case 2: 播放無效連結
    @objc private func case2ButtonTapped() {
        logger.log(.action, "=== Case 2: Invalid URL ===")
        
        let invalidURL = URL(string: "https://invalid-url.example.com/invalid.m3u8")!
        loadVideo(url: invalidURL)
    }
    
    /// Case 3: PiP 運行中切換另一條 URL
    @objc private func case3ButtonTapped() {
        logger.log(.action, "=== Case 3: Switch URL ===")
        
        // 另一條有效的測試 URL
        let anotherURL = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
        loadVideo(url: anotherURL)
    }
    
    /// Case 4: 先播放本地 dummy 快速啟動 PiP，再切換到真實 m3u8
    @objc private func case4ButtonTapped() {
        logger.log(.action, "=== Case 4: Dummy first, then m3u8 ===")
        
        // 本地 dummy 視頻
        guard let dummyURL = Bundle.main.url(forResource: "dummy", withExtension: "mp4") else {
            logger.log(.player, "ERROR: dummy.mp4 not found in bundle")
            statusLabel.text = "找不到 dummy.mp4"
            return
        }
        
        // 真實的 m3u8 URL
        let realURL = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
        
        logger.log(.player, "Step 1: Loading dummy video for instant PiP")
        loadVideo(url: dummyURL)
        
        // 當 PiP 啟動後，延遲切換到真實 m3u8
        // 這裡用簡單的延遲，實際項目可以用 delegate 回調
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.logger.log(.player, "Step 2: Switching to real m3u8")
            self.loadVideo(url: realURL)
        }
    }
}

// MARK: - AVPictureInPictureControllerDelegate

extension ViewController: AVPictureInPictureControllerDelegate {
    
    /// PiP 即將開始
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        logger.log(.willStart, "PiP will start")
        statusLabel.text = "PiP 即將開始..."
    }
    
    /// PiP 已開始
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        logger.log(.didStart, "PiP did start")
        statusLabel.text = "PiP 播放中"
    }
    
    /// PiP 開始失敗
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        logger.error(.failedToStart, error)
        statusLabel.text = "PiP 啟動失敗: \(error.localizedDescription)"
    }
    
    /// PiP 即將停止
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        logger.log(.willStop, "PiP will stop")
        statusLabel.text = "PiP 即將停止..."
    }
    
    /// PiP 已停止
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        logger.log(.didStop, "PiP did stop")
        
        // 停止播放，避免背景繼續播放聲音
        player?.pause()
        logger.log(.player, "Player paused")
        
        statusLabel.text = "PiP 已停止"
    }
    
    /// 使用者要求恢復播放介面
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        logger.log(.restoreUI, "User requested to restore UI")
        statusLabel.text = "恢復播放介面"
        completionHandler(true)
    }
}

// MARK: - AVPlayerItem.Status Extension

extension AVPlayerItem.Status: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .readyToPlay: return "readyToPlay"
        case .failed: return "failed"
        @unknown default: return "unknown(\(rawValue))"
        }
    }
}


/*
 Case 1:
 播放一條有效的連結
 [PiP] [ACTION] === Case 1: Valid URL ===
 [PiP] [PLAYER] Loading video: https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
 [PiP] [CONTROLLER] PiP active: false
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] Player item status changed: readyToPlay
 [PiP] [PLAYER] Video ready to play
 [PiP] [STATE] isPossible=true, isActive=false, playerStatus=readyToPlay
 [PiP] [ACTION] Starting PiP
 [PiP] [WILL_START] PiP will start
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 [PiP] [DID_START] PiP did start
 
 if 用户點擊左上角close button
 [PiP] [WILL_STOP] PiP will stop
 [PiP] [DID_STOP] PiP did stop
 [PiP] [PLAYER] Player paused
 
 if 用户點擊右上角resume button
 [PiP] [RESTORE_UI] User requested to restore UI
 [PiP] [WILL_STOP] PiP will stop
 [PiP] [DID_STOP] PiP did stop
 [PiP] [PLAYER] Player paused
 
 =======
 Case 2:
 播放一條無效的連結
 [PiP] [ACTION] === Case 2: Invalid URL ===
 [PiP] [PLAYER] Loading video: https://invalid-url.example.com/invalid.m3u8
 [PiP] [CONTROLLER] PiP active: false
 [PiP] [PLAYER] Removed observers for player item
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] Player item status changed: failed
 [PiP] [PLAYER] ERROR: A TLS error caused the secure connection to fail.
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 
 =======
 Case 3: 播放另一條 URL
 if 先完成 Case 1
 [PiP] [ACTION] === Case 3: Switch URL ===
 [PiP] [PLAYER] Loading video: https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8
 [PiP] [CONTROLLER] PiP active: true
 [PiP] [PLAYER] Removed observers for player item
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] Player item status changed: readyToPlay
 [PiP] [PLAYER] Video ready to play
 [PiP] [STATE] isPossible=true, isActive=true, playerStatus=readyToPlay
 [PiP] [ACTION] PiP already active, video updated
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 
 if 直接運行Case 3 (和上面一樣)
 [PiP] [ACTION] === Case 3: Switch URL ===
 [PiP] [PLAYER] Loading video: https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8
 [PiP] [CONTROLLER] PiP active: false
 [PiP] [PLAYER] Removed observers for player item
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] Player item status changed: readyToPlay
 [PiP] [PLAYER] Video ready to play
 [PiP] [STATE] isPossible=true, isActive=false, playerStatus=readyToPlay
 [PiP] [ACTION] Starting PiP
 [PiP] [WILL_START] PiP will start
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 [PiP] [DID_START] PiP did start
 
 
 === Case 4:先 dummy 再有效m3u8
 [PiP] [ACTION] === Case 4: Dummy first, then m3u8 ===
 [PiP] [PLAYER] Step 1: Loading dummy video for instant PiP
 [PiP] [PLAYER] Loading video: file:///Users/wingchan/Library/Developer/CoreSimulator/Devices/D19D48DD-0189-414F-9634-B90EEBF29B4B/data/Containers/Bundle/Application/9D60FFB1-8764-4100-A990-8769065F9823/study_pip_lifecycle.app/dummy.mp4
 [PiP] [CONTROLLER] PiP active: false
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 [PiP] [PLAYER] Player item status changed: readyToPlay
 [PiP] [PLAYER] Video ready to play
 [PiP] [STATE] isPossible=true, isActive=false, playerStatus=readyToPlay
 [PiP] [ACTION] Starting PiP
 [PiP] [WILL_START] PiP will start
 [PiP] [DID_START] PiP did start
 [PiP] [PLAYER] Step 2: Switching to real m3u8
 [PiP] [PLAYER] Loading video: https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8
 [PiP] [CONTROLLER] PiP active: true
 [PiP] [PLAYER] Removed observers for player item
 [PiP] [PLAYER] Player item replaced
 [PiP] [PLAYER] Added observers for player item
 [PiP] [PLAYER] Player started
 [PiP] [PLAYER] Player item status changed: unknown
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: false
 [PiP] [PLAYER] Player item status changed: readyToPlay
 [PiP] [PLAYER] Video ready to play
 [PiP] [STATE] isPossible=true, isActive=true, playerStatus=readyToPlay
 [PiP] [ACTION] PiP already active, video updated
 [PiP] [PLAYER] isPlaybackLikelyToKeepUp: true
 */
