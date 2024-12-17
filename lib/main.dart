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

void main() {
  try {
    developer.log('Starting app initialization');
    
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('Flutter bindings initialized');
    
    // Run the app inside error zone
    runZonedGuarded(() {
      runApp(const MyApp());
      developer.log('App started successfully');
    }, (error, stack) {
      developer.log('Error during app execution',
          error: error, stackTrace: stack);
    });
  } catch (e, stack) {
    developer.log('Fatal error during initialization',
        error: e, stackTrace: stack);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue, // Changed to make any rendering obvious
        body: Center(
          child: Text(
            'Hello World',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}

