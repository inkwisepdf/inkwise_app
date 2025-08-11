import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  static Future<void> logError(dynamic exception, StackTrace stack) async {
    await FirebaseCrashlytics.instance.recordError(exception, stack);
  }
}
