import 'dart:async';

import 'package:daloy_flutter/core/router/app_router.dart';
import 'package:daloy_flutter/core/router/routes.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/presentation/forgot_password_screen.dart';
import 'package:daloy_flutter/features/auth/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  testWidgets('screens are platform pages: iOS edge swipe goes back', (tester) async {
    final container = await createTestContainer(FakeApiAdapter({}));
    await container.read(sessionControllerProvider.future);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: DaloyTheme.light(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);

    unawaited(router.push(Routes.forgotPassword));
    await tester.pumpAndSettle();
    final route = ModalRoute.of(tester.element(find.byType(ForgotPasswordScreen)))!;
    // go_router's own fallback is a NoTransitionPage — no slide, no swipe.
    expect(route, isA<MaterialRouteTransitionMixin<void>>());

    final drag = await tester.startGesture(const Offset(5, 300));
    for (var i = 0; i < 20; i++) {
      await drag.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await drag.up();
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsNothing);
    expect(find.byType(SignInScreen), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
