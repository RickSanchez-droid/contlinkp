import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

void main() async {
  try {
    debugPrint("Starting app initialization");

    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("Flutter bindings initialized");

    runZonedGuarded(() {
      debugPrint("About to call runApp");
      runApp(const MyApp());
      debugPrint("App started successfully");
    }, (error, stack) {
      debugPrint('Error from runZonedGuarded: $error');
      debugPrint(stack.toString());
    });
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint(stack.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building MyApp widget");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        platform: TargetPlatform.iOS,
      ),
      home: Builder(
        builder: (context) {
          debugPrint("Building home widget");
          return Container(
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Hello World',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
          );
        },
      ),
    );
  }
}
