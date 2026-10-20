import 'package:flutter/foundation.dart';

extension TargetPlatformIdiom on TargetPlatform {
  /// iOS and macOS: Apple's idioms (no ink splash, chevron back, centred
  /// titles) rather than Material's.
  bool get isApple => this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}

/// The Mac build: a pointer-first desktop app, not a touch device.
bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
