import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
            'FirebaseOptions have not been configured for iOS.');
      case TargetPlatform.macOS:
        throw UnsupportedError(
            'FirebaseOptions have not been configured for macOS.');
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
            'FirebaseOptions have not been configured for Linux.');
      default:
        throw UnsupportedError(
            'FirebaseOptions are not supported for this platform.');
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['API_KEY'] ?? '',
        appId: dotenv.env['APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        authDomain: dotenv.env['AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['API_KEY'] ?? '',
        appId: dotenv.env['APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: dotenv.env['API_KEY'] ?? '',
        appId: dotenv.env['APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        authDomain: dotenv.env['AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );
}
