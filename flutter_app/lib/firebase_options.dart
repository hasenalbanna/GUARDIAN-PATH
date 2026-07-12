import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDYTUyqCmXpCkwOf58PsQf1vIzXL7g_QKg',
    appId: '1:876564803371:web:824b30fe2b4c6de69f1f6e',
    messagingSenderId: '876564803371',
    projectId: 'guardianpath-e386b',
    authDomain: 'guardianpath-e386b.firebaseapp.com',
    storageBucket: 'guardianpath-e386b.firebasestorage.app',
    measurementId: 'G-DQ80K7FVMJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLKen3vjGipnyaxjzbBpgoMta68anU_tk',
    appId: '1:876564803371:android:e1a094a5f1bed5839f1f6e',
    messagingSenderId: '876564803371',
    projectId: 'guardianpath-e386b',
    storageBucket: 'guardianpath-e386b.firebasestorage.app',
  );
}
