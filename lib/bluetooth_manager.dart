import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:myapp/virtual_controller.dart';

/// Manages Bluetooth connections to game controllers.
class BluetoothManager {
  // Store the input mappings.
  final Map<String, dynamic> _inputMappings = {}; 

  // Controller for connection status changes.
  final _connectionStatusController = StreamController<BluetoothConnectionStatus>.broadcast();

  /// Scans for available Bluetooth devices and filters for game controllers.
  ///
  /// Returns a list of [BluetoothDevice] objects representing the detected
  /// game controllers.
  Future<List<BluetoothDevice>> scanForDevices() async {
    // Get the list of paired devices.
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    // Start scanning for new devices.
    // This uses default search duration of 10 seconds.
    final newDevices = await FlutterBluetoothSerial.instance.requestEnableBluetooth();
    if (newDevices != true) {
      // TODO: Handle user rejection of enabling Bluetooth.
      throw Exception("Bluetooth is not enabled.");
    }
    //await FlutterBluetoothSerial.instance.startDiscovery().listen((discoveryData) {});

    // Filter for game controllers (placeholder filter for now).
    final gameControllers = devices.where((device) {
      // TODO: Implement a more robust filter for game controllers.
      // For now, we'll just check if the device name contains "Gamepad".
      return device.name?.contains('Gamepad') ?? false;
    }).toList();

    return gameControllers;
  }

  /// Connects to the specified Bluetooth device.
  ///
  /// [device] The Bluetooth device to connect to.
  ///
  /// Returns a [BluetoothConnection] object representing the established
  /// connection.
  ///
  /// Throws an exception if the connection fails.
  Future<BluetoothConnection> connectToDevice(BluetoothDevice device) async {
    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      // Listen for connection status changes.
      connection.onStateChanged().listen((status) {
        _connectionStatusController.add(status);
      });
      return connection;
    } catch (e) {
      // TODO: Handle connection errors more gracefully.
      print('Failed to connect to device: ${e.toString()}');
      rethrow;
    }
  }

  /// Handles incoming data from the connected Bluetooth device.
  ///
  /// [connection] The Bluetooth connection to read data from.
  ///
  /// Emits controller input events as they are received and parsed.
  Stream<Uint8List> handleIncomingData(BluetoothConnection connection) {
    final controller = StreamController<Uint8List>();
    final virtualController = VirtualGameController(); // Assuming this is initialized elsewhere

    connection.input!.listen((Uint8List data) async {
      try {
        // Load input mappings if not already loaded.
        if (_inputMappings.isEmpty) {
          final mappingJson = await rootBundle.loadString('config/input_mapping.json');
          _inputMappings.addAll(json.decode(mappingJson));
        }

        // Process incoming data.
        for (var byte in data) {
          final byteKey = byte.toString(); 
          if (_inputMappings.containsKey(byteKey)) {
            final action = _inputMappings[byteKey];
            // Trigger the corresponding virtual controller action.
            print('Triggering action: $action for input: $byteKey');
            virtualController.performAction(action);
          } else if (byte != 0) { // Ignore idle/zero inputs
            print('Unmapped input: $byteKey'); 
          }
        }
      } catch (e) {
        print('Error handling incoming data: $e');
      }

      controller.add(rawData); // For now, still emitting raw data.
    }).onDone(() { 
      print('Bluetooth connection closed');
      controller.close();
    });

    return controller.stream;
  }

  /// Connects to a Bluetooth controller.
  ///
  /// Scans for available devices, filters for game controllers,
  /// and allows the user to select a controller to connect to.
  ///
  /// Returns a [BluetoothConnection] object if the connection is successful,
  /// otherwise throws an exception.
  Future<BluetoothConnection> connectToController() async {
    try {
      // Scan for Bluetooth devices.
      final devices = await scanForDevices();

      // If no devices are found, throw an exception.
      if (devices.isEmpty) {
        throw Exception('No Bluetooth game controllers found.');
      }

      // Allow the user to select a device from the list.
      // Placeholder: Replace with actual UI for device selection.
      final selectedDevice = devices.first; // For now, select the first device.

      // Attempt to connect to the selected device.
      final connection = await connectToDevice(selectedDevice);

      // If it's a new controller, prompt for button mapping.
      await _promptAndSaveInputMapping(connection); 

      return connection;
    } catch (e) {
      // Handle connection errors.
      print('Failed to connect to controller: ${e.toString()}');
      rethrow;
    }
  }

  // Placeholder for displaying a device selection dialog.
  // Replace with your actual UI implementation.
  Future<BluetoothDevice?> _showDeviceSelectionDialog(
      BuildContext context, List<BluetoothDevice> devices) async {
    // ... (Your UI code here)
    return devices.first; // Placeholder: Select the first device for now.
  }

  // Placeholder for handling connection errors.
  // Replace with your actual error handling logic.
  void _handleConnectionError(BuildContext context, Object error) {
    // ... (Your error handling code here)
    print('Connection error: $error');
  }

  /// Prompts the user to map inputs for a new controller and saves the mapping.
  Future<void> _promptAndSaveInputMapping(BluetoothConnection connection) async {
    // Check if there's an existing mapping for this device.
    if (_inputMappings.isNotEmpty) {
      print('Input mapping already exists. Skipping mapping prompt.');
      return; // Mapping already exists, no need to prompt.
    }

    print('New controller detected. Starting input mapping process...');

    final gameInputs = [
      'A', 'B', 'X', 'Y', 'L1', 'R1', 'L2', 'R2',
      'D-Pad Up', 'D-Pad Down', 'D-Pad Left', 'D-Pad Right',
      'Start', 'Select',
      // ... add other game inputs as needed
    ];

    for (final gameInput in gameInputs) {
      print('Press the button/trigger/direction for "$gameInput"...');

      // Wait for input from the controller.
      final rawData = await connection.input!.first; 

      // Check for duplicate mappings (ensure data integrity).
      if (_inputMappings.containsValue(rawData)) {
        print('Warning: This input is already mapped to another action. Please try again.');
        // You could add a retry mechanism here.
        continue;
      }

      // Store the mapping.
      _inputMappings[rawData.toString()] = gameInput; 

      print('Mapped "$gameInput" to raw input: $rawData');
    }

    // Save the mappings to the JSON file.
    await saveInputMappingToJson();

    print('Input mapping completed and saved.');
  }

  /// Get the current input mappings.
  Map<String, dynamic> get inputMappings {
    return _inputMappings;
  }

  /// Get the current input mappings.
  Map<String, dynamic> getInputMappings() {
    return _inputMappings;
  }

  /// Updates the input mappings with the provided data.
  ///
  /// [newMappings] A map containing the new input mappings.
  void updateInputMappings(Map<String, dynamic> newMappings) {
    _inputMappings.clear();
    _inputMappings.addAll(newMappings);

    print('Input mappings updated.');
  }

  /// Saves the current input mapping to a JSON file.
  Future<void> saveInputMappingToJson() async {
    try {
      // Convert the input mappings to JSON format.
      final jsonMapping = jsonEncode(_inputMappings);

      // Create a File object for the configuration file.
      final configFile = File('config/input_mapping.json');

      // Write the JSON data to the file.
      await configFile.writeAsString(jsonMapping);

      print('Input mapping saved to config/input_mapping.json');
    } catch (e) {
      print('Error saving input mapping: $e');
    }

    print('Input mapping saved to config/input_mapping.json'); 
  }

  /// Returns a stream that emits connection status changes.
  Stream<BluetoothConnectionStatus> get connectionStatusStream {
    return _connectionStatusController.stream;
  }
}