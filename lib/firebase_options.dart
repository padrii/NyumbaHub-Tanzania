import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => kIsWeb ? web : android;
  static const web = FirebaseOptions(apiKey: 'REPLACE_WITH_FIREBASE_API_KEY', appId: 'REPLACE_WITH_FIREBASE_APP_ID', messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID', projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID', storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET');
  static const android = web;
}
