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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD97y34Sdmk1GzpIx0DRtLtW27mhRzLHdc',
    appId: '1:599994651302:web:5a3b740ecff4188b58da67',
    messagingSenderId: '599994651302',
    projectId: 'chira-966cf',
    authDomain: 'chira-966cf.firebaseapp.com',
    storageBucket: 'chira-966cf.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDd2N6cP6JmVx63QsiMjEQtFlZ-Pk4cLWE',
    appId: '1:599994651302:android:f443a00b212a61bd58da67',
    messagingSenderId: '599994651302',
    projectId: 'chira-966cf',
    storageBucket: 'chira-966cf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjyZ5XnIRlwifkOXb4AZP_wLUJWP9ZC8A',
    appId: '1:599994651302:ios:53f9de33cf30b7fe58da67',
    messagingSenderId: '599994651302',
    projectId: 'chira-966cf',
    storageBucket: 'chira-966cf.firebasestorage.app',
    iosBundleId: 'com.example.chira',
  );
}
