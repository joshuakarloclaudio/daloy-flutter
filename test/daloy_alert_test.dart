import 'dart:async';
import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('pro.daloy.app/alert');

late BuildContext _context;

Future<void> _pump(WidgetTester tester, {ThemeData? theme}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? DaloyTheme.light(),
    home: Builder(
      builder: (context) {
        _context = context;
        return const Scaffold(body: SizedBox.expand());
      },
    ),
  ),
);

/// The platform override has to be cleared before the test body ends: the
/// binding checks it before any tearDown runs.
void iosTest(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
  });

  group('drawn in Flutter (Android, tests)', () {
    testWidgets('two actions sit side by side and the tap returns its value', (tester) async {
      await _pump(tester);
      final result = showDaloyAlert<String>(
        _context,
        title: 'Discard changes?',
        message: "Your edits haven't been saved.",
        actions: const [
          DaloyAlertAction('Keep editing', 'keep', style: DaloyAlertStyle.cancel),
          DaloyAlertAction('Discard', 'discard', style: DaloyAlertStyle.destructive),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text("Your edits haven't been saved."), findsOneWidget);
      expect(tester.getCenter(find.text('Keep editing')).dy, tester.getCenter(find.text('Discard')).dy);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(await result, 'discard');
      expect(find.text('Discard changes?'), findsNothing);
    });

    testWidgets('three actions stack', (tester) async {
      await _pump(tester);
      unawaited(
        showDaloyAlert<int>(
          _context,
          title: 'Pick',
          actions: const [DaloyAlertAction('A', 1), DaloyAlertAction('B', 2), DaloyAlertAction('C', 3)],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('A')).dy, lessThan(tester.getCenter(find.text('B')).dy));
      expect(tester.getCenter(find.text('B')).dy, lessThan(tester.getCenter(find.text('C')).dy));
    });

    testWidgets('only a dismissible alert closes on a tap outside', (tester) async {
      await _pump(tester);
      var done = false;
      unawaited(
        showDaloyAlert<int>(
          _context,
          title: 'Stay',
          actions: const [DaloyAlertAction('OK', 1)],
        ).then((_) => done = true),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(done, isFalse);

      Navigator.of(_context).pop();
      await tester.pumpAndSettle();
      var result = 0;
      unawaited(
        showDaloyAlert<int>(
          _context,
          title: 'Go',
          dismissible: true,
          actions: const [DaloyAlertAction('OK', 1)],
        ).then((v) => result = v ?? -1),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, -1);
    });

    testWidgets('confirmAlert and confirmDestructive are true only for the confirm', (tester) async {
      await _pump(tester, theme: DaloyTheme.dark());
      var r = confirmAlert(_context, title: 'Go live?', confirmLabel: 'Go live', cancelLabel: 'Not yet');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not yet'));
      await tester.pumpAndSettle();
      expect(await r, isFalse);

      r = confirmDestructive(_context, title: 'Remove?', confirmLabel: 'Remove');
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('Cancel')).dx, lessThan(tester.getCenter(find.text('Remove')).dx));
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(await r, isTrue);
    });

    testWidgets('custom content is shown under the title', (tester) async {
      await _pump(tester);
      unawaited(
        showDaloyAlert<int>(
          _context,
          title: 'Chart',
          content: const Text('1 4 5'),
          actions: const [DaloyAlertAction('OK', 1)],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 4 5'), findsOneWidget);
    });
  });

  group('native (iOS)', () {
    iosTest('an alert goes to UIKit and the chosen index maps to its value', (tester) async {
      Map<Object?, Object?>? sent;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
        call,
      ) async {
        sent = call.arguments as Map<Object?, Object?>;
        return 1;
      });
      await _pump(tester);
      final result = await tester.runAsync(
        () => showDaloyAlert<String>(
          _context,
          title: 'Discard changes?',
          message: 'Sure?',
          actions: const [
            DaloyAlertAction('Keep editing', 'keep', style: DaloyAlertStyle.cancel),
            DaloyAlertAction('Discard', 'discard', style: DaloyAlertStyle.destructive),
          ],
        ),
      );
      expect(result, 'discard');
      expect(sent!['style'], 'alert');
      expect(sent!['title'], 'Discard changes?');
      expect((sent!['actions']! as List).map((a) => (a as Map)['style']), ['cancel', 'destructive']);
      expect(find.text('Discard changes?'), findsNothing, reason: 'nothing drawn in Flutter');
    });

    iosTest('confirmDestructive is an action sheet; dismissing is false', (tester) async {
      Map<Object?, Object?>? sent;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
        call,
      ) async {
        sent = call.arguments as Map<Object?, Object?>;
        return null;
      });
      await _pump(tester);
      final confirmed = await tester.runAsync(
        () => confirmDestructive(_context, title: 'Delete?', confirmLabel: 'Delete'),
      );
      expect(confirmed, isFalse);
      expect(sent!['style'], 'actionSheet');
    });

    iosTest('custom content or a Perform wrap stays in Flutter', (tester) async {
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (
        call,
      ) async {
        calls++;
        return 0;
      });
      await _pump(tester);
      unawaited(
        showDaloyAlert<int>(
          _context,
          title: 'Chart',
          content: const Text('1 4 5'),
          actions: const [DaloyAlertAction('OK', 1)],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 4 5'), findsOneWidget);
      expect(calls, 0);
    });

    iosTest('without the plugin it falls back to the Flutter alert', (tester) async {
      await _pump(tester);
      unawaited(showDaloyAlert<int>(_context, title: 'Hi', actions: const [DaloyAlertAction('OK', 1)]));
      // The missing-plugin reply comes back through the real event loop.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsOneWidget);
    });
  });

  test('no Material dialogs left in the app', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains(RegExp(r'\bAlertDialog\b|\bshowDialog\b'))) offenders.add(file.path);
    }
    expect(offenders, isEmpty, reason: 'Use showDaloyAlert / confirmAlert / confirmDestructive');
  });
}
