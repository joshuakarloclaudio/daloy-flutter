import 'package:flutter/foundation.dart';

extension TargetPlatformIdiom on TargetPlatform {
  /// iOS and macOS: Apple's idioms (no ink splash, chevron back, centred
  /// titles) rather than Material's.
  bool get isApple => this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}

/// The Mac build: a pointer-first desktop app, not a touch device.
bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// The Mac or Windows: a window with a pointer and a keyboard. The desktop
/// shell, pointer-sized controls, no camera to scan with.
bool get isDesktop => isMacOS || isWindows;

/// The YouTube player runs in a WebView, and `webview_flutter` has no
/// Windows side: there, YouTube links open in the browser instead.
bool get hasInAppPlayer => !isWindows;

/// The modifier the desktop's shortcuts use, for showing them: ⌘ on the Mac,
/// Ctrl+ on Windows.
String get shortcutModifier => isMacOS ? '⌘' : 'Ctrl+';
