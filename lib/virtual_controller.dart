import 'package:flutter/services.dart';

class VirtualGameController {
  static const platform = MethodChannel('virtual_game_controller');
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      final result = await platform.invokeMethod('registerController');
      print('Virtual controller initialized: $result');
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize virtual controller: $e');
      rethrow;
    }
  }

  Future<void> sendButtonInput(String button, bool isPressed) async {
    if (!_isInitialized) return;

    try {
      await platform.invokeMethod('sendInputEvent', {
        'type': 'button',
        'button': button,
        'value': isPressed ? 1.0 : 0.0,
      });
    } catch (e) {
      print('Failed to send button input: $e');
    }
  }

  Future<void> sendTriggerInput(String trigger, double value) async {
    if (!_isInitialized) return;

    try {
      await platform.invokeMethod('sendInputEvent', {
        'type': 'trigger',
        'trigger': trigger,
        'value': value,
      });
    } catch (e) {
      print('Failed to send trigger input: $e');
    }
  }

  Future<void> sendDPadInput(String direction, bool isPressed) async {
    if (!_isInitialized) return;

    try {
      await platform.invokeMethod('sendInputEvent', {
        'type': 'dpad',
        'direction': direction,
        'value': isPressed ? 1.0 : 0.0,
      });
    } catch (e) {
      print('Failed to send d-pad input: $e');
    }
  }

  void dispose() {
    // Clean up any resources if needed
  }
}
