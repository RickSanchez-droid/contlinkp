import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'virtual_controller.dart';

class BluetoothManager {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  final StreamController<String> _connectionStatusController = StreamController<String>.broadcast();
  Map<String, String> _inputMappings = {};
  VirtualGameController? _virtualController;

  Stream<String> get connectionStatus => _connectionStatusController.stream;
  Map<String, String> get inputMappings => _inputMappings;

  Future<void> initialize() async {
    // Request permissions
    if (Platform.isAndroid) {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    } else if (Platform.isIOS) {
      await Permission.bluetooth.request();
    }

    // Initialize FlutterBluePlus
    await FlutterBluePlus.turnOn();
    
    // Initialize virtual controller
    _virtualController = VirtualGameController();
    await _virtualController!.initialize();

    // Load saved mappings
    await loadSavedMappings();
  }

  Future<void> connectToController() async {
    try {
      _connectionStatusController.add('Scanning...');
      
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          // You might want to filter devices based on name or service UUID
          if (result.device.name.toLowerCase().contains('controller')) {
            await FlutterBluePlus.stopScan();
            await _connectToDevice(result.device);
            break;
          }
        }
      });

    } catch (e) {
      _connectionStatusController.add('Error: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      _connectionStatusController.add('Connected to ${device.name}');

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        // Handle services and characteristics as needed
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              _handleControllerInput(value);
            });
          }
        }
      }
    } catch (e) {
      _connectionStatusController.add('Connection failed: ${e.toString()}');
      rethrow;
    }
  }

  void _handleControllerInput(List<int> value) {
    // Parse the raw input data
    String inputData = String.fromCharCodes(value);
    print('Received input: $inputData');
    
    // Map the input based on saved mappings
    if (_inputMappings.containsKey(inputData)) {
      String mappedButton = _inputMappings[inputData]!;
      
      // Convert the mapped button to GCControllerButtonInput
      _sendInputToVirtualController(mappedButton, true);
      
      // You might want to add logic here to detect button release
      // and call _sendInputToVirtualController with false
    }
  }

  void _sendInputToVirtualController(String button, bool isPressed) {
    if (_virtualController == null) return;

    // Convert button string to appropriate virtual controller input
    switch (button.toLowerCase()) {
      case 'a':
        _virtualController!.sendButtonInput('buttonA', isPressed);
        break;
      case 'b':
        _virtualController!.sendButtonInput('buttonB', isPressed);
        break;
      case 'x':
        _virtualController!.sendButtonInput('buttonX', isPressed);
        break;
      case 'y':
        _virtualController!.sendButtonInput('buttonY', isPressed);
        break;
      case 'l1':
        _virtualController!.sendButtonInput('leftShoulder', isPressed);
        break;
      case 'r1':
        _virtualController!.sendButtonInput('rightShoulder', isPressed);
        break;
      case 'l2':
        _virtualController!.sendTriggerInput('leftTrigger', isPressed ? 1.0 : 0.0);
        break;
      case 'r2':
        _virtualController!.sendTriggerInput('rightTrigger', isPressed ? 1.0 : 0.0);
        break;
      case 'd-pad up':
        _virtualController!.sendDPadInput('up', isPressed);
        break;
      case 'd-pad down':
        _virtualController!.sendDPadInput('down', isPressed);
        break;
      case 'd-pad left':
        _virtualController!.sendDPadInput('left', isPressed);
        break;
      case 'd-pad right':
        _virtualController!.sendDPadInput('right', isPressed);
        break;
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      _connectionStatusController.add('Disconnected');
      connectedDevice = null;
    }
  }

  void updateInputMapping(String originalInput, String mappedButton) {
    _inputMappings[originalInput] = mappedButton;
    saveInputMappingToJson(); // Save after updating
  }

  Future<void> loadSavedMappings() async {
    try {
      final file = File('config/input_mapping.json');
      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> jsonMap = json.decode(contents);
        _inputMappings = Map<String, String>.from(jsonMap);
      }
    } catch (e) {
      print('Error loading mappings: $e');
    }
  }

  Future<void> saveInputMappingToJson() async {
    try {
      final file = File('config/input_mapping.json');
      await file.writeAsString(json.encode(_inputMappings));
    } catch (e) {
      print('Error saving mappings: $e');
    }
  }

  void dispose() {
    _connectionStatusController.close();
    _virtualController?.dispose();
  }
}