import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        throw UnsupportedError('NyumbaHub not supported for this platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxNyEoJB5fW_K0Z0H0Q0Q0Q0Q0Q0Q0Q0Q',
    appId: '1:123456789:web:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'nyumba-hub-tanzania',
    authDomain: 'nyumba-hub-tanzania.firebaseapp.com',
    storageBucket: 'nyumba-hub-tanzania.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxNyEoJB5fW_K0Z0H0Q0Q0Q0Q0Q0Q0Q0Q',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'nyumba-hub-tanzania',
    storageBucket: 'nyumba-hub-tanzania.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxNyEoJB5fW_K0Z0H0Q0Q0Q0Q0Q0Q0Q0Q',
    appId: '1:123456789:ios:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'nyumba-hub-tanzania',
    storageBucket: 'nyumba-hub-tanzania.appspot.com',
  );
}
