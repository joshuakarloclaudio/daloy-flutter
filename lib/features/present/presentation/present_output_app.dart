import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/present_deck.dart';
import 'present_slide_view.dart';

/// The external screen's whole app, run by a second Flutter engine
/// (`presentOutputMain` in main.dart): the slide and nothing else. The deck
/// arrives as JSON from the presenting app through the native side.
void runPresentOutput() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PresentOutputApp());
}

class PresentOutputApp extends StatefulWidget {
  const PresentOutputApp({super.key});

  @override
  State<PresentOutputApp> createState() => _PresentOutputAppState();
}

class _PresentOutputAppState extends State<PresentOutputApp> {
  static const _channel = MethodChannel('pro.daloy.app/present_output');
  PresentDeckState? _deck;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'deck') _take(call.arguments);
    });
    // The deck may have been sent before this engine was listening.
    _channel.invokeMethod<String>('ready').then(_take, onError: (_) {});
  }

  void _take(Object? json) {
    if (json is! String) return;
    final value = jsonDecode(json);
    if (value is Map && mounted) setState(() => _deck = PresentDeckState.fromJson(value.cast()));
  }

  @override
  Widget build(BuildContext context) {
    final deck = _deck;
    return WidgetsApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        return ColoredBox(
          color: Colors.black,
          child: deck == null
              ? const SizedBox.expand()
              : PresentSlideView(
                  slide: deck.current,
                  look: deck.look,
                  blanked: deck.blanked,
                  aspectRatio: size.height > 0 ? size.width / size.height : 16 / 9,
                ),
        );
      },
    );
  }
}
