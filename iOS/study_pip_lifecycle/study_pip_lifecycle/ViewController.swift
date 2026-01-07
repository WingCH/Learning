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
    
    /// 開始 PiP 的按鈕
    private lazy var startPiPButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("開始畫中畫", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startPiPButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 狀態標籤
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "準備就緒"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        logger.log(.setup, "viewDidLoad started")
        setupUI()
        setupPlayer()
        logger.log(.setup, "viewDidLoad completed")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    // MARK: - Setup
    
    /// 設定 UI 元件
    private func setupUI() {
        view.addSubview(startPiPButton)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            startPiPButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startPiPButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPiPButton.widthAnchor.constraint(equalToConstant: 160),
            startPiPButton.heightAnchor.constraint(equalToConstant: 50),
            statusLabel.topAnchor.constraint(equalTo: startPiPButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    /// 設定視頻播放器和 PiP 控制器
    private func setupPlayer() {
        let isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
        logger.log(.setup, "PiP supported: \(isPiPSupported)")
        
        guard isPiPSupported else {
            statusLabel.text = "此設備不支援畫中畫"
            startPiPButton.isEnabled = false
            return
        }
        
        // 設定音頻 session（允許背景播放）
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            logger.log(.audioSession, "Audio session configured")
        } catch {
            logger.error(.audioSession, error)
        }
        
        // 創建播放器
        let videoURL = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
        player = AVPlayer(url: videoURL)
        logger.log(.player, "AVPlayer created with URL")
        
        // 創建播放器圖層（PiP 需要一個 layer 來參考）
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
        logger.log(.controller, "AVPictureInPictureController created")
        
        statusLabel.text = "準備就緒，點擊按鈕開始"
    }
    
    // MARK: - Actions
    
    /// 點擊開始 PiP 按鈕
    @objc private func startPiPButtonTapped() {
        logger.log(.action, "Button tapped")
        
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
        
        guard pipController.isPictureInPicturePossible else {
            logger.log(.state, "PiP not possible yet, waiting for video to load")
            statusLabel.text = "正在載入視頻..."
            player?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.startPiPButtonTapped()
            }
            return
        }
        
        player?.play()
        
        if pipController.isPictureInPictureActive {
            logger.log(.action, "Stopping PiP")
            pipController.stopPictureInPicture()
            statusLabel.text = "PiP 已停止"
        } else {
            logger.log(.action, "Starting PiP")
            pipController.startPictureInPicture()
            statusLabel.text = "PiP 啟動中..."
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
        startPiPButton.setTitle("停止畫中畫", for: .normal)
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
        startPiPButton.setTitle("開始畫中畫", for: .normal)
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
 正常播放一條有效的連結
 [PiP] [ACTION] Button tapped
 [PiP] [STATE] isPossible=true, isActive=false, playerStatus=readyToPlay
 [PiP] [ACTION] Starting PiP
 [PiP] [WILL_START] PiP will start
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
 */
