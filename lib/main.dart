import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:developer' as developer;

import 'bluetooth_manager.dart'; // Import BluetoothManager

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('Flutter binding initialized');

    final BluetoothManager bluetoothManager = BluetoothManager();
    developer.log('BluetoothManager created');

    await bluetoothManager.initialize();
    developer.log('BluetoothManager initialized');

    runApp(ControllerMapperApp(bluetoothManager: bluetoothManager));
    developer.log('App started');
  } catch (e, stackTrace) {
    developer.log('Error in initialization: $e\n$stackTrace');
    // Show error screen instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class ControllerMapperApp extends StatelessWidget {
  final BluetoothManager bluetoothManager;
  
  const ControllerMapperApp({
    required this.bluetoothManager,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controller Mapper',
      debugShowCheckedModeBanner: false,  // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        // Add more theme configurations
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          developer.log('Building HomeScreen');
          return HomeScreen(bluetoothManager: bluetoothManager);
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final BluetoothManager bluetoothManager;

  const HomeScreen({
    required this.bluetoothManager,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedMapping;
  String? selectedButton;
  String connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    // Listen to connection status changes
    widget.bluetoothManager.connectionStatus.listen((status) {
      setState(() {
        connectionStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller Mapper'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $connectionStatus',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await widget.bluetoothManager.connectToController();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Connection error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Connect to Controller'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mappings Section
              Text(
                'Current Mappings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: widget.bluetoothManager.inputMappings.isEmpty
                    ? const Center(
                        child: Text('No mappings configured'),
                      )
                    : ListView.builder(
                        itemCount: widget.bluetoothManager.inputMappings.length,
                        itemBuilder: (context, index) {
                          final entry = widget.bluetoothManager.inputMappings.entries.elementAt(index);
                          return Card(
                            child: ListTile(
                              title: Text('${entry.key} → ${entry.value}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Add delete functionality
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Mapping Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Input'),
                        value: selectedMapping,
                        items: widget.bluetoothManager.inputMappings.keys
                            .map((key) => DropdownMenuItem(
                                  value: key,
                                  child: Text(key),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedMapping = value),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Button'),
                        value: selectedButton,
                        items: const [
                          'A', 'B', 'X', 'Y',
                          'L1', 'R1', 'L2', 'R2',
                          'D-Pad Up', 'D-Pad Down',
                          'D-Pad Left', 'D-Pad Right'
                        ].map((button) => DropdownMenuItem(
                              value: button,
                              child: Text(button),
                            )).toList(),
                        onChanged: (value) => setState(() => selectedButton = value),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: selectedMapping != null && selectedButton != null
                            ? () {
                                widget.bluetoothManager.updateInputMapping(
                                  selectedMapping!,
                                  selectedButton!,
                                );
                                setState(() {});
                              }
                            : null,
                        child: const Text('Update Mapping'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

