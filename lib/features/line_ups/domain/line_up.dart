import 'package:freezed_annotation/freezed_annotation.dart';

import '../../songs/domain/song.dart';

part 'line_up.freezed.dart';
part 'line_up.g.dart';

/// `LineUpListItemData` from the API.
@freezed
abstract class LineUp with _$LineUp {
  const LineUp._();

  const factory LineUp({
    required int id,
    required String title,

    /// `YYYY-MM-DD`.
    required String date,
    String? worshipLeader,
    @Default(0) int songsCount,
    @Default(1) int version,
  }) = _LineUp;

  factory LineUp.fromJson(Map<String, dynamic> json) => _$LineUpFromJson(json);

  bool get isEmpty => songsCount == 0;

  /// Created on this device and not yet accepted by the server.
  bool get isPending => id < 0;

  String? get leader {
    final trimmed = worshipLeader?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

/// `GET /api/line-ups` → `{ line_ups: [...] }`.
@freezed
abstract class LineUpListPage with _$LineUpListPage {
  const factory LineUpListPage({required List<LineUp> lineUps}) = _LineUpListPage;

  factory LineUpListPage.fromJson(Map<String, dynamic> json) => _$LineUpListPageFromJson(json);
}

/// `LineUpDetailData` — what create, update, song sync and show return.
@freezed
abstract class LineUpDetail with _$LineUpDetail {
  const LineUpDetail._();

  const factory LineUpDetail({
    required int id,
    required String title,
    required String date,
    String? worshipLeader,
    @Default(0) int songsCount,
    @Default(<LineUpSongEntry>[]) List<LineUpSongEntry> songs,
    @Default(1) int version,
  }) = _LineUpDetail;

  factory LineUpDetail.fromJson(Map<String, dynamic> json) => _$LineUpDetailFromJson(json);

  LineUp get summary =>
      LineUp(id: id, title: title, date: date, worshipLeader: worshipLeader, songsCount: songsCount, version: version);
}

/// `LineUpSongEntryData` — one song in a line-up, with its line-up key.
@freezed
abstract class LineUpSongEntry with _$LineUpSongEntry {
  const factory LineUpSongEntry({
    required int lineUpSongId,
    required int order,
    @Default(0) int transposition,
    required Song song,
    @Default(<LineUpSongNote>[]) List<LineUpSongNote> notes,
    SectionArrangement? sectionArrangement,
  }) = _LineUpSongEntry;

  factory LineUpSongEntry.fromJson(Map<String, dynamic> json) => _$LineUpSongEntryFromJson(json);
}

/// `LineUpSongNoteData` — a team note pinned to one line of a song's chart.
@freezed
abstract class LineUpSongNote with _$LineUpSongNote {
  const factory LineUpSongNote({required String id, required int line, required String text}) = _LineUpSongNote;

  factory LineUpSongNote.fromJson(Map<String, dynamic> json) => _$LineUpSongNoteFromJson(json);
}

/// `LineUpSongSectionArrangementData` — how this line-up plays a song's
/// sections, separately for the chord chart and the lyrics.
@freezed
abstract class SectionArrangement with _$SectionArrangement {
  const SectionArrangement._();

  const factory SectionArrangement({
    @Default(SectionArrangementField()) SectionArrangementField chords,
    @Default(SectionArrangementField()) SectionArrangementField lyrics,
  }) = _SectionArrangement;

  factory SectionArrangement.fromJson(Map<String, dynamic> json) => _$SectionArrangementFromJson(json);

  bool get isEmpty => chords.isEmpty && lyrics.isEmpty;
}

/// `SectionArrangementFieldData` — original section indices in play order,
/// and the ones left out.
@freezed
abstract class SectionArrangementField with _$SectionArrangementField {
  const SectionArrangementField._();

  const factory SectionArrangementField({@Default(<int>[]) List<int> order, @Default(<int>[]) List<int> removed}) =
      _SectionArrangementField;

  factory SectionArrangementField.fromJson(Map<String, dynamic> json) => _$SectionArrangementFieldFromJson(json);

  bool get isEmpty => order.isEmpty && removed.isEmpty;
}

/// `LineUpShareLinkData` — the public read-only link, when it's on.
@freezed
abstract class LineUpShareLink with _$LineUpShareLink {
  const factory LineUpShareLink({required bool enabled, String? token, String? sharePath}) = _LineUpShareLink;

  factory LineUpShareLink.fromJson(Map<String, dynamic> json) => _$LineUpShareLinkFromJson(json);
}
