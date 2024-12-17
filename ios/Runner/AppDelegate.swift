import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSLog("AppDelegate - Application will launch")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    NSLog("AppDelegate - Flutter controller initialized")
    
    GeneratedPluginRegistrant.register(with: self)
    NSLog("AppDelegate - Plugins registered")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
} 