import Flutter
import UIKit
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "startup-notification")
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "daily-notification", frequency: NSNumber(value: 60 * 15))
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60 * 15))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
