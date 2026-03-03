import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
/// TODO: Replace these placeholder values with your actual Firebase project configuration.
/// Run `flutterfire configure` to generate this file automatically.
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
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvd0oAd_k9Wmx5cQ9Tkyoohl_iUWFuEZo',
    appId: '1:42034860151:web:2fbcf6843ce893b0e9b672',
    messagingSenderId: '42034860151',
    projectId: 'hostel-hub-b9e33',
    authDomain: 'hostel-hub-b9e33.firebaseapp.com',
    storageBucket: 'hostel-hub-b9e33.firebasestorage.app',
    measurementId: 'G-ESKYCQKQB0',
    databaseURL: 'https://hostel-hub-b9e33-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvd0oAd_k9Wmx5cQ9Tkyoohl_iUWFuEZo',
    appId: '1:42034860151:web:2fbcf6843ce893b0e9b672',
    messagingSenderId: '42034860151',
    projectId: 'hostel-hub-b9e33',
    storageBucket: 'hostel-hub-b9e33.firebasestorage.app',
    databaseURL: 'https://hostel-hub-b9e33-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.hostel.student.studentApp',
  );
}
