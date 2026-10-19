import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/line_ups/domain/live_session.dart';
import 'package:daloy_flutter/shell/live_session_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Live extends ActiveLiveSession {
  @override
  Future<LiveSession?> build() async => LiveSession(
    id: 1,
    lineUpId: 7,
    participantCount: 3,
    startedByUserId: 1,
    startedByUserName: 'Ana',
    startedAt: DateTime(2026, 1, 1),
  );
}

Future<void> _pump(WidgetTester tester, {bool hidden = false, bool online = true}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        isOnlineProvider.overrideWithValue(online),
        activeLiveSessionProvider.overrideWith(_Live.new),
        workspaceLineUpsProvider.overrideWith((ref) => Stream.value(const <LineUp>[])),
      ],
      child: MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: LiveSessionBar(hidden: hidden),
          ),
        ),
      ),
    ),
  );
  // The pulse dot animates forever, so settle by time rather than pumpAndSettle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('shows the live performance with a Join action', (tester) async {
    await _pump(tester);
    expect(find.text('LIVE NOW · 3 PEOPLE'), findsOneWidget);
    expect(find.text('Live performance'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });

  testWidgets('is absent when hidden (Home) or offline', (tester) async {
    await _pump(tester, hidden: true);
    expect(find.text('Join'), findsNothing);
    await _pump(tester, online: false);
    expect(find.text('Join'), findsNothing);
  });
}
