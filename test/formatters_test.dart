import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 15, 9);

  test('greeting follows the hour', () {
    expect(greeting(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(greeting(DateTime(2026, 1, 1, 13)), 'Good afternoon');
    expect(greeting(DateTime(2026, 1, 1, 20)), 'Good evening');
  });

  test('lineUpDayChip marks today and tomorrow only', () {
    expect(lineUpDayChip('2026-10-15', now), DayChip.today);
    expect(lineUpDayChip('2026-10-16', now), DayChip.tomorrow);
    expect(lineUpDayChip('2026-10-17', now), isNull);
  });

  test('workspaceInitials', () {
    expect(workspaceInitials('Grace Community Church'), 'GC');
    expect(workspaceInitials('riverside'), 'RI');
    expect(workspaceInitials('  '), '?');
  });

  test('labels pluralise', () {
    expect(lineUpSongsLabel(1), '1 song');
    expect(lineUpSongsLabel(3), '3 songs');
    expect(firstName('Joshua Claudio'), 'Joshua');
  });

  test('formatRole', () {
    expect(formatRole('superadmin'), 'Platform admin');
    expect(formatRole('ADMIN'), 'Admin');
    expect(formatRole(''), 'Member');
  });
}
