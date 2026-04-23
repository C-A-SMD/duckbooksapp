// Generated-like Firebase options for this project.
// Keeps Flutter Web working without FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZJeY6K8zz08t9SuvDh_5e5wJ7eQESDC8',
    authDomain: 'duckbooksapp.firebaseapp.com',
    projectId: 'duckbooksapp',
    storageBucket: 'duckbooksapp.firebasestorage.app',
    messagingSenderId: '44932513238',
    appId: '1:44932513238:web:09b863e257f7cc676af877',
    measurementId: 'G-8ZQFEZLLK6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBunLFEnPOlPTK6KDetcE4_o7BsNvD6Yc',
    appId: '1:44932513238:android:f66fe0d77f298ffc6af877',
    messagingSenderId: '44932513238',
    projectId: 'duckbooksapp',
    storageBucket: 'duckbooksapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxrkTtACk_m9_AfGa4NoianKXV1phzp84',
    appId: '1:44932513238:ios:93614c72d3fa9f966af877',
    messagingSenderId: '44932513238',
    projectId: 'duckbooksapp',
    storageBucket: 'duckbooksapp.firebasestorage.app',
    iosBundleId: 'br.casmd.duckbooks',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}
