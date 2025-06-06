// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBOQA7tc-UAJRMXnwu5zhgpzPIqT2v3rv0',
    appId: '1:722903766795:web:7d1732258f77ce8805f40e',
    messagingSenderId: '722903766795',
    projectId: 'trixo-1eacc',
    authDomain: 'trixo-1eacc.firebaseapp.com',
    storageBucket: 'trixo-1eacc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-EwjvsWeDmILrVJ-Eyatgtw9Zf8rXvxI',
    appId: '1:722903766795:android:565b691c9f04890f05f40e',
    messagingSenderId: '722903766795',
    projectId: 'trixo-1eacc',
    storageBucket: 'trixo-1eacc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAm0a_2uL0Blrwlf_45zjDkTWzyQ-60cow',
    appId: '1:722903766795:ios:1d12489b3ce8c88805f40e',
    messagingSenderId: '722903766795',
    projectId: 'trixo-1eacc',
    storageBucket: 'trixo-1eacc.firebasestorage.app',
    iosBundleId: 'com.example.trixoFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAm0a_2uL0Blrwlf_45zjDkTWzyQ-60cow',
    appId: '1:722903766795:ios:1d12489b3ce8c88805f40e',
    messagingSenderId: '722903766795',
    projectId: 'trixo-1eacc',
    storageBucket: 'trixo-1eacc.firebasestorage.app',
    iosBundleId: 'com.example.trixoFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBOQA7tc-UAJRMXnwu5zhgpzPIqT2v3rv0',
    appId: '1:722903766795:web:111d2cc1d2e0abd305f40e',
    messagingSenderId: '722903766795',
    projectId: 'trixo-1eacc',
    authDomain: 'trixo-1eacc.firebaseapp.com',
    storageBucket: 'trixo-1eacc.firebasestorage.app',
  );
}
