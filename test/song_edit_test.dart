import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/songs/application/song_edit_controller.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:daloy_flutter/features/songs/domain/song_fields.dart';
import 'package:daloy_flutter/features/songs/presentation/editor/formatted_text_controllers.dart';
import 'package:daloy_flutter/features/songs/presentation/song_edit_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  group('SongFields', () {
    const song = Song(id: 7, title: 'Amazing Grace', artist: 'Newton', key: 'G', bpm: 72, content: '[G]Hi');

    test('round-trips a song and counts no change', () {
      final f = SongFields.fromSong(song);
      expect(f.matches(SongFields.fromSong(song)), isTrue);
      expect(f.applyTo(song), song);
    });

    test('blank text is null and whitespace is not a change', () {
      final f = SongFields.fromSong(song).copyWith(title: '  Amazing Grace ', artist: '   ');
      expect(f.matches(SongFields.fromSong(song)), isFalse); // artist cleared
      final applied = f.applyTo(song);
      expect((applied.title, applied.artist), ('Amazing Grace', null));
      expect(SongFields.fromSong(song).copyWith(title: 'Amazing Grace  ').matches(SongFields.fromSong(song)), isTrue);
    });

    test('copyWith can clear the key', () {
      expect(SongFields.fromSong(song).copyWith(key: null).key, isNull);
      expect(SongFields.fromSong(song).copyWith(title: 'x').key, 'G');
    });

    test('validates title, tempo and links', () {
      final f = SongFields.fromSong(song);
      expect(f.copyWith(title: ' ').titleError, isNotNull);
      expect(f.copyWith(bpm: '19').bpmError, isNotNull);
      expect(f.copyWith(bpm: '301').isValid, isFalse);
      expect(f.copyWith(bpm: '').isValid, isTrue);
      expect(f.copyWith(youtubeUrl: 'youtu.be/x').isValid, isFalse);
      expect(f.copyWith(youtubeUrl: 'https://youtu.be/x').isValid, isTrue);
      expect(f.copyWith(youtubeUrl: 'https://youtu.be/x', otherUrl: 'https://a.com').linkCount, 2);
    });
  });

  group('SongEdit', () {
    late FakeApiAdapter api;

    setUp(() {
      api = FakeApiAdapter({'PATCH /api/songs/7/changes': (r) => songChangeReply(r, serverSongJson(7))});
    });

    Future<(ProviderContainer, AppDatabase)> open() async {
      final container = await createTestContainer(api);
      final db = container.read(appDatabaseProvider);
      await db
          .into(db.songs)
          .insert(
            SongsCompanion.insert(
              id: const Value(7),
              workspaceId: 1,
              title: 'Amazing Grace',
              key: const Value('G'),
              content: const Value('[G]Hi'),
              lyrics: const Value('Hi'),
            ),
          );
      return (container, db);
    }

    test('is clean until something changes, and Save needs a valid change', () async {
      final (container, _) = await open();
      final provider = songEditProvider(7);
      container.listen(provider, (_, _) {}); // auto-dispose: keep it alive
      await container.read(provider.future);
      final controller = container.read(provider.notifier);

      expect(container.read(provider).value!.canSave, isFalse);
      controller.change((f) => f.copyWith(title: ''));
      expect(container.read(provider).value!.canSave, isFalse);
      controller.change((f) => f.copyWith(title: 'Grace'));
      expect(container.read(provider).value!.canSave, isTrue);
    });

    test('changing the key warns while chords exist, and only while it differs', () async {
      final (container, _) = await open();
      final provider = songEditProvider(7);
      container.listen(provider, (_, _) {}); // auto-dispose: keep it alive
      await container.read(provider.future);
      final controller = container.read(provider.notifier);

      controller.setKey('A');
      expect(container.read(provider).value!.showKeyNotice, isTrue);
      expect(container.read(provider).value!.fields.chords, '[G]Hi'); // chords are never rewritten
      controller.setKey('G');
      expect(container.read(provider).value!.showKeyNotice, isFalse);
    });

    test('save lands in Drift and the outbox without touching the network', () async {
      final (container, db) = await open();
      final provider = songEditProvider(7);
      container.listen(provider, (_, _) {}); // auto-dispose: keep it alive
      await container.read(provider.future);
      final controller = container.read(provider.notifier);

      controller.change((f) => f.copyWith(title: 'Grace', bpm: '80', chords: '[C]Yo', lyrics: ''));
      controller.setKey(null);
      expect(await controller.save(), isTrue);

      final row = await (db.select(db.songs)..where((t) => t.id.equals(7))).getSingle();
      expect((row.title, row.bpm, row.content, row.lyrics, row.key), ('Grace', 80, '[C]Yo', null, null));
      expect((await db.select(db.songEdits).get()).single.songId, 7);
      // Clean again afterwards.
      expect(container.read(provider).value!.isDirty, isFalse);
    });

    test('flush sends the saved fields', () async {
      final (container, _) = await open();
      final provider = songEditProvider(7);
      container.listen(provider, (_, _) {}); // auto-dispose: keep it alive
      await container.read(provider.future);
      final controller = container.read(provider.notifier);
      controller.change((f) => f.copyWith(artist: 'Newton'));
      await controller.save();

      await container.read(songDetailRepositoryProvider).flush(1);
      final patch = api.requests.singleWhere((r) => r.method == 'PATCH' && r.path == '/api/songs/7/changes');
      // Only the changed field, with the value it started from.
      expect(patch.data, {
        'changes': {'artist': 'Newton'},
        'base': {'artist': null},
      });
    });

    test('a missing song is reported', () async {
      final container = await createTestContainer(api);
      final provider = songEditProvider(99);
      expect(await container.read(songDetailRepositoryProvider).loadSong(99), isNull);
      container.listen(provider, (_, _) {}, onError: (_, _) {});
      await expectLater(container.read(provider.future), throwsA(isA<SongNotFound>()));
    });
  });

  group('screen', () {
    Future<void> pump(WidgetTester tester, {Size size = const Size(390, 844)}) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final container = await createTestContainer(FakeApiAdapter({}));
      final db = container.read(appDatabaseProvider);
      await db
          .into(db.songs)
          .insert(
            SongsCompanion.insert(
              id: const Value(7),
              workspaceId: 1,
              title: 'Amazing Grace',
              artist: const Value('Newton'),
              key: const Value('G'),
              bpm: const Value(72),
              timeSignature: const Value('3/4'),
              content: const Value('Verse:\n[G]Amazing [C]grace\n\nChorus: x2\n[C]How sweet'),
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const SongEditScreen(songId: 7),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('previews the song and reads Saved until something changes', (tester) async {
      await pump(tester);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.bySemanticsLabel('Key: G'), findsOneWidget);
      expect(find.bySemanticsLabel('Tempo: 72 BPM'), findsOneWidget);
      expect(find.text('No lyrics yet'), findsOneWidget);
      // The chords preview heads its sections as Perform does.
      expect(find.text('VERSE'), findsOneWidget);
      expect(find.text('CHORUS  ×2'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Amazing Grace'), 'Grace');
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Unsaved changes'), findsOneWidget);
    });

    testWidgets('the tempo sheet sets the tempo', (tester) async {
      await pump(tester);
      await tester.tap(find.bySemanticsLabel('Tempo: 72 BPM'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '72'), '96');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Tempo: 96 BPM'), findsOneWidget);
      expect(find.text('Unsaved changes'), findsOneWidget);
    });

    testWidgets('fits a small phone', (tester) async {
      await pump(tester, size: const Size(320, 640));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the lyrics editor styles headings but keeps the text as typed', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: DaloyTheme.light(),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final controller = LyricsTextController(text: '[Chorus]\nHow sweet\nVerse 2:\nThe sound');
    addTearDown(controller.dispose);
    final span = controller.buildTextSpan(context: context, withComposing: false);
    expect(span.toPlainText(), '[CHORUS]\nHow sweet\nVERSE 2:\nThe sound'); // same length, offsets kept
    expect(controller.text, '[Chorus]\nHow sweet\nVerse 2:\nThe sound');
  });
}
