import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAocEbuLJNldit1u6Y4O-48XXvHcUz8B80',
    appId: '1:100335575609:android:611ad00217d1a430c9e3e8',
    messagingSenderId: '100335575609',
    projectId: 'bhagwa-prod',
    storageBucket: 'bhagwa-prod.firebasestorage.app',
  );
}
