import 'package:daloy_flutter/core/router/incoming_link.dart';
import 'package:daloy_flutter/core/router/routes.dart';
import 'package:daloy_flutter/features/team/presentation/join_scanner_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

const _token = 'AbCdEf0123456789AbCdEf0123456789AbCdEf01';

void main() {
  group('routeForIncomingLink', () {
    test('app paths from Spotlight and shortcuts pass through, nothing else does', () {
      expect(routeForIncomingLink('/songs/12'), '/songs/12');
      expect(routeForIncomingLink('/line-ups/7'), '/line-ups/7');
      expect(routeForIncomingLink('/team'), isNull);
      expect(routeForIncomingLink('/songs/12/edit'), isNull);
    });

    test('the widget\'s "Plan a line-up" opens the new-line-up sheet', () {
      expect(routeForIncomingLink(Routes.newLineUp), '/line-ups?new=1');
      expect(routeForIncomingLink('daloy://open/line-ups?new=1'), Routes.newLineUp);
      expect(routeForIncomingLink('daloy://open/line-ups/7'), '/line-ups/7');
      expect(routeForIncomingLink('/line-ups?new=2'), isNull);
    });

    test('a join link on the site opens the join screen', () {
      expect(routeForIncomingLink('https://daloy.pro/share/j/$_token'), '/join/$_token');
      expect(routeForIncomingLink('https://www.daloy.pro/share/j/$_token'), '/join/$_token');
    });

    test('an invitation email link opens the invitation screen', () {
      expect(routeForIncomingLink('https://daloy.pro/auth/register?invite=$_token'), '/invite/$_token');
      expect(routeForIncomingLink('https://daloy.pro/auth/register'), isNull);
    });

    test('a reset email link opens reset-password with its token and email', () {
      final route = routeForIncomingLink('https://daloy.pro/auth/reset-password?token=abc123&email=ana%40example.com');
      final uri = Uri.parse(route!);
      expect(uri.path, '/reset-password');
      expect(uri.queryParameters, {'token': 'abc123', 'email': 'ana@example.com'});
      expect(routeForIncomingLink('https://daloy.pro/auth/reset-password?token=abc123'), isNull);
    });

    test('other hosts and other paths are not ours', () {
      expect(routeForIncomingLink('https://evil.example/share/j/$_token'), isNull);
      expect(routeForIncomingLink('https://daloy.pro/share/l/$_token'), isNull);
      expect(routeForIncomingLink('https://daloy.pro/app/songs'), isNull);
      expect(routeForIncomingLink('https://daloy.pro/share/j/short'), isNull);
      expect(routeForIncomingLink('not a link at all'), isNull);
    });

    test('android shortcuts arrive as daloy://open paths', () {
      expect(routeForIncomingLink('daloy://open/songs/12'), '/songs/12');
      expect(routeForIncomingLink('daloy://open/anything-else'), isNull);
    });
  });

  group('joinRouteFor (scanner and paste)', () {
    test('accepts join and invitation links, with stray whitespace', () {
      expect(joinRouteFor('  https://daloy.pro/share/j/$_token\n'), Routes.join(_token));
      expect(joinRouteFor('https://daloy.pro/auth/register?invite=$_token'), Routes.invite(_token));
    });

    test('rejects anything else, including links that are ours but not for joining', () {
      expect(joinRouteFor('https://example.com'), isNull);
      expect(joinRouteFor('/songs/12'), isNull);
      expect(joinRouteFor('https://daloy.pro/auth/reset-password?token=abc123&email=a%40b.co'), isNull);
    });
  });
}
