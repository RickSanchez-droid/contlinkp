import UIKit
import Flutter
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  func logStackTrace() {
    let symbols = Thread.callStackSymbols
    NSLog("Current stack trace:")
    for symbol in symbols {
      NSLog(symbol)
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSSetUncaughtExceptionHandler { exception in
      NSLog("CRASH: \(exception)")
      NSLog("Stack Trace: \(exception.callStackSymbols)")
    }
    
    signal(SIGTRAP) { signal in
      NSLog("Received SIGTRAP signal")
    }
    
    NSLog("AppDelegate - Application will launch")
    
    do {
      NSLog("AppDelegate - Setting up window")
      guard let window = self.window else {
        NSLog("Window is nil!")
        return false
      }
      
      let controller = FlutterViewController()
      window.rootViewController = controller
      window.makeKeyAndVisible()
      NSLog("AppDelegate - Flutter controller initialized")
      
      GeneratedPluginRegistrant.register(with: self)
      NSLog("AppDelegate - Plugins registered")
      
      logStackTrace()
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    } catch {
      NSLog("Error in AppDelegate: \(error)")
      logStackTrace()
      return false
    }
  }
} 