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
    apiKey: 'AIzaSyBJIiryJHOoOZgCMJTG6AF5AobH0DsVquo',
    appId: '1:746085633002:web:6b30ac9f77a3e02fd20093',
    messagingSenderId: '746085633002',
    projectId: 'fuocherello-a4c5c',
    authDomain: 'fuocherello-a4c5c.firebaseapp.com',
    storageBucket: 'fuocherello-a4c5c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkU7iX8hTvhOfzIRVooBsLh8w3HrC9SnU',
    appId: '1:746085633002:android:287511f9390084e7d20093',
    messagingSenderId: '746085633002',
    projectId: 'fuocherello-a4c5c',
    storageBucket: 'fuocherello-a4c5c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOyagxdK3eyvKooPTywpZFR7Q1YelusHU',
    appId: '1:746085633002:ios:fdf42bdf70751790d20093',
    messagingSenderId: '746085633002',
    projectId: 'fuocherello-a4c5c',
    storageBucket: 'fuocherello-a4c5c.appspot.com',
    androidClientId: '746085633002-boju5ivnpdrg87bu1rcsttrl49t842hn.apps.googleusercontent.com',
    iosClientId: '746085633002-8ekj8guism6i2p2uokv8epp35mo1rv0g.apps.googleusercontent.com',
    iosBundleId: 'com.diodorogroup.fuocherello',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBOyagxdK3eyvKooPTywpZFR7Q1YelusHU',
    appId: '1:746085633002:ios:fdf42bdf70751790d20093',
    messagingSenderId: '746085633002',
    projectId: 'fuocherello-a4c5c',
    storageBucket: 'fuocherello-a4c5c.appspot.com',
    androidClientId: '746085633002-boju5ivnpdrg87bu1rcsttrl49t842hn.apps.googleusercontent.com',
    iosClientId: '746085633002-8ekj8guism6i2p2uokv8epp35mo1rv0g.apps.googleusercontent.com',
    iosBundleId: 'com.diodorogroup.fuocherello',
  );
}
