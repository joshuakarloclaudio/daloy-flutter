import 'package:flutter/foundation.dart';

/// `LiveSessionCueData.kind`.
enum LiveCueKind {
  emoji,
  text,
  preset;

  static LiveCueKind parse(Object? value) =>
      LiveCueKind.values.firstWhere((k) => k.name == value, orElse: () => LiveCueKind.text);
}

/// A cue sent to everyone in the session (`LiveSessionCueData`): an emoji, a
/// preset call ("Bridge") or a line of text.
@immutable
class LiveCue {
  const LiveCue({
    required this.id,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.senderId,
    this.senderName,
    this.sectionId,
    this.songIndex,
  });

  factory LiveCue.fromJson(Map<String, dynamic> json) => LiveCue(
    id: json['id'] as String,
    kind: LiveCueKind.parse(json['kind']),
    body: json['body'] as String,
    senderId: (json['sender_id'] as num?)?.toInt(),
    senderName: json['sender_name'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch((json['created_at'] as num).toInt()),
    sectionId: json['section_id'] as String?,
    songIndex: (json['song_index'] as num?)?.toInt(),
  );

  final String id;
  final LiveCueKind kind;
  final String body;
  final int? senderId;
  final String? senderName;
  final DateTime createdAt;

  /// Where the sender was when they sent it.
  final String? sectionId;
  final int? songIndex;

  bool get isEmoji => kind == LiveCueKind.emoji;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'body': body,
    'sender_id': senderId,
    'sender_name': senderName,
    'created_at': createdAt.millisecondsSinceEpoch,
    'section_id': sectionId,
    'song_index': songIndex,
  };
}

/// A one-tap call on the cue pad. [body] is what everyone sees, on the web
/// too, so the web's presets keep their exact bodies.
typedef CuePreset = ({String label, String body});

/// The web's five (`PERFORMANCE_PRESET_CUES`) plus Tag, Last chorus and
/// Key up, in the order a set usually needs them.
const List<CuePreset> liveCuePresets = [
  (label: 'Repeat', body: '↩ Repeat'),
  (label: 'Bridge', body: 'Bridge'),
  (label: 'Tag', body: 'Tag'),
  (label: 'Last chorus', body: 'Last chorus'),
  (label: 'Key up', body: 'Key up'),
  (label: 'Vamp', body: 'Vamp'),
  (label: 'Outro', body: 'Outro'),
  (label: 'Stop', body: 'Stop'),
];

/// The web's `PERFORMANCE_EMOJI_CUES`.
const List<String> liveEmojiCues = ['👏', '🔥', '🙌', '⏸️', '▶️'];
