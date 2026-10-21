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

  test('formatUpdated says when, then who', () {
    expect(formatUpdated(now.subtract(const Duration(seconds: 20)), now: now), 'Updated just now');
    expect(formatUpdated(now.subtract(const Duration(minutes: 1)), by: 'Ana', now: now), 'Updated 1 minute ago by Ana');
    expect(
      formatUpdated(now.subtract(const Duration(minutes: 42)), by: 'Ana', now: now),
      'Updated 42 minutes ago by Ana',
    );
    expect(
      formatUpdated(now.subtract(const Duration(hours: 3)), by: 'Ana', isMe: true, now: now),
      'Updated 3 hours ago by you',
    );
    // 9am today, 10pm yesterday: a different day, though under 24 hours.
    expect(formatUpdated(DateTime(2026, 10, 14, 22), now: now), 'Updated yesterday');
    expect(formatUpdated(DateTime(2026, 10, 11, 12), by: ' ', now: now), 'Updated 4 days ago');
    expect(formatUpdated(DateTime(2026, 10, 3, 12), by: 'Ana', now: now), 'Updated on Oct 3 by Ana');
    expect(formatUpdated(DateTime(2025, 12, 24, 12), now: now), 'Updated on Dec 24, 2025');
  });

  test('formatRole', () {
    expect(formatRole('superadmin'), 'Platform admin');
    expect(formatRole('ADMIN'), 'Admin');
    expect(formatRole(''), 'Member');
  });
}
