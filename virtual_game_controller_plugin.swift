swift
import Flutter
import GameController

class VirtualGameControllerPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var virtualController: GCController?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "virtual_game_controller", binaryMessenger: registrar.messenger())
        let instance = VirtualGameControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerVirtualController":
            registerVirtualController(result: result)
        case "sendButtonEvent":
            sendButtonEvent(call: call, result: result)
        case "sendAxisEvent":
            sendAxisEvent(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerVirtualController(result: @escaping FlutterResult) {
        virtualController = GCController.controllers().first
        if virtualController == nil {
            virtualController = GCController()
            virtualController?.playerIndex = 0 // Set player index if needed
        }
        result(nil)
    }


    private func sendButtonEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let buttonName = arguments["button"] as? String,
              let pressed = arguments["pressed"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendButtonEvent", details: nil))
            return
        }

        // Simulate button press/release
        if let virtualController = virtualController {
            //  Replace with actual button mapping based on your controller setup.
            if let button = getButton(for: buttonName, controller: virtualController) {
                button.value = pressed ? 1 : 0
            }
        }
        result(nil)
    }

    private func sendAxisEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let axisName = arguments["axis"] as? String,
              let value = arguments["value"] as? Double else {
                  result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendAxisEvent", details: nil))
                  return
              }
        
        if let virtualController = virtualController {
            // Replace with actual axis mapping
            if let axis = getAxis(for: axisName, controller: virtualController) {
                axis.value = CGFloat(value)
            }
        }
        result(nil)
    }


    // Helper functions to map button names to actual GCController elements
    private func getButton(for name: String, controller: GCController) -> GCControllerButtonInput? {
        switch name {
        case "A": return controller.extendedGamepad?.buttonA
        case "B": return controller.extendedGamepad?.buttonB
        // Add more button mappings
        default: return nil
        }
    }
    
    private func getAxis(for name: String, controller: GCController) -> GCControllerAxisInput? {
        switch name {
        case "leftStickX": return controller.extendedGamepad?.leftThumbstick?.xAxis
        case "leftStickY": return controller.extendedGamepad?.leftThumbstick?.yAxis
            // Add more axis mappings here
        default: return nil
        }
    }
}