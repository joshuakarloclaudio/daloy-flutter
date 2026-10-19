import 'package:daloy_flutter/features/export/domain/export_sheet.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/songs/chart/chart_parser.dart';
import 'package:daloy_flutter/features/songs/chart/chordpro.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:flutter_test/flutter_test.dart';

// Same cases as the web's `lib/chordpro.test.ts`, so the two agree.
const _amazingGrace = '''{title: Amazing Grace}
{subtitle: John Newton}
{key: G}
{tempo: 72}
{time: 3/4}
{capo: 2}
# a comment line

{start_of_verse}
A[G]mazing [G7]grace, how [C]sweet the [G]sound
That [G]saved a [Em]wretch like [D/F#]me
{end_of_verse}

{soc}
[C]My chains are [G]gone
{eoc}

{start_of_verse}
'Twas [G]grace that taught
{end_of_verse}

{chorus}

{c: Play softly}
{start_of_tab}
e|---3---|
{end_of_tab}
''';

void main() {
  group('parseChordPro', () {
    final song = parseChordPro(_amazingGrace);

    test('reads the metadata', () {
      expect(song.title, 'Amazing Grace');
      expect(song.artist, 'John Newton');
      expect(song.key, 'G');
      expect(song.bpm, 72);
      expect(song.timeSignature, '3/4');
      expect(song.skippedSongs, 0);
    });

    test('keeps chords inline and turns environments into headers', () {
      expect(
        song.content,
        [
          'Verse 1:',
          'A[G]mazing [G7]grace, how [C]sweet the [G]sound',
          'That [G]saved a [Em]wretch like [D]/[F#]me',
          '',
          'Chorus:',
          '[C]My chains are [G]gone',
          '',
          'Verse 2:',
          "'Twas [G]grace that taught",
          '',
          'Chorus:',
          '[C]My chains are [G]gone',
          '',
          'Play softly',
        ].join('\n'),
      );
    });

    test('gives the lyrics the same sections without chords or notes', () {
      expect(
        song.lyrics,
        [
          'Verse 1:',
          'Amazing grace, how sweet the sound',
          'That saved a wretch like me',
          '',
          'Chorus:',
          'My chains are gone',
          '',
          'Verse 2:',
          "'Twas grace that taught",
          '',
          'Chorus:',
          'My chains are gone',
        ].join('\n'),
      );
    });

    test('reads section comments as headers, with their repeat', () {
      final parsed = parseChordPro('{c: Chorus (x2)}\n[G]Sing\n{ci: Intro}\n[G] [C]');
      expect(parsed.content, 'Chorus: x2\n[G]Sing\n\nIntro:\n[G] [C]');
      expect(parsed.lyrics, 'Chorus: x2\nSing\n\nIntro:');
    });

    test('converts a grid into barlines', () {
      final parsed = parseChordPro('{start_of_grid: Intro}\n|| G . . . | C . . . | % . . . :| x2\n{end_of_grid}');
      expect(parsed.content, 'Intro:\n| [G] | [C] | % | x2');
      expect(parsed.lyrics, '');
    });

    test('imports only the first of several songs', () {
      final parsed = parseChordPro('{t: One}\n[G]a\n{new_song}\n{t: Two}\n{ns}\n{t: Three}');
      expect(parsed.title, 'One');
      expect(parsed.skippedSongs, 2);
    });

    test('leaves the chart empty for a file of words only', () {
      final parsed = parseChordPro('{title: Hymn}\nJust words here');
      expect(parsed.content, '');
      expect(parsed.lyrics, 'Just words here');
    });

    test('reads the long meta form and the label attribute', () {
      final parsed = parseChordPro('{meta: artist Hillsong}\n{sov label="Verse 2"}\n[A]x\n{eov}');
      expect(parsed.artist, 'Hillsong');
      expect(parsed.content, 'Verse 2:\n[A]x');
    });

    test("drops annotations and keeps what isn't a chord as text", () {
      expect(parseChordPro('[*Riff][G]Go [N.C.]stop').content, '[G]Go N.C.stop');
    });
  });

  test('chordProChordToDaloy', () {
    const cases = {
      'G': '[G]',
      'am': '[Am]',
      'D/F#': '[D]/[F#]',
      'C(add9)': '[Cadd9]',
      'B♭maj7': '[Bbmaj7]',
      'C-7': '[Cm7]',
      'G+': '[Gaug]',
      'Bo7': '[Bdim7]',
      'N.C.': null,
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      expect(chordProChordToDaloy(key), value, reason: key);
    }
  });

  test('normalizeChordProKey', () {
    const cases = {'G': 'G', 'E minor': 'Em', 'f#m': 'F#m', 'A#': 'Bb', 'Db': 'Db', 'nonsense': null};
    for (final MapEntry(:key, :value) in cases.entries) {
      expect(normalizeChordProKey(key), value, reason: key);
    }
  });

  test('looksLikeChordPro spots directives', () {
    expect(looksLikeChordPro('{title: X}\n[G]Hi'), isTrue);
    expect(looksLikeChordPro('Verse:\n[G] [C]'), isFalse);
  });

  group('toChordPro', () {
    const base = ChordProExportSong(
      title: 'Amazing Grace',
      artist: 'John Newton',
      key: 'G',
      bpm: 72,
      timeSignature: '3/4',
      content: 'Verse 1:\nA[G]mazing [G]/[B]grace\n\nChorus: x2\n| [C] | % |\n\nIntro:\n[G] [D]',
    );

    test('writes metadata, environments and slash chords', () {
      expect(
        toChordPro([base]),
        [
          '{title: Amazing Grace}',
          '{artist: John Newton}',
          '{key: G}',
          '{tempo: 72}',
          '{time: 3/4}',
          '',
          '{start_of_verse: Verse 1}',
          'A[G]mazing [G/B]grace',
          '{end_of_verse}',
          '',
          '{start_of_chorus: Chorus x2}',
          '| [C] | % |',
          '{end_of_chorus}',
          '',
          '{comment: Intro}',
          '[G] [D]',
          '',
        ].join('\n'),
      );
    });

    test('transposes to the played key and writes capo shapes', () {
      final text = toChordPro([
        const ChordProExportSong(title: 'X', key: 'G', content: '[G]/[B] [C]', transposition: 2, capo: 2),
      ]);
      expect(text, contains('{key: A}'));
      expect(text, contains('{capo: 2}'));
      expect(text, contains('[G/B] [C]'));
    });

    test('falls back to lyrics and separates songs', () {
      final text = toChordPro([base, const ChordProExportSong(title: 'Two', lyrics: 'Chorus:\nWords')]);
      expect(text, contains('{new_song}\n{title: Two}'));
      expect(text, contains('{start_of_chorus: Chorus}\nWords\n{end_of_chorus}'));
    });

    test('round-trips through import', () {
      final back = parseChordPro(toChordPro([base]));
      expect(back.content, base.content);
      expect(back.title, 'Amazing Grace');
      expect(back.bpm, 72);
    });
  });

  test('a line-up exports as one file in its keys and order', () {
    final set = ExportSet.lineUp(LineUp(id: 1, title: 'Sunday', date: '2026-10-25'), [
      ExportSong(
        song: const Song(id: 1, title: 'One', key: 'G', content: '[G]Hi'),
        transposition: 2,
      ),
      const ExportSong(
        song: Song(id: 2, title: 'Two', lyrics: 'Words'),
      ),
    ]);
    final text = chordProText(set);
    expect(text, startsWith('{title: One}\n{key: A}\n\n[A]Hi\n\n{new_song}\n{title: Two}'));
    expect(set.fileName(ExportFormat.chordPro), 'sunday.cho');
  });

  test('chordLyricWords keeps [G]/[B] as one chord over its word', () {
    final words = chordLyricWords(parseLine('[G]/[B]grace'));
    expect(words.single.single.chord, 'G/B');
    expect(words.single.single.text, 'grace');
  });
}
