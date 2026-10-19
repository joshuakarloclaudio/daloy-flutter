import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/present_deck.dart';

part 'present_display.g.dart';

/// A second screen the slides can go to: HDMI or AirPlay on iOS
/// (`PresentDisplay` in AppDelegate.swift), USB-C/HDMI or Miracast on
/// Android (`PresentDisplay.kt`).
@immutable
class ExternalDisplay {
  const ExternalDisplay({required this.name, required this.width, required this.height});

  final String name;
  final double width;
  final double height;

  double get aspectRatio => width > 0 && height > 0 ? width / height : 16 / 9;

  static ExternalDisplay? fromMap(Object? value) {
    if (value is! Map) return null;
    return ExternalDisplay(
      name: value['name'] as String? ?? 'External display',
      width: (value['width'] as num?)?.toDouble() ?? 0,
      height: (value['height'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExternalDisplay && other.name == name && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(name, width, height);
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
