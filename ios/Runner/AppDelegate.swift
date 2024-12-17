import UIKit
import Flutter
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSLog("AppDelegate - Application will launch")
    
    // Create and configure Flutter engine
    let flutterEngine = FlutterEngine(name: "my flutter engine")
    NSLog("AppDelegate - Created Flutter engine")
    
    // Start Flutter engine
    flutterEngine.run()
    NSLog("AppDelegate - Started Flutter engine")
    
    // Set the engine as the app's engine
    self.flutterEngine = flutterEngine
    
    // Create Flutter view controller with the engine
    let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    NSLog("AppDelegate - Created Flutter view controller")
    
    // Set root view controller
    window.rootViewController = controller
    window.makeKeyAndVisible()
    NSLog("AppDelegate - Set root view controller")
    
    GeneratedPluginRegistrant.register(with: self)
    NSLog("AppDelegate - Plugins registered")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
} 