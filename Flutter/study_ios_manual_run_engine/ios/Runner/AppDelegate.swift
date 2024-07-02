import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("Application didFinishLaunchingWithOptions")
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let foregroundChannel = FlutterMethodChannel(
            name: "samples.flutter.dev/foregroundChannel",
            binaryMessenger: controller.binaryMessenger
        )

        foregroundChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
                print("Foreground channel method called: \(call.method)")
                if call.method == "initialize" {
                    let arguments = call.arguments as? [AnyHashable: Any]
                    let handle = arguments?["callbackHandle"] as? Int
                    print("Foreground channel initialized with handle: \(handle)")

                    // save to userdefaults
                    UserDefaults.standard.set(handle, forKey: "callbackHandle")
                    result(nil)
                } else {
                    result(FlutterMethodNotImplemented)
                }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
