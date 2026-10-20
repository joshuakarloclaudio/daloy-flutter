import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/present_deck.dart';

part 'present_display.g.dart';

/// A second screen the slides can go to: HDMI or AirPlay on iOS
/// (`PresentDisplay` in AppDelegate.swift), USB-C/HDMI or Miracast on
/// Android (`PresentDisplay.kt`), any screen but the window's on macOS
/// (`macos/Runner/PresentDisplay.swift`).
@immutable
class ExternalDisplay {
  const ExternalDisplay({required this.name, required this.width, required this.height, this.id});

  /// The Mac's display id, for [PresentDisplayChannel.select]; null where
  /// there's only ever one external screen.
  final int? id;
  final String name;
  final double width;
  final double height;

  double get aspectRatio => width > 0 && height > 0 ? width / height : 16 / 9;

  static ExternalDisplay? fromMap(Object? value) {
    if (value is! Map) return null;
    return ExternalDisplay(
      id: (value['id'] as num?)?.toInt(),
      name: value['name'] as String? ?? 'External display',
      width: (value['width'] as num?)?.toDouble() ?? 0,
      height: (value['height'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExternalDisplay &&
      other.id == id &&
      other.name == name &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(id, name, width, height);
}

/// The projector side of Present on the native side. While [show]n, a
/// second Flutter engine draws [PresentDeckState]s on the external screen
/// (`presentOutputMain`); [update] sends each change. Where there's no
/// native side (tests), there is never a display.
class PresentDisplayChannel {
  PresentDisplayChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('pro.daloy.app/present_display') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'displayChanged') _changes.add(ExternalDisplay.fromMap(call.arguments));
    });
  }

  final MethodChannel _channel;
  final _changes = StreamController<ExternalDisplay?>.broadcast();

  Stream<ExternalDisplay?> get changes => _changes.stream;

  Future<ExternalDisplay?> current() async {
    try {
      return ExternalDisplay.fromMap(await _channel.invokeMethod<Object?>('getDisplay'));
    } on MissingPluginException {
      return null;
    }
  }

  /// Every screen the slides could go to, and which one they go to
  /// ([selected]). More than one only on the Mac.
  Future<List<({ExternalDisplay display, bool selected})>> all() async {
    try {
      final list = await _channel.invokeMethod<List<Object?>>('getDisplays') ?? const [];
      return [
        for (final value in list)
          if (ExternalDisplay.fromMap(value) case final display?)
            (display: display, selected: (value as Map)['selected'] == true),
      ];
    } on MissingPluginException {
      final display = await current();
      return [if (display != null) (display: display, selected: true)];
    }
  }

  /// Sends the slides to [display] instead; [changes] follows.
  Future<void> select(ExternalDisplay display) => _call('select', display.id);

  /// Puts the slides on the external screen; false when there isn't one.
  Future<bool> show(PresentDeckState deck) async {
    try {
      return await _channel.invokeMethod<bool>('show', jsonEncode(deck.toJson())) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> update(PresentDeckState deck) => _call('update', jsonEncode(deck.toJson()));

  /// Takes the slides off; the system goes back to mirroring.
  Future<void> hide() => _call('hide');

  Future<void> _call(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // No native side.
    }
  }
}

@Riverpod(keepAlive: true)
PresentDisplayChannel presentDisplayChannel(Ref ref) => PresentDisplayChannel();

/// The external screen, if one is connected — follows plugging in and out.
@riverpod
Stream<ExternalDisplay?> externalDisplay(Ref ref) async* {
  final channel = ref.watch(presentDisplayChannelProvider);
  yield await channel.current();
  yield* channel.changes;
}
