/* GitHub Actions Workflow Steps:
 * 1. cd ios
 * 2. rm -rf Pods
 * 3. rm -rf .symlinks
 * 4. rm Podfile.lock
 * 5. pod deintegrate
 * 6. pod setup
 * 7. pod install
 * 
 * Add to .github/workflows/main.yml:
 * 
 * - name: Clean iOS build
 *   working-directory: ios
 *   run: |
 *     rm -rf Pods
 *     rm -rf .symlinks
 *     rm -f Podfile.lock
 *     
 * - name: Install CocoaPods
 *   run: |
 *     sudo gem install cocoapods
 *     
 * - name: Pod Setup and Install
 *   working-directory: ios
 *   run: |
 *     pod deintegrate
 *     pod setup
 *     pod install
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

void main() async {
  // Set error handlers as early as possible
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.toString()}');
  };

  try {
    debugPrint("Starting app initialization");
    
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("Flutter bindings initialized");

    // Run the app inside error zone
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
          debugPrint("Building Scaffold");
          return const Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
              child: Text(
                'Hello World',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

