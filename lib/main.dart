import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

void _logError(String message, dynamic error, StackTrace? stack) {
  developer.log(message, error: error, stackTrace: stack);
  print('ERROR: $message - $error');
}

void main() {
  try {
    developer.log('App starting...');
    print('App starting...');
    
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('Flutter binding initialized');
    
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError('Flutter Error', details.exception, details.stack);
      runApp(ErrorScreen(error: details.exception.toString()));
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      runApp(ErrorScreen(error: error.toString()));
      return true;
    };

    try {
      runApp(const InitialLoadingApp());
    } catch (e, stack) {
      _logError('Error in runApp', e, stack);
      runApp(ErrorScreen(error: e.toString()));
    }
  } catch (e, stack) {
    _logError('Fatal Error in main()', e, stack);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Fatal Error: $e'),
        ),
      ),
    ));
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
  const InitialLoadingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
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

