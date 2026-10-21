import 'package:intl/intl.dart';

/// Pure helpers shared across features — the twin of `lib/utils.ts`.

String isoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String todayIsoLocal() => isoDate(DateTime.now());

String firstName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.isEmpty ? name : parts.first;
}

String greeting([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// "Oct 15, 2026" in the device locale. Parsed at noon so no timezone can
/// push the calendar day.
String formatLineUpDate(String isoDate) => DateFormat.yMMMd().format(DateTime.parse('${isoDate}T12:00:00'));

enum DayChip { today, tomorrow }

DayChip? lineUpDayChip(String isoDateValue, [DateTime? now]) {
  final base = now ?? DateTime.now();
  if (isoDateValue == isoDate(base)) return DayChip.today;
  if (isoDateValue == isoDate(base.add(const Duration(days: 1)))) return DayChip.tomorrow;
  return null;
}

String lineUpSongsLabel(int count) => count == 1 ? '1 song' : '$count songs';

String peopleLabel(int count) => count == 1 ? '1 person' : '$count people';

String changesLabel(int count) => count == 1 ? '1 change' : '$count changes';

/// A size on disk in the unit that keeps it short: `(value: '4.2', unit: 'MB')`.
({String value, String unit}) bytesParts(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var i = 0;
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return (value: i == 0 || size >= 100 ? size.round().toString() : size.toStringAsFixed(1), unit: units[i]);
}

/// "4.2 MB".
String formatBytes(int bytes) {
  final (:value, :unit) = bytesParts(bytes);
  return '$value $unit';
}

String workspaceInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts[0][0];
  final second = parts.length >= 2 ? parts[1][0] : (parts[0].length > 1 ? parts[0][1] : '');
  return (first + second).toUpperCase();
}

/// A workspace role for display (web: `formatRole`).
String formatRole(String role) {
  if (role.isEmpty) return 'Member';
  final lower = role.toLowerCase();
  if (lower == 'superadmin') return 'Platform admin';
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}

String formatTimeAgo(DateTime? time, [DateTime? now]) {
  if (time == null) return '';
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// "Updated 5 minutes ago by Ana" — when a song or line-up last changed,
/// and who did it ("you" when [isMe]). Past a week, the date instead.
String formatUpdated(DateTime at, {String? by, bool isMe = false, DateTime? now}) {
  final local = at.toLocal();
  final base = now ?? DateTime.now();
  final diff = base.difference(local);
  // Calendar days apart; rounded, since a DST change makes one 23 or 25 hours.
  final days =
      (DateTime(base.year, base.month, base.day).difference(DateTime(local.year, local.month, local.day)).inHours / 24)
          .round();
  String ago(int n, String unit) => n == 1 ? '1 $unit ago' : '$n ${unit}s ago';

  final String label;
  if (diff.inMinutes < 1) {
    label = 'Updated just now';
  } else if (diff.inHours < 1) {
    label = 'Updated ${ago(diff.inMinutes, 'minute')}';
  } else if (days == 0) {
    label = 'Updated ${ago(diff.inHours, 'hour')}';
  } else if (days == 1) {
    label = 'Updated yesterday';
  } else if (days < 7) {
    label = 'Updated ${ago(days, 'day')}';
  } else {
    label = 'Updated on ${(local.year == base.year ? DateFormat.MMMd() : DateFormat.yMMMd()).format(local)}';
  }
  final who = isMe ? 'you' : by?.trim();
  return who == null || who.isEmpty ? label : '$label by $who';
}

/// "3:07", or "1:02:09" past an hour — a playback position.
String formatPlaybackTime(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}
