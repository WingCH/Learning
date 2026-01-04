import Flutter
import UIKit

public class BatteryLevelPlugin: NSObject, FlutterPlugin, BatteryLevelApi {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BatteryLevelPlugin()
        BatteryLevelApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }
    
    func getBatteryLevel() throws -> Int64 {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel < 0 {
            return -1
        }
        return Int64(batteryLevel * 100)
    }
    
    func getBatteryState() throws -> PlatformBatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        
        switch state {
        case .charging:
            return .charging
        case .full:
            return .full
        case .unplugged:
            return .discharging
        case .unknown:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
    
    func getBatteryInfo() throws -> BatteryInfo {
        let level = try getBatteryLevel()
        let state = try getBatteryState()
        
        return BatteryInfo(level: level, state: state)
    }
}
