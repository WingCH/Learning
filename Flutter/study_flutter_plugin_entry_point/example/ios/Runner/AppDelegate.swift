import Flutter
import study_flutter_plugin_entry_point
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        StudyFlutterPluginEntryPointPlugin.setPluginRegistrantCallback({ registry in
            GeneratedPluginRegistrant.register(with: registry)
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
