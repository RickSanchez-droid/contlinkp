import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:developer' as developer;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

import 'bluetooth_manager.dart'; // Import BluetoothManager
import 'error_screen.dart';  // Add this import

// Add this class to store logs
class AppLogger {
  static final List<String> logs = [];
  static final StreamController<String> _logController = StreamController<String>.broadcast();
  
  static Stream<String> get logStream => _logController.stream;
  
  static void log(String message) {
    developer.log(message);
    logs.add(message);
    _logController.add(message);
  }
}

void main() {
  // Force light mode and add error catching
  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: ErrorWidget.builder = (FlutterErrorDetails details) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'Error: ${details.exception}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
        child: Builder(
          builder: (context) {
            // Add error reporting
            FlutterError.onError = (FlutterErrorDetails details) {
              FlutterError.presentError(details);
              debugPrint('Error: ${details.exception}');
            };
            
            _initializeApp(context);
            
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> _initializeApp(BuildContext context) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.log('Flutter binding initialized');
    
    final packageInfo = await PackageInfo.fromPlatform();
    AppLogger.log('Bundle ID: ${packageInfo.packageName}');
    AppLogger.log('App Name: ${packageInfo.appName}');
    AppLogger.log('Version: ${packageInfo.version}');

    final BluetoothManager bluetoothManager = BluetoothManager();
    AppLogger.log('BluetoothManager created');

    await bluetoothManager.initialize();
    AppLogger.log('BluetoothManager initialized');

    if (context.mounted) {
      // Replace the loading screen with the actual app
      runApp(ControllerMapperApp(bluetoothManager: bluetoothManager));
    }
    AppLogger.log('App started');
  } catch (e, stackTrace) {
    AppLogger.log('Error in initialization: $e\n$stackTrace');
    if (context.mounted) {
      // Show error screen
      runApp(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Initialization Error',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      e.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
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
          AppLogger.log('Building HomeScreen');
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
  bool showLogs = false;  // Add this

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
        actions: [
          // Add debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              setState(() {
                showLogs = !showLogs;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Your existing UI
            Padding(
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
            // Debug overlay
            if (showLogs)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  color: Colors.black.withOpacity(0.8),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: AppLogger.logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          AppLogger.logs[AppLogger.logs.length - 1 - index],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

