import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Firebase 초기화 서비스
class FirebaseService {
  static bool _initialized = false;

  /// Firebase 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// 초기화 여부 확인
  static bool get isInitialized => _initialized;
}


