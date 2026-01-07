//
//  PiPLogger.swift
//  study_pip_lifecycle
//
//  Created by Wing CHAN on 1/8/26.
//

import Foundation

/// PiP lifecycle event types
enum PiPEvent: String {
    // Setup
    case setup = "SETUP"
    case audioSession = "AUDIO"
    case player = "PLAYER"
    case controller = "CONTROLLER"
    
    // User actions
    case action = "ACTION"
    
    // PiP delegate callbacks
    case willStart = "WILL_START"
    case didStart = "DID_START"
    case failedToStart = "FAILED"
    case willStop = "WILL_STOP"
    case didStop = "DID_STOP"
    case restoreUI = "RESTORE_UI"
    
    // State
    case state = "STATE"
}

/// Simple PiP lifecycle logger with [PiP] prefix
final class PiPLogger {
    
    static let shared = PiPLogger()
    private init() {}
    
    private let prefix = "[PiP]"
    
    /// Log a PiP lifecycle event
    func log(_ event: PiPEvent, _ message: String) {
        print("\(prefix) [\(event.rawValue)] \(message)")
    }
    
    /// Log with additional key-value info
    func log(_ event: PiPEvent, _ message: String, info: [String: Any]) {
        let infoStr = info.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        print("\(prefix) [\(event.rawValue)] \(message) | \(infoStr)")
    }
    
    /// Log an error
    func error(_ event: PiPEvent, _ error: Error) {
        print("\(prefix) [\(event.rawValue)] ERROR: \(error.localizedDescription)")
    }
    
    /// Log current PiP state
    func state(isPossible: Bool, isActive: Bool, playerStatus: String? = nil) {
        var info = "isPossible=\(isPossible), isActive=\(isActive)"
        if let status = playerStatus {
            info += ", playerStatus=\(status)"
        }
        print("\(prefix) [STATE] \(info)")
    }
}
