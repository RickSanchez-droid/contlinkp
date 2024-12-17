//this is the main file for contlink
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final BluetoothManager bluetoothManager = BluetoothManager();
  await bluetoothManager.initialize();
  runApp(ControllerMapperApp(bluetoothManager: bluetoothManager));
}

class ControllerMapperApp extends StatelessWidget {
  final BluetoothManager bluetoothManager;

  const ControllerMapperApp({required this.bluetoothManager, super.key});

  @override
  Widget build(BuildContext context) {
    String? selectedMapping;
    String? selectedButton;

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
                  child: Text(
                      'Connection Status: ${bluetoothManager.connectionStatus}'),
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
                            final mapping = bluetoothManager
                                .inputMappings.entries
                                .elementAt(index);
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
                DropdownButton<String>(
                    items: [
                      'A',
                      'B',
                      'X',
                      'Y',
                      'L1',
                      'R1',
                      'L2',
                      'R2',
                      'D-Pad Up',
                      'D-Pad Down',
                      'D-Pad Left',
                      'D-Pad Right'
                    ].map((button) {
                      return DropdownMenuItem<String>(
                        value: button,
                        child: Text(button),
                      );
                    }).toList(),
                    onChanged: (selectedButtonValue) {
                      setState(() {
                        selectedButton = selectedButtonValue;
                      });
                    },
                    value: selectedButton,
                    hint: const Text('Select Button')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMapping != null && selectedButton != null) {
                      bluetoothManager.updateInputMapping(
                          selectedMapping!, selectedButton!);
                      // You might want to trigger a UI update here (setState)
                      // to reflect the changes in the mappings list
                    }
                  },
                  child: const Text('Update Mapping'),
                ),
                // Save Button
                ElevatedButton(
                    onPressed: () {
                      bluetoothManager.saveInputMappingToJson();
                    },
                    child: const Text('Save Mappings')),
              ],
            ),
          ),
        );
      },
    );
  }
}
