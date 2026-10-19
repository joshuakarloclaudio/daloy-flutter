import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One song or line-up as the OS sees it.
@immutable
class OsSearchItem {
  const OsSearchItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.path,
    this.subtitle,
    this.description,
    this.keywords = const [],
  });

  /// `song:12` / `lineup:7` — stable, so a re-index replaces rather than adds.
  final String id;

  /// `song` / `lineup`: the Spotlight domain, the Android shortcut's icon.
  final String kind;
  final String title;

  /// The in-app location opened when it's picked, e.g. `/songs/12`.
  final String path;
  final String? subtitle;

  /// Extra searchable text — a song's opening line.
  final String? description;
  final List<String> keywords;

  Map<String, Object?> toMap() => {
    'id': id,
    'kind': kind,
    'title': title,
    'path': path,
    'subtitle': subtitle,
    'description': description,
    'keywords': keywords,
  };
}

/// The app's songs and line-ups in the OS's own search: Core Spotlight on
/// iOS/iPadOS, dynamic shortcuts on Android (long-press the icon, or the
/// launcher's search). Written natively in `ios/Runner` and `MainActivity`;
/// on other platforms, and in tests, every call is a quiet no-op.
class OsSearchIndex {
  OsSearchIndex([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('pro.daloy.app/search_index');

  static final instance = OsSearchIndex();

  final MethodChannel _channel;
  final _opens = StreamController<String>.broadcast();

  bool _listening = false;

  /// In-app paths the OS asked to open while the app was running.
  Stream<String> get opens {
    _listen();
    return _opens.stream;
  }

  /// Registered on first use rather than at construction, so merely making
  /// one (a provider in a plain Dart test) needs no Flutter binding.
  void _listen() {
    if (_listening || kIsWeb || !_hasBinding) return;
    _listening = true;
    _channel.setMethodCallHandler(_onCall);
  }

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'open' && call.arguments is String) _opens.add(call.arguments as String);
    return null;
  }

  /// The path the app was launched to open (a Spotlight hit or shortcut
  /// tapped while it wasn't running), handed over once.
  Future<String?> takeLaunchPath() => _call<String>('takeLaunchPath');

  /// Makes the OS index exactly [items] — everything else from this app goes.
  Future<void> replaceAll(List<OsSearchItem> items) => _call<void>('replaceAll', {
    'items': [for (final i in items) i.toMap()],
  });

  /// Android's launcher shortcuts, most important first. The OS shows as many
  /// as it allows (usually four); iOS ignores this.
  Future<void> setShortcuts(List<OsSearchItem> items) => _call<void>('setShortcuts', {
    'items': [for (final i in items) i.toMap()],
  });

  /// Signing out: nothing of this account stays findable.
  Future<void> clear() => _call<void>('clear');

  Future<T?> _call<T>(String method, [Object? args]) async {
    if (kIsWeb || !_hasBinding) return null;
    try {
      _listen();
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Daloy: OS search index $method failed: ${e.message}');
      return null;
    }
  }

  /// False in a plain Dart test, where there's no platform to talk to.
  static bool get _hasBinding {
    try {
      ServicesBinding.instance;
      return true;
    } on Object {
      return false;
    }
  }
}
