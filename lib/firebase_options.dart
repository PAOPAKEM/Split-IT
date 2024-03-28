// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJIKWUd00VuujLgere0hKw8Z2ulKQ8jns',
    appId: '1:537913486938:web:0b2f98577ff52dd2cfb263',
    messagingSenderId: '537913486938',
    projectId: 'split-it-8d423',
    authDomain: 'split-it-8d423.firebaseapp.com',
    storageBucket: 'split-it-8d423.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDctebCXfEqI-FEc6MBi3aRk_B3xlXmDII',
    appId: '1:537913486938:android:39b580939d0fd08dcfb263',
    messagingSenderId: '537913486938',
    projectId: 'split-it-8d423',
    storageBucket: 'split-it-8d423.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzjnH8afOwvhAI2uesnO7Q7UF2kDrDZYI',
    appId: '1:537913486938:ios:a522fdc0c2ee821bcfb263',
    messagingSenderId: '537913486938',
    projectId: 'split-it-8d423',
    storageBucket: 'split-it-8d423.appspot.com',
    iosBundleId: 'com.example.splitIt',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAzjnH8afOwvhAI2uesnO7Q7UF2kDrDZYI',
    appId: '1:537913486938:ios:53c10c2ff837e267cfb263',
    messagingSenderId: '537913486938',
    projectId: 'split-it-8d423',
    storageBucket: 'split-it-8d423.appspot.com',
    iosBundleId: 'com.example.splitIt.RunnerTests',
  );
}
