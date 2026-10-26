import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

extension TargetPlatformIdiom on TargetPlatform {
  /// iOS and macOS: Apple's idioms (no ink splash, chevron back, centred
  /// titles) rather than Material's.
  bool get isApple => this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}

/// The Mac build: a pointer-first desktop app, not a touch device.
bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// Windows 11 22H2 (build 22621) and later: the runner asks the compositor
/// for an acrylic window, so the sidebar can be see-through at no per-frame
/// cost. Earlier builds keep solid fills.
final bool hasAcrylic = isWindows && _windowsBuild >= 22621;

int get _windowsBuild {
  final version = Platform.operatingSystemVersion;
  final match = RegExp(r'Build (\d+)').firstMatch(version) ?? RegExp(r'10\.0\.(\d+)').firstMatch(version);
  return int.tryParse(match?.group(1) ?? '') ?? 0;
}

/// The Mac or Windows: a window with a pointer and a keyboard. The desktop
/// shell, pointer-sized controls, no camera to scan with.
bool get isDesktop => isMacOS || isWindows;

/// The YouTube player runs in a WebView, and `webview_flutter` has no
/// Windows side: there, YouTube links open in the browser instead.
bool get hasInAppPlayer => !isWindows;

/// The modifier the desktop's shortcuts use, for showing them: ⌘ on the Mac,
/// Ctrl+ on Windows.
String get shortcutModifier => isMacOS ? '⌘' : 'Ctrl+';
