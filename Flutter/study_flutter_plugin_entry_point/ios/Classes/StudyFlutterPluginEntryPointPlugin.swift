import Flutter
import UIKit

public class StudyFlutterPluginEntryPointPlugin: NSObject, FlutterPlugin {
    private static var flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    // TODO: should be save to userdefaults for background model
    private var callbackHandle: Int64?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "study_flutter_plugin_entry_point", binaryMessenger: registrar.messenger())
        let backgroundChannel = FlutterMethodChannel(name: "study_flutter_plugin_entry_point_background", binaryMessenger: registrar.messenger())
        let instance = StudyFlutterPluginEntryPointPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addMethodCallDelegate(instance, channel: backgroundChannel)
    }

    public static func setPluginRegistrantCallback(_ callback: FlutterPluginRegistrantCallback) {
        flutterPluginRegistrantCallback = callback
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "registerCallbackDispatcher":
            if let arguments = call.arguments as? [AnyHashable: Any],
               let callbackHandle = arguments["dispatcherHandler"] as? Int64
            {
                self.callbackHandle = callbackHandle
            }
            result(true)
        case "triggerVmEntryPoint":
            guard let callbackHandle = callbackHandle,
                  let flutterCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)
            else {
                result(false)
                return
            }
            
            var flutterEngine: FlutterEngine? = FlutterEngine(
                name: "FlutterEngine for background",
                project: nil,
                allowHeadlessExecution: true
            )
            flutterEngine!.run(
                withEntrypoint: flutterCallbackInformation.callbackName,
                libraryURI: flutterCallbackInformation.callbackLibraryPath
            )
            StudyFlutterPluginEntryPointPlugin.flutterPluginRegistrantCallback?(flutterEngine!)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
