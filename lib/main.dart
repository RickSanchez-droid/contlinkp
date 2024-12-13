import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'bluetooth_manager.dart'; // Import BluetoothManager

void main() {
  runApp(const ControllerMapperApp());
}

class ControllerMapperApp extends StatelessWidget {
  const ControllerMapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final BluetoothManager bluetoothManager = BluetoothManager(); // Create an instance

    return StatefulBuilder(
      builder: (context, setState) {
        bluetoothManager.connectionStatus.listen((status) {
          setState(() {});
        });
        return MaterialApp(
          title: 'Controller Mapper',
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Controller Mapper'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Connection Status
                Center(
                  child: Text('Connection Status: ${bluetoothManager.connectionStatus}'),
                ),
                // Connect Button
                ElevatedButton(
                  onPressed: () {
                    bluetoothManager.connectToController().then((connection) {
                      // Handle successful connection
                      // Update UI to show connection status
                    }).catchError((error) {
                      // Handle connection error
                      // Display error message in UI
                      print('Connection Error: $error');
                    });
                  },
                  child: const Text('Connect to Controller'),
                ),
                // Input Mappings Section
                const SizedBox(height: 20),
                const Text('Input Mappings:'),
                Expanded(
                  child: bluetoothManager.inputMappings.isNotEmpty
                      ? ListView.builder(
                          itemCount: bluetoothManager.inputMappings.length,
                          itemBuilder: (context, index) {
                            final mapping = bluetoothManager.inputMappings.entries.elementAt(index);
                            return ListTile(
                              title: Text('${mapping.key} : ${mapping.value}'),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No mappings configured yet.'),
                        ),
                ),
                // Edit Mappings Section (Placeholder)
                const SizedBox(height: 20),
                const Text('Edit Mappings:'),
                // Dropdown to select mapping
                DropdownButton<String>(
                  items: bluetoothManager.inputMappings.keys.map((key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                  onChanged: (selectedKey) {
                    // Handle mapping selection
                  },
                  hint: const Text('Select Mapping'),
                ),
                // Dropdown to select PlayStation button
                String? selectedMapping; 
                String? selectedButton; 
                DropdownButton<String>( 
                    items: ['A', 'B', 'X', 'Y', 'L1', 'R1', 'L2', 'R2', 'D-Pad Up', 'D-Pad Down', 'D-Pad Left', 'D-Pad Right']
                        .map((button) {
                      return DropdownMenuItem<String>(
                        value: button,
                        child: Text(button),
                      );
                    }).toList(),
                    onChanged: (selectedButtonValue) {
                      selectedButton = selectedButtonValue;
                    },
                    hint: const Text('Select Button')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMapping != null && selectedButton != null) {
                      bluetoothManager.updateInputMapping(selectedMapping!, selectedButton!);
                      // You might want to trigger a UI update here (setState)
                      // to reflect the changes in the mappings list
                    }
                  },
                  child: const Text('Update Mapping'),
                ),
                // Save Button
                ElevatedButton(onPressed: () {
                  bluetoothManager.saveInputMappingToJson();
                }, child: const Text('Save Mappings')),
              ],
            ),
          ),
        );
      },
    );
  } 
}

