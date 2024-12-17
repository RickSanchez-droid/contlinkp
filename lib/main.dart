import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

void main() {
  // Catch all errors, including platform errors
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      developer.log('Flutter Error: ${details.exception}', error: details);
      // Force show error screen
      runApp(ErrorScreen(error: details.exception.toString()));
    };

    // Catch platform errors
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      developer.log('Platform Error', error: error, stackTrace: stack);
      // Force show error screen
      runApp(ErrorScreen(error: error.toString()));
      return true;
    };

    runApp(const InitialLoadingApp());
  } catch (e, stack) {
    developer.log('Error in main()', error: e, stackTrace: stack);
    runApp(ErrorScreen(error: e.toString()));
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'An error occurred',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.red,
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

class InitialLoadingApp extends StatelessWidget {
  const InitialLoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _status = 'Starting...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      developer.log('Starting app initialization');
      
      setState(() => _status = 'Initializing Flutter binding...');
      await Future.delayed(const Duration(milliseconds: 100)); // Shorter delay
      
      developer.log('Flutter binding initialized');
      setState(() => _status = 'Setting up services...');
      
      // Add any other initialization here...
      
      developer.log('App initialization complete');
      
    } catch (e, stack) {
      developer.log('Error during initialization', error: e, stackTrace: stack);
      setState(() {
        _status = 'Error: $e';
        _hasError = true;
      });
      // Re-throw to trigger error screen
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_hasError)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  )
                else
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                const SizedBox(height: 24),
                Text(
                  _status,
                  style: TextStyle(
                    color: _hasError ? Colors.red : Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

