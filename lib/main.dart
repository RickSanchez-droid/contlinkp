import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized'); // Debug print
    
    runApp(const MyApp());
  }, (error, stack) {
    print('Error: $error');
    print('Stack trace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Hello World',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

