// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, SongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transpositionMeta = const VerificationMeta(
    'transposition',
  );
  @override
  late final GeneratedColumn<int> transposition = GeneratedColumn<int>(
    'transposition',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
    'bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeSignatureMeta = const VerificationMeta(
    'timeSignature',
  );
  @override
  late final GeneratedColumn<String> timeSignature = GeneratedColumn<String>(
    'time_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
    'lyrics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeUrlMeta = const VerificationMeta(
    'youtubeUrl',
  );
  @override
  late final GeneratedColumn<String> youtubeUrl = GeneratedColumn<String>(
    'youtube_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spotifyUrlMeta = const VerificationMeta(
    'spotifyUrl',
  );
  @override
  late final GeneratedColumn<String> spotifyUrl = GeneratedColumn<String>(
    'spotify_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appleMusicUrlMeta = const VerificationMeta(
    'appleMusicUrl',
  );
  @override
  late final GeneratedColumn<String> appleMusicUrl = GeneratedColumn<String>(
    'apple_music_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherUrlMeta = const VerificationMeta(
    'otherUrl',
  );
  @override
  late final GeneratedColumn<String> otherUrl = GeneratedColumn<String>(
    'other_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    title,
    artist,
    key,
    transposition,
    bpm,
    timeSignature,
    content,
    lyrics,
    youtubeUrl,
    spotifyUrl,
    appleMusicUrl,
    otherUrl,
    isPublic,
    createdAt,
    lastUsedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('transposition')) {
      context.handle(
        _transpositionMeta,
        transposition.isAcceptableOrUnknown(
          data['transposition']!,
          _transpositionMeta,
        ),
      );
    }
    if (data.containsKey('bpm')) {
      context.handle(
        _bpmMeta,
        bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta),
      );
    }
    if (data.containsKey('time_signature')) {
      context.handle(
        _timeSignatureMeta,
        timeSignature.isAcceptableOrUnknown(
          data['time_signature']!,
          _timeSignatureMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('lyrics')) {
      context.handle(
        _lyricsMeta,
        lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta),
      );
    }
    if (data.containsKey('youtube_url')) {
      context.handle(
        _youtubeUrlMeta,
        youtubeUrl.isAcceptableOrUnknown(data['youtube_url']!, _youtubeUrlMeta),
      );
    }
    if (data.containsKey('spotify_url')) {
      context.handle(
        _spotifyUrlMeta,
        spotifyUrl.isAcceptableOrUnknown(data['spotify_url']!, _spotifyUrlMeta),
      );
    }
    if (data.containsKey('apple_music_url')) {
      context.handle(
        _appleMusicUrlMeta,
        appleMusicUrl.isAcceptableOrUnknown(
          data['apple_music_url']!,
          _appleMusicUrlMeta,
        ),
      );
    }
    if (data.containsKey('other_url')) {
      context.handle(
        _otherUrlMeta,
        otherUrl.isAcceptableOrUnknown(data['other_url']!, _otherUrlMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      ),
      transposition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transposition'],
      ),
      bpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bpm'],
      ),
      timeSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_signature'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      lyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics'],
      ),
      youtubeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_url'],
      ),
      spotifyUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spotify_url'],
      ),
      appleMusicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apple_music_url'],
      ),
      otherUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_url'],
      ),
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class SongRow extends DataClass implements Insertable<SongRow> {
  final int id;
  final int workspaceId;
  final String title;
  final String? artist;
  final String? key;
  final int? transposition;
  final int? bpm;
  final String? timeSignature;
  final String? content;
  final String? lyrics;
  final String? youtubeUrl;
  final String? spotifyUrl;
  final String? appleMusicUrl;
  final String? otherUrl;
  final bool isPublic;
  final DateTime? createdAt;

  /// When it was last added to a line-up — the "Recently used" sort.
  final DateTime? lastUsedAt;

  /// The server's version of this copy; a realtime ping with a higher one
  /// means it's out of date.
  final int version;
  const SongRow({
    required this.id,
    required this.workspaceId,
    required this.title,
    this.artist,
    this.key,
    this.transposition,
    this.bpm,
    this.timeSignature,
    this.content,
    this.lyrics,
    this.youtubeUrl,
    this.spotifyUrl,
    this.appleMusicUrl,
    this.otherUrl,
    required this.isPublic,
    this.createdAt,
    this.lastUsedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    if (!nullToAbsent || transposition != null) {
      map['transposition'] = Variable<int>(transposition);
    }
    if (!nullToAbsent || bpm != null) {
      map['bpm'] = Variable<int>(bpm);
    }
    if (!nullToAbsent || timeSignature != null) {
      map['time_signature'] = Variable<String>(timeSignature);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || lyrics != null) {
      map['lyrics'] = Variable<String>(lyrics);
    }
    if (!nullToAbsent || youtubeUrl != null) {
      map['youtube_url'] = Variable<String>(youtubeUrl);
    }
    if (!nullToAbsent || spotifyUrl != null) {
      map['spotify_url'] = Variable<String>(spotifyUrl);
    }
    if (!nullToAbsent || appleMusicUrl != null) {
      map['apple_music_url'] = Variable<String>(appleMusicUrl);
    }
    if (!nullToAbsent || otherUrl != null) {
      map['other_url'] = Variable<String>(otherUrl);
    }
    map['is_public'] = Variable<bool>(isPublic);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      transposition: transposition == null && nullToAbsent
          ? const Value.absent()
          : Value(transposition),
      bpm: bpm == null && nullToAbsent ? const Value.absent() : Value(bpm),
      timeSignature: timeSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSignature),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      lyrics: lyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(lyrics),
      youtubeUrl: youtubeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeUrl),
      spotifyUrl: spotifyUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(spotifyUrl),
      appleMusicUrl: appleMusicUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(appleMusicUrl),
      otherUrl: otherUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(otherUrl),
      isPublic: Value(isPublic),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      version: Value(version),
    );
  }

  factory SongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongRow(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      key: serializer.fromJson<String?>(json['key']),
      transposition: serializer.fromJson<int?>(json['transposition']),
      bpm: serializer.fromJson<int?>(json['bpm']),
      timeSignature: serializer.fromJson<String?>(json['timeSignature']),
      content: serializer.fromJson<String?>(json['content']),
      lyrics: serializer.fromJson<String?>(json['lyrics']),
      youtubeUrl: serializer.fromJson<String?>(json['youtubeUrl']),
      spotifyUrl: serializer.fromJson<String?>(json['spotifyUrl']),
      appleMusicUrl: serializer.fromJson<String?>(json['appleMusicUrl']),
      otherUrl: serializer.fromJson<String?>(json['otherUrl']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'key': serializer.toJson<String?>(key),
      'transposition': serializer.toJson<int?>(transposition),
      'bpm': serializer.toJson<int?>(bpm),
      'timeSignature': serializer.toJson<String?>(timeSignature),
      'content': serializer.toJson<String?>(content),
      'lyrics': serializer.toJson<String?>(lyrics),
      'youtubeUrl': serializer.toJson<String?>(youtubeUrl),
      'spotifyUrl': serializer.toJson<String?>(spotifyUrl),
      'appleMusicUrl': serializer.toJson<String?>(appleMusicUrl),
      'otherUrl': serializer.toJson<String?>(otherUrl),
      'isPublic': serializer.toJson<bool>(isPublic),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  SongRow copyWith({
    int? id,
    int? workspaceId,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> key = const Value.absent(),
    Value<int?> transposition = const Value.absent(),
    Value<int?> bpm = const Value.absent(),
    Value<String?> timeSignature = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<String?> lyrics = const Value.absent(),
    Value<String?> youtubeUrl = const Value.absent(),
    Value<String?> spotifyUrl = const Value.absent(),
    Value<String?> appleMusicUrl = const Value.absent(),
    Value<String?> otherUrl = const Value.absent(),
    bool? isPublic,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> lastUsedAt = const Value.absent(),
    int? version,
  }) => SongRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    key: key.present ? key.value : this.key,
    transposition: transposition.present
        ? transposition.value
        : this.transposition,
    bpm: bpm.present ? bpm.value : this.bpm,
    timeSignature: timeSignature.present
        ? timeSignature.value
        : this.timeSignature,
    content: content.present ? content.value : this.content,
    lyrics: lyrics.present ? lyrics.value : this.lyrics,
    youtubeUrl: youtubeUrl.present ? youtubeUrl.value : this.youtubeUrl,
    spotifyUrl: spotifyUrl.present ? spotifyUrl.value : this.spotifyUrl,
    appleMusicUrl: appleMusicUrl.present
        ? appleMusicUrl.value
        : this.appleMusicUrl,
    otherUrl: otherUrl.present ? otherUrl.value : this.otherUrl,
    isPublic: isPublic ?? this.isPublic,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    version: version ?? this.version,
  );
  SongRow copyWithCompanion(SongsCompanion data) {
    return SongRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      key: data.key.present ? data.key.value : this.key,
      transposition: data.transposition.present
          ? data.transposition.value
          : this.transposition,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      timeSignature: data.timeSignature.present
          ? data.timeSignature.value
          : this.timeSignature,
      content: data.content.present ? data.content.value : this.content,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
      youtubeUrl: data.youtubeUrl.present
          ? data.youtubeUrl.value
          : this.youtubeUrl,
      spotifyUrl: data.spotifyUrl.present
          ? data.spotifyUrl.value
          : this.spotifyUrl,
      appleMusicUrl: data.appleMusicUrl.present
          ? data.appleMusicUrl.value
          : this.appleMusicUrl,
      otherUrl: data.otherUrl.present ? data.otherUrl.value : this.otherUrl,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('key: $key, ')
          ..write('transposition: $transposition, ')
          ..write('bpm: $bpm, ')
          ..write('timeSignature: $timeSignature, ')
          ..write('content: $content, ')
          ..write('lyrics: $lyrics, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('spotifyUrl: $spotifyUrl, ')
          ..write('appleMusicUrl: $appleMusicUrl, ')
          ..write('otherUrl: $otherUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    title,
    artist,
    key,
    transposition,
    bpm,
    timeSignature,
    content,
    lyrics,
    youtubeUrl,
    spotifyUrl,
    appleMusicUrl,
    otherUrl,
    isPublic,
    createdAt,
    lastUsedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.key == this.key &&
          other.transposition == this.transposition &&
          other.bpm == this.bpm &&
          other.timeSignature == this.timeSignature &&
          other.content == this.content &&
          other.lyrics == this.lyrics &&
          other.youtubeUrl == this.youtubeUrl &&
          other.spotifyUrl == this.spotifyUrl &&
          other.appleMusicUrl == this.appleMusicUrl &&
          other.otherUrl == this.otherUrl &&
          other.isPublic == this.isPublic &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.version == this.version);
}

class SongsCompanion extends UpdateCompanion<SongRow> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> key;
  final Value<int?> transposition;
  final Value<int?> bpm;
  final Value<String?> timeSignature;
  final Value<String?> content;
  final Value<String?> lyrics;
  final Value<String?> youtubeUrl;
  final Value<String?> spotifyUrl;
  final Value<String?> appleMusicUrl;
  final Value<String?> otherUrl;
  final Value<bool> isPublic;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int> version;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.key = const Value.absent(),
    this.transposition = const Value.absent(),
    this.bpm = const Value.absent(),
    this.timeSignature = const Value.absent(),
    this.content = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.spotifyUrl = const Value.absent(),
    this.appleMusicUrl = const Value.absent(),
    this.otherUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.version = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String title,
    this.artist = const Value.absent(),
    this.key = const Value.absent(),
    this.transposition = const Value.absent(),
    this.bpm = const Value.absent(),
    this.timeSignature = const Value.absent(),
    this.content = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.spotifyUrl = const Value.absent(),
    this.appleMusicUrl = const Value.absent(),
    this.otherUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.version = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       title = Value(title);
  static Insertable<SongRow> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? key,
    Expression<int>? transposition,
    Expression<int>? bpm,
    Expression<String>? timeSignature,
    Expression<String>? content,
    Expression<String>? lyrics,
    Expression<String>? youtubeUrl,
    Expression<String>? spotifyUrl,
    Expression<String>? appleMusicUrl,
    Expression<String>? otherUrl,
    Expression<bool>? isPublic,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (key != null) 'key': key,
      if (transposition != null) 'transposition': transposition,
      if (bpm != null) 'bpm': bpm,
      if (timeSignature != null) 'time_signature': timeSignature,
      if (content != null) 'content': content,
      if (lyrics != null) 'lyrics': lyrics,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      if (spotifyUrl != null) 'spotify_url': spotifyUrl,
      if (appleMusicUrl != null) 'apple_music_url': appleMusicUrl,
      if (otherUrl != null) 'other_url': otherUrl,
      if (isPublic != null) 'is_public': isPublic,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (version != null) 'version': version,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<int>? workspaceId,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? key,
    Value<int?>? transposition,
    Value<int?>? bpm,
    Value<String?>? timeSignature,
    Value<String?>? content,
    Value<String?>? lyrics,
    Value<String?>? youtubeUrl,
    Value<String?>? spotifyUrl,
    Value<String?>? appleMusicUrl,
    Value<String?>? otherUrl,
    Value<bool>? isPublic,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<int>? version,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      transposition: transposition ?? this.transposition,
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      content: content ?? this.content,
      lyrics: lyrics ?? this.lyrics,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      appleMusicUrl: appleMusicUrl ?? this.appleMusicUrl,
      otherUrl: otherUrl ?? this.otherUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (transposition.present) {
      map['transposition'] = Variable<int>(transposition.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (timeSignature.present) {
      map['time_signature'] = Variable<String>(timeSignature.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(lyrics.value);
    }
    if (youtubeUrl.present) {
      map['youtube_url'] = Variable<String>(youtubeUrl.value);
    }
    if (spotifyUrl.present) {
      map['spotify_url'] = Variable<String>(spotifyUrl.value);
    }
    if (appleMusicUrl.present) {
      map['apple_music_url'] = Variable<String>(appleMusicUrl.value);
    }
    if (otherUrl.present) {
      map['other_url'] = Variable<String>(otherUrl.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('key: $key, ')
          ..write('transposition: $transposition, ')
          ..write('bpm: $bpm, ')
          ..write('timeSignature: $timeSignature, ')
          ..write('content: $content, ')
          ..write('lyrics: $lyrics, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('spotifyUrl: $spotifyUrl, ')
          ..write('appleMusicUrl: $appleMusicUrl, ')
          ..write('otherUrl: $otherUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $SongOutboxTable extends SongOutbox
    with TableInfo<$SongOutboxTable, SongOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    workspaceId,
    error,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SongOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongOutboxRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SongOutboxTable createAlias(String alias) {
    return $SongOutboxTable(attachedDatabase, alias);
  }
}

class SongOutboxRow extends DataClass implements Insertable<SongOutboxRow> {
  final int localId;
  final int workspaceId;
  final String? error;
  final DateTime createdAt;
  const SongOutboxRow({
    required this.localId,
    required this.workspaceId,
    this.error,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['workspace_id'] = Variable<int>(workspaceId);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SongOutboxCompanion toCompanion(bool nullToAbsent) {
    return SongOutboxCompanion(
      localId: Value(localId),
      workspaceId: Value(workspaceId),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
    );
  }

  factory SongOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongOutboxRow(
      localId: serializer.fromJson<int>(json['localId']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SongOutboxRow copyWith({
    int? localId,
    int? workspaceId,
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
  }) => SongOutboxRow(
    localId: localId ?? this.localId,
    workspaceId: workspaceId ?? this.workspaceId,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
  );
  SongOutboxRow copyWithCompanion(SongOutboxCompanion data) {
    return SongOutboxRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongOutboxRow(')
          ..write('localId: $localId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, workspaceId, error, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongOutboxRow &&
          other.localId == this.localId &&
          other.workspaceId == this.workspaceId &&
          other.error == this.error &&
          other.createdAt == this.createdAt);
}

class SongOutboxCompanion extends UpdateCompanion<SongOutboxRow> {
  final Value<int> localId;
  final Value<int> workspaceId;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  const SongOutboxCompanion({
    this.localId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SongOutboxCompanion.insert({
    this.localId = const Value.absent(),
    required int workspaceId,
    this.error = const Value.absent(),
    required DateTime createdAt,
  }) : workspaceId = Value(workspaceId),
       createdAt = Value(createdAt);
  static Insertable<SongOutboxRow> custom({
    Expression<int>? localId,
    Expression<int>? workspaceId,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SongOutboxCompanion copyWith({
    Value<int>? localId,
    Value<int>? workspaceId,
    Value<String?>? error,
    Value<DateTime>? createdAt,
  }) {
    return SongOutboxCompanion(
      localId: localId ?? this.localId,
      workspaceId: workspaceId ?? this.workspaceId,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongOutboxCompanion(')
          ..write('localId: $localId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SongEditsTable extends SongEdits
    with TableInfo<$SongEditsTable, SongEditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongEditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<String> base = GeneratedColumn<String>(
    'base',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictsMeta = const VerificationMeta(
    'conflicts',
  );
  @override
  late final GeneratedColumn<String> conflicts = GeneratedColumn<String>(
    'conflicts',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    workspaceId,
    updatedAt,
    error,
    base,
    conflicts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_edits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongEditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('base')) {
      context.handle(
        _baseMeta,
        base.isAcceptableOrUnknown(data['base']!, _baseMeta),
      );
    }
    if (data.containsKey('conflicts')) {
      context.handle(
        _conflictsMeta,
        conflicts.isAcceptableOrUnknown(data['conflicts']!, _conflictsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  SongEditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongEditRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      base: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base'],
      ),
      conflicts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflicts'],
      ),
    );
  }

  @override
  $SongEditsTable createAlias(String alias) {
    return $SongEditsTable(attachedDatabase, alias);
  }
}

class SongEditRow extends DataClass implements Insertable<SongEditRow> {
  final int songId;
  final int workspaceId;
  final DateTime updatedAt;

  /// Why the server last refused it (null: just waiting).
  final String? error;

  /// JSON `{api_field: value}`: each changed field as the server had it when
  /// this device first changed it. Null on rows queued before schema 10
  /// (they send the whole song, as they used to).
  final String? base;

  /// JSON `{api_field: value}`: fields the server refused because someone
  /// else changed them first — their value. Not sent until settled.
  final String? conflicts;
  const SongEditRow({
    required this.songId,
    required this.workspaceId,
    required this.updatedAt,
    this.error,
    this.base,
    this.conflicts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || base != null) {
      map['base'] = Variable<String>(base);
    }
    if (!nullToAbsent || conflicts != null) {
      map['conflicts'] = Variable<String>(conflicts);
    }
    return map;
  }

  SongEditsCompanion toCompanion(bool nullToAbsent) {
    return SongEditsCompanion(
      songId: Value(songId),
      workspaceId: Value(workspaceId),
      updatedAt: Value(updatedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      base: base == null && nullToAbsent ? const Value.absent() : Value(base),
      conflicts: conflicts == null && nullToAbsent
          ? const Value.absent()
          : Value(conflicts),
    );
  }

  factory SongEditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongEditRow(
      songId: serializer.fromJson<int>(json['songId']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      error: serializer.fromJson<String?>(json['error']),
      base: serializer.fromJson<String?>(json['base']),
      conflicts: serializer.fromJson<String?>(json['conflicts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'error': serializer.toJson<String?>(error),
      'base': serializer.toJson<String?>(base),
      'conflicts': serializer.toJson<String?>(conflicts),
    };
  }

  SongEditRow copyWith({
    int? songId,
    int? workspaceId,
    DateTime? updatedAt,
    Value<String?> error = const Value.absent(),
    Value<String?> base = const Value.absent(),
    Value<String?> conflicts = const Value.absent(),
  }) => SongEditRow(
    songId: songId ?? this.songId,
    workspaceId: workspaceId ?? this.workspaceId,
    updatedAt: updatedAt ?? this.updatedAt,
    error: error.present ? error.value : this.error,
    base: base.present ? base.value : this.base,
    conflicts: conflicts.present ? conflicts.value : this.conflicts,
  );
  SongEditRow copyWithCompanion(SongEditsCompanion data) {
    return SongEditRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      error: data.error.present ? data.error.value : this.error,
      base: data.base.present ? data.base.value : this.base,
      conflicts: data.conflicts.present ? data.conflicts.value : this.conflicts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongEditRow(')
          ..write('songId: $songId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('error: $error, ')
          ..write('base: $base, ')
          ..write('conflicts: $conflicts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(songId, workspaceId, updatedAt, error, base, conflicts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongEditRow &&
          other.songId == this.songId &&
          other.workspaceId == this.workspaceId &&
          other.updatedAt == this.updatedAt &&
          other.error == this.error &&
          other.base == this.base &&
          other.conflicts == this.conflicts);
}

class SongEditsCompanion extends UpdateCompanion<SongEditRow> {
  final Value<int> songId;
  final Value<int> workspaceId;
  final Value<DateTime> updatedAt;
  final Value<String?> error;
  final Value<String?> base;
  final Value<String?> conflicts;
  const SongEditsCompanion({
    this.songId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.base = const Value.absent(),
    this.conflicts = const Value.absent(),
  });
  SongEditsCompanion.insert({
    this.songId = const Value.absent(),
    required int workspaceId,
    required DateTime updatedAt,
    this.error = const Value.absent(),
    this.base = const Value.absent(),
    this.conflicts = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       updatedAt = Value(updatedAt);
  static Insertable<SongEditRow> custom({
    Expression<int>? songId,
    Expression<int>? workspaceId,
    Expression<DateTime>? updatedAt,
    Expression<String>? error,
    Expression<String>? base,
    Expression<String>? conflicts,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (error != null) 'error': error,
      if (base != null) 'base': base,
      if (conflicts != null) 'conflicts': conflicts,
    });
  }

  SongEditsCompanion copyWith({
    Value<int>? songId,
    Value<int>? workspaceId,
    Value<DateTime>? updatedAt,
    Value<String?>? error,
    Value<String?>? base,
    Value<String?>? conflicts,
  }) {
    return SongEditsCompanion(
      songId: songId ?? this.songId,
      workspaceId: workspaceId ?? this.workspaceId,
      updatedAt: updatedAt ?? this.updatedAt,
      error: error ?? this.error,
      base: base ?? this.base,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (base.present) {
      map['base'] = Variable<String>(base.value);
    }
    if (conflicts.present) {
      map['conflicts'] = Variable<String>(conflicts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongEditsCompanion(')
          ..write('songId: $songId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('error: $error, ')
          ..write('base: $base, ')
          ..write('conflicts: $conflicts')
          ..write(')'))
        .toString();
  }
}

class $SongCaposTable extends SongCapos
    with TableInfo<$SongCaposTable, SongCapoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongCaposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capoMeta = const VerificationMeta('capo');
  @override
  late final GeneratedColumn<int> capo = GeneratedColumn<int>(
    'capo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [songId, capo, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_capos';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongCapoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    }
    if (data.containsKey('capo')) {
      context.handle(
        _capoMeta,
        capo.isAcceptableOrUnknown(data['capo']!, _capoMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  SongCapoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongCapoRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      capo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capo'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $SongCaposTable createAlias(String alias) {
    return $SongCaposTable(attachedDatabase, alias);
  }
}

class SongCapoRow extends DataClass implements Insertable<SongCapoRow> {
  final int songId;
  final int capo;
  final bool dirty;
  const SongCapoRow({
    required this.songId,
    required this.capo,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    map['capo'] = Variable<int>(capo);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  SongCaposCompanion toCompanion(bool nullToAbsent) {
    return SongCaposCompanion(
      songId: Value(songId),
      capo: Value(capo),
      dirty: Value(dirty),
    );
  }

  factory SongCapoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongCapoRow(
      songId: serializer.fromJson<int>(json['songId']),
      capo: serializer.fromJson<int>(json['capo']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'capo': serializer.toJson<int>(capo),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  SongCapoRow copyWith({int? songId, int? capo, bool? dirty}) => SongCapoRow(
    songId: songId ?? this.songId,
    capo: capo ?? this.capo,
    dirty: dirty ?? this.dirty,
  );
  SongCapoRow copyWithCompanion(SongCaposCompanion data) {
    return SongCapoRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      capo: data.capo.present ? data.capo.value : this.capo,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongCapoRow(')
          ..write('songId: $songId, ')
          ..write('capo: $capo, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, capo, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongCapoRow &&
          other.songId == this.songId &&
          other.capo == this.capo &&
          other.dirty == this.dirty);
}

class SongCaposCompanion extends UpdateCompanion<SongCapoRow> {
  final Value<int> songId;
  final Value<int> capo;
  final Value<bool> dirty;
  const SongCaposCompanion({
    this.songId = const Value.absent(),
    this.capo = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  SongCaposCompanion.insert({
    this.songId = const Value.absent(),
    this.capo = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  static Insertable<SongCapoRow> custom({
    Expression<int>? songId,
    Expression<int>? capo,
    Expression<bool>? dirty,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (capo != null) 'capo': capo,
      if (dirty != null) 'dirty': dirty,
    });
  }

  SongCaposCompanion copyWith({
    Value<int>? songId,
    Value<int>? capo,
    Value<bool>? dirty,
  }) {
    return SongCaposCompanion(
      songId: songId ?? this.songId,
      capo: capo ?? this.capo,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (capo.present) {
      map['capo'] = Variable<int>(capo.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongCaposCompanion(')
          ..write('songId: $songId, ')
          ..write('capo: $capo, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }
}

class $SongUpcomingLineUpsTable extends SongUpcomingLineUps
    with TableInfo<$SongUpcomingLineUpsTable, SongUpcomingLineUpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongUpcomingLineUpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineUpIdMeta = const VerificationMeta(
    'lineUpId',
  );
  @override
  late final GeneratedColumn<int> lineUpId = GeneratedColumn<int>(
    'line_up_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, lineUpId, title, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_upcoming_line_ups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongUpcomingLineUpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('line_up_id')) {
      context.handle(
        _lineUpIdMeta,
        lineUpId.isAcceptableOrUnknown(data['line_up_id']!, _lineUpIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineUpIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId, lineUpId};
  @override
  SongUpcomingLineUpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongUpcomingLineUpRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      lineUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $SongUpcomingLineUpsTable createAlias(String alias) {
    return $SongUpcomingLineUpsTable(attachedDatabase, alias);
  }
}

class SongUpcomingLineUpRow extends DataClass
    implements Insertable<SongUpcomingLineUpRow> {
  final int songId;
  final int lineUpId;
  final String title;

  /// `YYYY-MM-DD`.
  final String date;
  const SongUpcomingLineUpRow({
    required this.songId,
    required this.lineUpId,
    required this.title,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    map['line_up_id'] = Variable<int>(lineUpId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    return map;
  }

  SongUpcomingLineUpsCompanion toCompanion(bool nullToAbsent) {
    return SongUpcomingLineUpsCompanion(
      songId: Value(songId),
      lineUpId: Value(lineUpId),
      title: Value(title),
      date: Value(date),
    );
  }

  factory SongUpcomingLineUpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongUpcomingLineUpRow(
      songId: serializer.fromJson<int>(json['songId']),
      lineUpId: serializer.fromJson<int>(json['lineUpId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'lineUpId': serializer.toJson<int>(lineUpId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
    };
  }

  SongUpcomingLineUpRow copyWith({
    int? songId,
    int? lineUpId,
    String? title,
    String? date,
  }) => SongUpcomingLineUpRow(
    songId: songId ?? this.songId,
    lineUpId: lineUpId ?? this.lineUpId,
    title: title ?? this.title,
    date: date ?? this.date,
  );
  SongUpcomingLineUpRow copyWithCompanion(SongUpcomingLineUpsCompanion data) {
    return SongUpcomingLineUpRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      lineUpId: data.lineUpId.present ? data.lineUpId.value : this.lineUpId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongUpcomingLineUpRow(')
          ..write('songId: $songId, ')
          ..write('lineUpId: $lineUpId, ')
          ..write('title: $title, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, lineUpId, title, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongUpcomingLineUpRow &&
          other.songId == this.songId &&
          other.lineUpId == this.lineUpId &&
          other.title == this.title &&
          other.date == this.date);
}

class SongUpcomingLineUpsCompanion
    extends UpdateCompanion<SongUpcomingLineUpRow> {
  final Value<int> songId;
  final Value<int> lineUpId;
  final Value<String> title;
  final Value<String> date;
  final Value<int> rowid;
  const SongUpcomingLineUpsCompanion({
    this.songId = const Value.absent(),
    this.lineUpId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongUpcomingLineUpsCompanion.insert({
    required int songId,
    required int lineUpId,
    required String title,
    required String date,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       lineUpId = Value(lineUpId),
       title = Value(title),
       date = Value(date);
  static Insertable<SongUpcomingLineUpRow> custom({
    Expression<int>? songId,
    Expression<int>? lineUpId,
    Expression<String>? title,
    Expression<String>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (lineUpId != null) 'line_up_id': lineUpId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongUpcomingLineUpsCompanion copyWith({
    Value<int>? songId,
    Value<int>? lineUpId,
    Value<String>? title,
    Value<String>? date,
    Value<int>? rowid,
  }) {
    return SongUpcomingLineUpsCompanion(
      songId: songId ?? this.songId,
      lineUpId: lineUpId ?? this.lineUpId,
      title: title ?? this.title,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (lineUpId.present) {
      map['line_up_id'] = Variable<int>(lineUpId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongUpcomingLineUpsCompanion(')
          ..write('songId: $songId, ')
          ..write('lineUpId: $lineUpId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DisplayPrefsTable extends DisplayPrefs
    with TableInfo<$DisplayPrefsTable, DisplayPrefsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisplayPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewModeMeta = const VerificationMeta(
    'viewMode',
  );
  @override
  late final GeneratedColumn<String> viewMode = GeneratedColumn<String>(
    'view_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('chords'),
  );
  static const VerificationMeta _zoomMeta = const VerificationMeta('zoom');
  @override
  late final GeneratedColumn<int> zoom = GeneratedColumn<int>(
    'zoom',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _chordNotationMeta = const VerificationMeta(
    'chordNotation',
  );
  @override
  late final GeneratedColumn<String> chordNotation = GeneratedColumn<String>(
    'chord_notation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performThemeMeta = const VerificationMeta(
    'performTheme',
  );
  @override
  late final GeneratedColumn<String> performTheme = GeneratedColumn<String>(
    'perform_theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performAutoHideMeta = const VerificationMeta(
    'performAutoHide',
  );
  @override
  late final GeneratedColumn<bool> performAutoHide = GeneratedColumn<bool>(
    'perform_auto_hide',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("perform_auto_hide" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _performNotesMeta = const VerificationMeta(
    'performNotes',
  );
  @override
  late final GeneratedColumn<bool> performNotes = GeneratedColumn<bool>(
    'perform_notes',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("perform_notes" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _liveAutoReturnMeta = const VerificationMeta(
    'liveAutoReturn',
  );
  @override
  late final GeneratedColumn<bool> liveAutoReturn = GeneratedColumn<bool>(
    'live_auto_return',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("live_auto_return" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _practiceClickMeta = const VerificationMeta(
    'practiceClick',
  );
  @override
  late final GeneratedColumn<bool> practiceClick = GeneratedColumn<bool>(
    'practice_click',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("practice_click" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _practiceHapticsMeta = const VerificationMeta(
    'practiceHaptics',
  );
  @override
  late final GeneratedColumn<bool> practiceHaptics = GeneratedColumn<bool>(
    'practice_haptics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("practice_haptics" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _practiceFlashMeta = const VerificationMeta(
    'practiceFlash',
  );
  @override
  late final GeneratedColumn<bool> practiceFlash = GeneratedColumn<bool>(
    'practice_flash',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("practice_flash" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    viewMode,
    zoom,
    chordNotation,
    performTheme,
    performAutoHide,
    performNotes,
    liveAutoReturn,
    practiceClick,
    practiceHaptics,
    practiceFlash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'display_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DisplayPrefsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('view_mode')) {
      context.handle(
        _viewModeMeta,
        viewMode.isAcceptableOrUnknown(data['view_mode']!, _viewModeMeta),
      );
    }
    if (data.containsKey('zoom')) {
      context.handle(
        _zoomMeta,
        zoom.isAcceptableOrUnknown(data['zoom']!, _zoomMeta),
      );
    }
    if (data.containsKey('chord_notation')) {
      context.handle(
        _chordNotationMeta,
        chordNotation.isAcceptableOrUnknown(
          data['chord_notation']!,
          _chordNotationMeta,
        ),
      );
    }
    if (data.containsKey('perform_theme')) {
      context.handle(
        _performThemeMeta,
        performTheme.isAcceptableOrUnknown(
          data['perform_theme']!,
          _performThemeMeta,
        ),
      );
    }
    if (data.containsKey('perform_auto_hide')) {
      context.handle(
        _performAutoHideMeta,
        performAutoHide.isAcceptableOrUnknown(
          data['perform_auto_hide']!,
          _performAutoHideMeta,
        ),
      );
    }
    if (data.containsKey('perform_notes')) {
      context.handle(
        _performNotesMeta,
        performNotes.isAcceptableOrUnknown(
          data['perform_notes']!,
          _performNotesMeta,
        ),
      );
    }
    if (data.containsKey('live_auto_return')) {
      context.handle(
        _liveAutoReturnMeta,
        liveAutoReturn.isAcceptableOrUnknown(
          data['live_auto_return']!,
          _liveAutoReturnMeta,
        ),
      );
    }
    if (data.containsKey('practice_click')) {
      context.handle(
        _practiceClickMeta,
        practiceClick.isAcceptableOrUnknown(
          data['practice_click']!,
          _practiceClickMeta,
        ),
      );
    }
    if (data.containsKey('practice_haptics')) {
      context.handle(
        _practiceHapticsMeta,
        practiceHaptics.isAcceptableOrUnknown(
          data['practice_haptics']!,
          _practiceHapticsMeta,
        ),
      );
    }
    if (data.containsKey('practice_flash')) {
      context.handle(
        _practiceFlashMeta,
        practiceFlash.isAcceptableOrUnknown(
          data['practice_flash']!,
          _practiceFlashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DisplayPrefsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DisplayPrefsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      viewMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_mode'],
      )!,
      zoom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zoom'],
      )!,
      chordNotation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chord_notation'],
      ),
      performTheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perform_theme'],
      ),
      performAutoHide: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}perform_auto_hide'],
      )!,
      performNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}perform_notes'],
      )!,
      liveAutoReturn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}live_auto_return'],
      )!,
      practiceClick: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}practice_click'],
      )!,
      practiceHaptics: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}practice_haptics'],
      )!,
      practiceFlash: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}practice_flash'],
      )!,
    );
  }

  @override
  $DisplayPrefsTable createAlias(String alias) {
    return $DisplayPrefsTable(attachedDatabase, alias);
  }
}

class DisplayPrefsRow extends DataClass implements Insertable<DisplayPrefsRow> {
  final int id;

  /// `chords` | `lyrics`.
  final String viewMode;

  /// Percent of the base size, 75–200.
  final int zoom;

  /// `letters` | `numbers`.
  final String? chordNotation;

  /// Perform's theme on this device (`PerformTheme.name`); null: follow the app.
  final String? performTheme;

  /// Perform hides its chrome after a few idle seconds.
  final bool performAutoHide;

  /// Perform shows the team's notes in the chart.
  final bool performNotes;

  /// In a live session, a follower who scrolled away goes back to the team
  /// after a few idle seconds.
  final bool liveAutoReturn;

  /// Practice: the metronome clicks (off: the clock still runs, silently).
  final bool practiceClick;

  /// Practice: a haptic tick on every beat, heavier on 1.
  final bool practiceHaptics;

  /// Practice: the playing bar pulses on the beat.
  final bool practiceFlash;
  const DisplayPrefsRow({
    required this.id,
    required this.viewMode,
    required this.zoom,
    this.chordNotation,
    this.performTheme,
    required this.performAutoHide,
    required this.performNotes,
    required this.liveAutoReturn,
    required this.practiceClick,
    required this.practiceHaptics,
    required this.practiceFlash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['view_mode'] = Variable<String>(viewMode);
    map['zoom'] = Variable<int>(zoom);
    if (!nullToAbsent || chordNotation != null) {
      map['chord_notation'] = Variable<String>(chordNotation);
    }
    if (!nullToAbsent || performTheme != null) {
      map['perform_theme'] = Variable<String>(performTheme);
    }
    map['perform_auto_hide'] = Variable<bool>(performAutoHide);
    map['perform_notes'] = Variable<bool>(performNotes);
    map['live_auto_return'] = Variable<bool>(liveAutoReturn);
    map['practice_click'] = Variable<bool>(practiceClick);
    map['practice_haptics'] = Variable<bool>(practiceHaptics);
    map['practice_flash'] = Variable<bool>(practiceFlash);
    return map;
  }

  DisplayPrefsCompanion toCompanion(bool nullToAbsent) {
    return DisplayPrefsCompanion(
      id: Value(id),
      viewMode: Value(viewMode),
      zoom: Value(zoom),
      chordNotation: chordNotation == null && nullToAbsent
          ? const Value.absent()
          : Value(chordNotation),
      performTheme: performTheme == null && nullToAbsent
          ? const Value.absent()
          : Value(performTheme),
      performAutoHide: Value(performAutoHide),
      performNotes: Value(performNotes),
      liveAutoReturn: Value(liveAutoReturn),
      practiceClick: Value(practiceClick),
      practiceHaptics: Value(practiceHaptics),
      practiceFlash: Value(practiceFlash),
    );
  }

  factory DisplayPrefsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DisplayPrefsRow(
      id: serializer.fromJson<int>(json['id']),
      viewMode: serializer.fromJson<String>(json['viewMode']),
      zoom: serializer.fromJson<int>(json['zoom']),
      chordNotation: serializer.fromJson<String?>(json['chordNotation']),
      performTheme: serializer.fromJson<String?>(json['performTheme']),
      performAutoHide: serializer.fromJson<bool>(json['performAutoHide']),
      performNotes: serializer.fromJson<bool>(json['performNotes']),
      liveAutoReturn: serializer.fromJson<bool>(json['liveAutoReturn']),
      practiceClick: serializer.fromJson<bool>(json['practiceClick']),
      practiceHaptics: serializer.fromJson<bool>(json['practiceHaptics']),
      practiceFlash: serializer.fromJson<bool>(json['practiceFlash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'viewMode': serializer.toJson<String>(viewMode),
      'zoom': serializer.toJson<int>(zoom),
      'chordNotation': serializer.toJson<String?>(chordNotation),
      'performTheme': serializer.toJson<String?>(performTheme),
      'performAutoHide': serializer.toJson<bool>(performAutoHide),
      'performNotes': serializer.toJson<bool>(performNotes),
      'liveAutoReturn': serializer.toJson<bool>(liveAutoReturn),
      'practiceClick': serializer.toJson<bool>(practiceClick),
      'practiceHaptics': serializer.toJson<bool>(practiceHaptics),
      'practiceFlash': serializer.toJson<bool>(practiceFlash),
    };
  }

  DisplayPrefsRow copyWith({
    int? id,
    String? viewMode,
    int? zoom,
    Value<String?> chordNotation = const Value.absent(),
    Value<String?> performTheme = const Value.absent(),
    bool? performAutoHide,
    bool? performNotes,
    bool? liveAutoReturn,
    bool? practiceClick,
    bool? practiceHaptics,
    bool? practiceFlash,
  }) => DisplayPrefsRow(
    id: id ?? this.id,
    viewMode: viewMode ?? this.viewMode,
    zoom: zoom ?? this.zoom,
    chordNotation: chordNotation.present
        ? chordNotation.value
        : this.chordNotation,
    performTheme: performTheme.present ? performTheme.value : this.performTheme,
    performAutoHide: performAutoHide ?? this.performAutoHide,
    performNotes: performNotes ?? this.performNotes,
    liveAutoReturn: liveAutoReturn ?? this.liveAutoReturn,
    practiceClick: practiceClick ?? this.practiceClick,
    practiceHaptics: practiceHaptics ?? this.practiceHaptics,
    practiceFlash: practiceFlash ?? this.practiceFlash,
  );
  DisplayPrefsRow copyWithCompanion(DisplayPrefsCompanion data) {
    return DisplayPrefsRow(
      id: data.id.present ? data.id.value : this.id,
      viewMode: data.viewMode.present ? data.viewMode.value : this.viewMode,
      zoom: data.zoom.present ? data.zoom.value : this.zoom,
      chordNotation: data.chordNotation.present
          ? data.chordNotation.value
          : this.chordNotation,
      performTheme: data.performTheme.present
          ? data.performTheme.value
          : this.performTheme,
      performAutoHide: data.performAutoHide.present
          ? data.performAutoHide.value
          : this.performAutoHide,
      performNotes: data.performNotes.present
          ? data.performNotes.value
          : this.performNotes,
      liveAutoReturn: data.liveAutoReturn.present
          ? data.liveAutoReturn.value
          : this.liveAutoReturn,
      practiceClick: data.practiceClick.present
          ? data.practiceClick.value
          : this.practiceClick,
      practiceHaptics: data.practiceHaptics.present
          ? data.practiceHaptics.value
          : this.practiceHaptics,
      practiceFlash: data.practiceFlash.present
          ? data.practiceFlash.value
          : this.practiceFlash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DisplayPrefsRow(')
          ..write('id: $id, ')
          ..write('viewMode: $viewMode, ')
          ..write('zoom: $zoom, ')
          ..write('chordNotation: $chordNotation, ')
          ..write('performTheme: $performTheme, ')
          ..write('performAutoHide: $performAutoHide, ')
          ..write('performNotes: $performNotes, ')
          ..write('liveAutoReturn: $liveAutoReturn, ')
          ..write('practiceClick: $practiceClick, ')
          ..write('practiceHaptics: $practiceHaptics, ')
          ..write('practiceFlash: $practiceFlash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    viewMode,
    zoom,
    chordNotation,
    performTheme,
    performAutoHide,
    performNotes,
    liveAutoReturn,
    practiceClick,
    practiceHaptics,
    practiceFlash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DisplayPrefsRow &&
          other.id == this.id &&
          other.viewMode == this.viewMode &&
          other.zoom == this.zoom &&
          other.chordNotation == this.chordNotation &&
          other.performTheme == this.performTheme &&
          other.performAutoHide == this.performAutoHide &&
          other.performNotes == this.performNotes &&
          other.liveAutoReturn == this.liveAutoReturn &&
          other.practiceClick == this.practiceClick &&
          other.practiceHaptics == this.practiceHaptics &&
          other.practiceFlash == this.practiceFlash);
}

class DisplayPrefsCompanion extends UpdateCompanion<DisplayPrefsRow> {
  final Value<int> id;
  final Value<String> viewMode;
  final Value<int> zoom;
  final Value<String?> chordNotation;
  final Value<String?> performTheme;
  final Value<bool> performAutoHide;
  final Value<bool> performNotes;
  final Value<bool> liveAutoReturn;
  final Value<bool> practiceClick;
  final Value<bool> practiceHaptics;
  final Value<bool> practiceFlash;
  const DisplayPrefsCompanion({
    this.id = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.zoom = const Value.absent(),
    this.chordNotation = const Value.absent(),
    this.performTheme = const Value.absent(),
    this.performAutoHide = const Value.absent(),
    this.performNotes = const Value.absent(),
    this.liveAutoReturn = const Value.absent(),
    this.practiceClick = const Value.absent(),
    this.practiceHaptics = const Value.absent(),
    this.practiceFlash = const Value.absent(),
  });
  DisplayPrefsCompanion.insert({
    this.id = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.zoom = const Value.absent(),
    this.chordNotation = const Value.absent(),
    this.performTheme = const Value.absent(),
    this.performAutoHide = const Value.absent(),
    this.performNotes = const Value.absent(),
    this.liveAutoReturn = const Value.absent(),
    this.practiceClick = const Value.absent(),
    this.practiceHaptics = const Value.absent(),
    this.practiceFlash = const Value.absent(),
  });
  static Insertable<DisplayPrefsRow> custom({
    Expression<int>? id,
    Expression<String>? viewMode,
    Expression<int>? zoom,
    Expression<String>? chordNotation,
    Expression<String>? performTheme,
    Expression<bool>? performAutoHide,
    Expression<bool>? performNotes,
    Expression<bool>? liveAutoReturn,
    Expression<bool>? practiceClick,
    Expression<bool>? practiceHaptics,
    Expression<bool>? practiceFlash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (viewMode != null) 'view_mode': viewMode,
      if (zoom != null) 'zoom': zoom,
      if (chordNotation != null) 'chord_notation': chordNotation,
      if (performTheme != null) 'perform_theme': performTheme,
      if (performAutoHide != null) 'perform_auto_hide': performAutoHide,
      if (performNotes != null) 'perform_notes': performNotes,
      if (liveAutoReturn != null) 'live_auto_return': liveAutoReturn,
      if (practiceClick != null) 'practice_click': practiceClick,
      if (practiceHaptics != null) 'practice_haptics': practiceHaptics,
      if (practiceFlash != null) 'practice_flash': practiceFlash,
    });
  }

  DisplayPrefsCompanion copyWith({
    Value<int>? id,
    Value<String>? viewMode,
    Value<int>? zoom,
    Value<String?>? chordNotation,
    Value<String?>? performTheme,
    Value<bool>? performAutoHide,
    Value<bool>? performNotes,
    Value<bool>? liveAutoReturn,
    Value<bool>? practiceClick,
    Value<bool>? practiceHaptics,
    Value<bool>? practiceFlash,
  }) {
    return DisplayPrefsCompanion(
      id: id ?? this.id,
      viewMode: viewMode ?? this.viewMode,
      zoom: zoom ?? this.zoom,
      chordNotation: chordNotation ?? this.chordNotation,
      performTheme: performTheme ?? this.performTheme,
      performAutoHide: performAutoHide ?? this.performAutoHide,
      performNotes: performNotes ?? this.performNotes,
      liveAutoReturn: liveAutoReturn ?? this.liveAutoReturn,
      practiceClick: practiceClick ?? this.practiceClick,
      practiceHaptics: practiceHaptics ?? this.practiceHaptics,
      practiceFlash: practiceFlash ?? this.practiceFlash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (viewMode.present) {
      map['view_mode'] = Variable<String>(viewMode.value);
    }
    if (zoom.present) {
      map['zoom'] = Variable<int>(zoom.value);
    }
    if (chordNotation.present) {
      map['chord_notation'] = Variable<String>(chordNotation.value);
    }
    if (performTheme.present) {
      map['perform_theme'] = Variable<String>(performTheme.value);
    }
    if (performAutoHide.present) {
      map['perform_auto_hide'] = Variable<bool>(performAutoHide.value);
    }
    if (performNotes.present) {
      map['perform_notes'] = Variable<bool>(performNotes.value);
    }
    if (liveAutoReturn.present) {
      map['live_auto_return'] = Variable<bool>(liveAutoReturn.value);
    }
    if (practiceClick.present) {
      map['practice_click'] = Variable<bool>(practiceClick.value);
    }
    if (practiceHaptics.present) {
      map['practice_haptics'] = Variable<bool>(practiceHaptics.value);
    }
    if (practiceFlash.present) {
      map['practice_flash'] = Variable<bool>(practiceFlash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisplayPrefsCompanion(')
          ..write('id: $id, ')
          ..write('viewMode: $viewMode, ')
          ..write('zoom: $zoom, ')
          ..write('chordNotation: $chordNotation, ')
          ..write('performTheme: $performTheme, ')
          ..write('performAutoHide: $performAutoHide, ')
          ..write('performNotes: $performNotes, ')
          ..write('liveAutoReturn: $liveAutoReturn, ')
          ..write('practiceClick: $practiceClick, ')
          ..write('practiceHaptics: $practiceHaptics, ')
          ..write('practiceFlash: $practiceFlash')
          ..write(')'))
        .toString();
  }
}

class $LineUpsTable extends LineUps with TableInfo<$LineUpsTable, LineUpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineUpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _worshipLeaderMeta = const VerificationMeta(
    'worshipLeader',
  );
  @override
  late final GeneratedColumn<String> worshipLeader = GeneratedColumn<String>(
    'worship_leader',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songsCountMeta = const VerificationMeta(
    'songsCount',
  );
  @override
  late final GeneratedColumn<int> songsCount = GeneratedColumn<int>(
    'songs_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _songsVersionMeta = const VerificationMeta(
    'songsVersion',
  );
  @override
  late final GeneratedColumn<int> songsVersion = GeneratedColumn<int>(
    'songs_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songsLoadedMeta = const VerificationMeta(
    'songsLoaded',
  );
  @override
  late final GeneratedColumn<bool> songsLoaded = GeneratedColumn<bool>(
    'songs_loaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("songs_loaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    title,
    date,
    worshipLeader,
    songsCount,
    version,
    songsVersion,
    songsLoaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_ups';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineUpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('worship_leader')) {
      context.handle(
        _worshipLeaderMeta,
        worshipLeader.isAcceptableOrUnknown(
          data['worship_leader']!,
          _worshipLeaderMeta,
        ),
      );
    }
    if (data.containsKey('songs_count')) {
      context.handle(
        _songsCountMeta,
        songsCount.isAcceptableOrUnknown(data['songs_count']!, _songsCountMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('songs_version')) {
      context.handle(
        _songsVersionMeta,
        songsVersion.isAcceptableOrUnknown(
          data['songs_version']!,
          _songsVersionMeta,
        ),
      );
    }
    if (data.containsKey('songs_loaded')) {
      context.handle(
        _songsLoadedMeta,
        songsLoaded.isAcceptableOrUnknown(
          data['songs_loaded']!,
          _songsLoadedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineUpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineUpRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      worshipLeader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worship_leader'],
      ),
      songsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}songs_count'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      songsVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}songs_version'],
      ),
      songsLoaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}songs_loaded'],
      )!,
    );
  }

  @override
  $LineUpsTable createAlias(String alias) {
    return $LineUpsTable(attachedDatabase, alias);
  }
}

class LineUpRow extends DataClass implements Insertable<LineUpRow> {
  final int id;
  final int workspaceId;
  final String title;

  /// `YYYY-MM-DD`, compared as text like the web does.
  final String date;
  final String? worshipLeader;
  final int songsCount;

  /// The server's version (details, set, keys, notes, arrangement).
  final int version;

  /// The [version] the cached songs came from; older: refetch the set.
  final int? songsVersion;

  /// Whether [LineUpSongs] holds this line-up's songs. The list endpoint
  /// carries only a count, so songs arrive with the detail (or a local edit).
  final bool songsLoaded;
  const LineUpRow({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.date,
    this.worshipLeader,
    required this.songsCount,
    required this.version,
    this.songsVersion,
    required this.songsLoaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || worshipLeader != null) {
      map['worship_leader'] = Variable<String>(worshipLeader);
    }
    map['songs_count'] = Variable<int>(songsCount);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || songsVersion != null) {
      map['songs_version'] = Variable<int>(songsVersion);
    }
    map['songs_loaded'] = Variable<bool>(songsLoaded);
    return map;
  }

  LineUpsCompanion toCompanion(bool nullToAbsent) {
    return LineUpsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      title: Value(title),
      date: Value(date),
      worshipLeader: worshipLeader == null && nullToAbsent
          ? const Value.absent()
          : Value(worshipLeader),
      songsCount: Value(songsCount),
      version: Value(version),
      songsVersion: songsVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(songsVersion),
      songsLoaded: Value(songsLoaded),
    );
  }

  factory LineUpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineUpRow(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      worshipLeader: serializer.fromJson<String?>(json['worshipLeader']),
      songsCount: serializer.fromJson<int>(json['songsCount']),
      version: serializer.fromJson<int>(json['version']),
      songsVersion: serializer.fromJson<int?>(json['songsVersion']),
      songsLoaded: serializer.fromJson<bool>(json['songsLoaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'worshipLeader': serializer.toJson<String?>(worshipLeader),
      'songsCount': serializer.toJson<int>(songsCount),
      'version': serializer.toJson<int>(version),
      'songsVersion': serializer.toJson<int?>(songsVersion),
      'songsLoaded': serializer.toJson<bool>(songsLoaded),
    };
  }

  LineUpRow copyWith({
    int? id,
    int? workspaceId,
    String? title,
    String? date,
    Value<String?> worshipLeader = const Value.absent(),
    int? songsCount,
    int? version,
    Value<int?> songsVersion = const Value.absent(),
    bool? songsLoaded,
  }) => LineUpRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    date: date ?? this.date,
    worshipLeader: worshipLeader.present
        ? worshipLeader.value
        : this.worshipLeader,
    songsCount: songsCount ?? this.songsCount,
    version: version ?? this.version,
    songsVersion: songsVersion.present ? songsVersion.value : this.songsVersion,
    songsLoaded: songsLoaded ?? this.songsLoaded,
  );
  LineUpRow copyWithCompanion(LineUpsCompanion data) {
    return LineUpRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      worshipLeader: data.worshipLeader.present
          ? data.worshipLeader.value
          : this.worshipLeader,
      songsCount: data.songsCount.present
          ? data.songsCount.value
          : this.songsCount,
      version: data.version.present ? data.version.value : this.version,
      songsVersion: data.songsVersion.present
          ? data.songsVersion.value
          : this.songsVersion,
      songsLoaded: data.songsLoaded.present
          ? data.songsLoaded.value
          : this.songsLoaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineUpRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('worshipLeader: $worshipLeader, ')
          ..write('songsCount: $songsCount, ')
          ..write('version: $version, ')
          ..write('songsVersion: $songsVersion, ')
          ..write('songsLoaded: $songsLoaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    title,
    date,
    worshipLeader,
    songsCount,
    version,
    songsVersion,
    songsLoaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineUpRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.date == this.date &&
          other.worshipLeader == this.worshipLeader &&
          other.songsCount == this.songsCount &&
          other.version == this.version &&
          other.songsVersion == this.songsVersion &&
          other.songsLoaded == this.songsLoaded);
}

class LineUpsCompanion extends UpdateCompanion<LineUpRow> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> title;
  final Value<String> date;
  final Value<String?> worshipLeader;
  final Value<int> songsCount;
  final Value<int> version;
  final Value<int?> songsVersion;
  final Value<bool> songsLoaded;
  const LineUpsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.worshipLeader = const Value.absent(),
    this.songsCount = const Value.absent(),
    this.version = const Value.absent(),
    this.songsVersion = const Value.absent(),
    this.songsLoaded = const Value.absent(),
  });
  LineUpsCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String title,
    required String date,
    this.worshipLeader = const Value.absent(),
    this.songsCount = const Value.absent(),
    this.version = const Value.absent(),
    this.songsVersion = const Value.absent(),
    this.songsLoaded = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       title = Value(title),
       date = Value(date);
  static Insertable<LineUpRow> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? worshipLeader,
    Expression<int>? songsCount,
    Expression<int>? version,
    Expression<int>? songsVersion,
    Expression<bool>? songsLoaded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (worshipLeader != null) 'worship_leader': worshipLeader,
      if (songsCount != null) 'songs_count': songsCount,
      if (version != null) 'version': version,
      if (songsVersion != null) 'songs_version': songsVersion,
      if (songsLoaded != null) 'songs_loaded': songsLoaded,
    });
  }

  LineUpsCompanion copyWith({
    Value<int>? id,
    Value<int>? workspaceId,
    Value<String>? title,
    Value<String>? date,
    Value<String?>? worshipLeader,
    Value<int>? songsCount,
    Value<int>? version,
    Value<int?>? songsVersion,
    Value<bool>? songsLoaded,
  }) {
    return LineUpsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      date: date ?? this.date,
      worshipLeader: worshipLeader ?? this.worshipLeader,
      songsCount: songsCount ?? this.songsCount,
      version: version ?? this.version,
      songsVersion: songsVersion ?? this.songsVersion,
      songsLoaded: songsLoaded ?? this.songsLoaded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (worshipLeader.present) {
      map['worship_leader'] = Variable<String>(worshipLeader.value);
    }
    if (songsCount.present) {
      map['songs_count'] = Variable<int>(songsCount.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (songsVersion.present) {
      map['songs_version'] = Variable<int>(songsVersion.value);
    }
    if (songsLoaded.present) {
      map['songs_loaded'] = Variable<bool>(songsLoaded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineUpsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('worshipLeader: $worshipLeader, ')
          ..write('songsCount: $songsCount, ')
          ..write('version: $version, ')
          ..write('songsVersion: $songsVersion, ')
          ..write('songsLoaded: $songsLoaded')
          ..write(')'))
        .toString();
  }
}

class $LineUpSongsTable extends LineUpSongs
    with TableInfo<$LineUpSongsTable, LineUpSongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineUpSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lineUpIdMeta = const VerificationMeta(
    'lineUpId',
  );
  @override
  late final GeneratedColumn<int> lineUpId = GeneratedColumn<int>(
    'line_up_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transpositionMeta = const VerificationMeta(
    'transposition',
  );
  @override
  late final GeneratedColumn<int> transposition = GeneratedColumn<int>(
    'transposition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineUpSongIdMeta = const VerificationMeta(
    'lineUpSongId',
  );
  @override
  late final GeneratedColumn<int> lineUpSongId = GeneratedColumn<int>(
    'line_up_song_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectionArrangementMeta =
      const VerificationMeta('sectionArrangement');
  @override
  late final GeneratedColumn<String> sectionArrangement =
      GeneratedColumn<String>(
        'section_arrangement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    lineUpId,
    position,
    songId,
    transposition,
    lineUpSongId,
    notes,
    sectionArrangement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_up_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineUpSongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('line_up_id')) {
      context.handle(
        _lineUpIdMeta,
        lineUpId.isAcceptableOrUnknown(data['line_up_id']!, _lineUpIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineUpIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('transposition')) {
      context.handle(
        _transpositionMeta,
        transposition.isAcceptableOrUnknown(
          data['transposition']!,
          _transpositionMeta,
        ),
      );
    }
    if (data.containsKey('line_up_song_id')) {
      context.handle(
        _lineUpSongIdMeta,
        lineUpSongId.isAcceptableOrUnknown(
          data['line_up_song_id']!,
          _lineUpSongIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('section_arrangement')) {
      context.handle(
        _sectionArrangementMeta,
        sectionArrangement.isAcceptableOrUnknown(
          data['section_arrangement']!,
          _sectionArrangementMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lineUpId, position};
  @override
  LineUpSongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineUpSongRow(
      lineUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      transposition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transposition'],
      )!,
      lineUpSongId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_song_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sectionArrangement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_arrangement'],
      ),
    );
  }

  @override
  $LineUpSongsTable createAlias(String alias) {
    return $LineUpSongsTable(attachedDatabase, alias);
  }
}

class LineUpSongRow extends DataClass implements Insertable<LineUpSongRow> {
  final int lineUpId;
  final int position;
  final int songId;
  final int transposition;

  /// The server's pivot id; null until the server has seen this entry.
  final int? lineUpSongId;

  /// Team notes as the server's JSON list (`[{id, line, text}]`); null: none.
  final String? notes;

  /// The server's `section_arrangement` JSON; null: play as written.
  final String? sectionArrangement;
  const LineUpSongRow({
    required this.lineUpId,
    required this.position,
    required this.songId,
    required this.transposition,
    this.lineUpSongId,
    this.notes,
    this.sectionArrangement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['line_up_id'] = Variable<int>(lineUpId);
    map['position'] = Variable<int>(position);
    map['song_id'] = Variable<int>(songId);
    map['transposition'] = Variable<int>(transposition);
    if (!nullToAbsent || lineUpSongId != null) {
      map['line_up_song_id'] = Variable<int>(lineUpSongId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || sectionArrangement != null) {
      map['section_arrangement'] = Variable<String>(sectionArrangement);
    }
    return map;
  }

  LineUpSongsCompanion toCompanion(bool nullToAbsent) {
    return LineUpSongsCompanion(
      lineUpId: Value(lineUpId),
      position: Value(position),
      songId: Value(songId),
      transposition: Value(transposition),
      lineUpSongId: lineUpSongId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineUpSongId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sectionArrangement: sectionArrangement == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionArrangement),
    );
  }

  factory LineUpSongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineUpSongRow(
      lineUpId: serializer.fromJson<int>(json['lineUpId']),
      position: serializer.fromJson<int>(json['position']),
      songId: serializer.fromJson<int>(json['songId']),
      transposition: serializer.fromJson<int>(json['transposition']),
      lineUpSongId: serializer.fromJson<int?>(json['lineUpSongId']),
      notes: serializer.fromJson<String?>(json['notes']),
      sectionArrangement: serializer.fromJson<String?>(
        json['sectionArrangement'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lineUpId': serializer.toJson<int>(lineUpId),
      'position': serializer.toJson<int>(position),
      'songId': serializer.toJson<int>(songId),
      'transposition': serializer.toJson<int>(transposition),
      'lineUpSongId': serializer.toJson<int?>(lineUpSongId),
      'notes': serializer.toJson<String?>(notes),
      'sectionArrangement': serializer.toJson<String?>(sectionArrangement),
    };
  }

  LineUpSongRow copyWith({
    int? lineUpId,
    int? position,
    int? songId,
    int? transposition,
    Value<int?> lineUpSongId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> sectionArrangement = const Value.absent(),
  }) => LineUpSongRow(
    lineUpId: lineUpId ?? this.lineUpId,
    position: position ?? this.position,
    songId: songId ?? this.songId,
    transposition: transposition ?? this.transposition,
    lineUpSongId: lineUpSongId.present ? lineUpSongId.value : this.lineUpSongId,
    notes: notes.present ? notes.value : this.notes,
    sectionArrangement: sectionArrangement.present
        ? sectionArrangement.value
        : this.sectionArrangement,
  );
  LineUpSongRow copyWithCompanion(LineUpSongsCompanion data) {
    return LineUpSongRow(
      lineUpId: data.lineUpId.present ? data.lineUpId.value : this.lineUpId,
      position: data.position.present ? data.position.value : this.position,
      songId: data.songId.present ? data.songId.value : this.songId,
      transposition: data.transposition.present
          ? data.transposition.value
          : this.transposition,
      lineUpSongId: data.lineUpSongId.present
          ? data.lineUpSongId.value
          : this.lineUpSongId,
      notes: data.notes.present ? data.notes.value : this.notes,
      sectionArrangement: data.sectionArrangement.present
          ? data.sectionArrangement.value
          : this.sectionArrangement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineUpSongRow(')
          ..write('lineUpId: $lineUpId, ')
          ..write('position: $position, ')
          ..write('songId: $songId, ')
          ..write('transposition: $transposition, ')
          ..write('lineUpSongId: $lineUpSongId, ')
          ..write('notes: $notes, ')
          ..write('sectionArrangement: $sectionArrangement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lineUpId,
    position,
    songId,
    transposition,
    lineUpSongId,
    notes,
    sectionArrangement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineUpSongRow &&
          other.lineUpId == this.lineUpId &&
          other.position == this.position &&
          other.songId == this.songId &&
          other.transposition == this.transposition &&
          other.lineUpSongId == this.lineUpSongId &&
          other.notes == this.notes &&
          other.sectionArrangement == this.sectionArrangement);
}

class LineUpSongsCompanion extends UpdateCompanion<LineUpSongRow> {
  final Value<int> lineUpId;
  final Value<int> position;
  final Value<int> songId;
  final Value<int> transposition;
  final Value<int?> lineUpSongId;
  final Value<String?> notes;
  final Value<String?> sectionArrangement;
  final Value<int> rowid;
  const LineUpSongsCompanion({
    this.lineUpId = const Value.absent(),
    this.position = const Value.absent(),
    this.songId = const Value.absent(),
    this.transposition = const Value.absent(),
    this.lineUpSongId = const Value.absent(),
    this.notes = const Value.absent(),
    this.sectionArrangement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineUpSongsCompanion.insert({
    required int lineUpId,
    required int position,
    required int songId,
    this.transposition = const Value.absent(),
    this.lineUpSongId = const Value.absent(),
    this.notes = const Value.absent(),
    this.sectionArrangement = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lineUpId = Value(lineUpId),
       position = Value(position),
       songId = Value(songId);
  static Insertable<LineUpSongRow> custom({
    Expression<int>? lineUpId,
    Expression<int>? position,
    Expression<int>? songId,
    Expression<int>? transposition,
    Expression<int>? lineUpSongId,
    Expression<String>? notes,
    Expression<String>? sectionArrangement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lineUpId != null) 'line_up_id': lineUpId,
      if (position != null) 'position': position,
      if (songId != null) 'song_id': songId,
      if (transposition != null) 'transposition': transposition,
      if (lineUpSongId != null) 'line_up_song_id': lineUpSongId,
      if (notes != null) 'notes': notes,
      if (sectionArrangement != null) 'section_arrangement': sectionArrangement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineUpSongsCompanion copyWith({
    Value<int>? lineUpId,
    Value<int>? position,
    Value<int>? songId,
    Value<int>? transposition,
    Value<int?>? lineUpSongId,
    Value<String?>? notes,
    Value<String?>? sectionArrangement,
    Value<int>? rowid,
  }) {
    return LineUpSongsCompanion(
      lineUpId: lineUpId ?? this.lineUpId,
      position: position ?? this.position,
      songId: songId ?? this.songId,
      transposition: transposition ?? this.transposition,
      lineUpSongId: lineUpSongId ?? this.lineUpSongId,
      notes: notes ?? this.notes,
      sectionArrangement: sectionArrangement ?? this.sectionArrangement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lineUpId.present) {
      map['line_up_id'] = Variable<int>(lineUpId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (transposition.present) {
      map['transposition'] = Variable<int>(transposition.value);
    }
    if (lineUpSongId.present) {
      map['line_up_song_id'] = Variable<int>(lineUpSongId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sectionArrangement.present) {
      map['section_arrangement'] = Variable<String>(sectionArrangement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineUpSongsCompanion(')
          ..write('lineUpId: $lineUpId, ')
          ..write('position: $position, ')
          ..write('songId: $songId, ')
          ..write('transposition: $transposition, ')
          ..write('lineUpSongId: $lineUpSongId, ')
          ..write('notes: $notes, ')
          ..write('sectionArrangement: $sectionArrangement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineUpSongCaposTable extends LineUpSongCapos
    with TableInfo<$LineUpSongCaposTable, LineUpSongCapoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineUpSongCaposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lineUpSongIdMeta = const VerificationMeta(
    'lineUpSongId',
  );
  @override
  late final GeneratedColumn<int> lineUpSongId = GeneratedColumn<int>(
    'line_up_song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineUpIdMeta = const VerificationMeta(
    'lineUpId',
  );
  @override
  late final GeneratedColumn<int> lineUpId = GeneratedColumn<int>(
    'line_up_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capoMeta = const VerificationMeta('capo');
  @override
  late final GeneratedColumn<int> capo = GeneratedColumn<int>(
    'capo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [lineUpSongId, lineUpId, capo, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_up_song_capos';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineUpSongCapoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('line_up_song_id')) {
      context.handle(
        _lineUpSongIdMeta,
        lineUpSongId.isAcceptableOrUnknown(
          data['line_up_song_id']!,
          _lineUpSongIdMeta,
        ),
      );
    }
    if (data.containsKey('line_up_id')) {
      context.handle(
        _lineUpIdMeta,
        lineUpId.isAcceptableOrUnknown(data['line_up_id']!, _lineUpIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineUpIdMeta);
    }
    if (data.containsKey('capo')) {
      context.handle(
        _capoMeta,
        capo.isAcceptableOrUnknown(data['capo']!, _capoMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lineUpSongId};
  @override
  LineUpSongCapoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineUpSongCapoRow(
      lineUpSongId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_song_id'],
      )!,
      lineUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_id'],
      )!,
      capo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capo'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $LineUpSongCaposTable createAlias(String alias) {
    return $LineUpSongCaposTable(attachedDatabase, alias);
  }
}

class LineUpSongCapoRow extends DataClass
    implements Insertable<LineUpSongCapoRow> {
  final int lineUpSongId;
  final int lineUpId;
  final int capo;
  final bool dirty;
  const LineUpSongCapoRow({
    required this.lineUpSongId,
    required this.lineUpId,
    required this.capo,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['line_up_song_id'] = Variable<int>(lineUpSongId);
    map['line_up_id'] = Variable<int>(lineUpId);
    map['capo'] = Variable<int>(capo);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  LineUpSongCaposCompanion toCompanion(bool nullToAbsent) {
    return LineUpSongCaposCompanion(
      lineUpSongId: Value(lineUpSongId),
      lineUpId: Value(lineUpId),
      capo: Value(capo),
      dirty: Value(dirty),
    );
  }

  factory LineUpSongCapoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineUpSongCapoRow(
      lineUpSongId: serializer.fromJson<int>(json['lineUpSongId']),
      lineUpId: serializer.fromJson<int>(json['lineUpId']),
      capo: serializer.fromJson<int>(json['capo']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lineUpSongId': serializer.toJson<int>(lineUpSongId),
      'lineUpId': serializer.toJson<int>(lineUpId),
      'capo': serializer.toJson<int>(capo),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  LineUpSongCapoRow copyWith({
    int? lineUpSongId,
    int? lineUpId,
    int? capo,
    bool? dirty,
  }) => LineUpSongCapoRow(
    lineUpSongId: lineUpSongId ?? this.lineUpSongId,
    lineUpId: lineUpId ?? this.lineUpId,
    capo: capo ?? this.capo,
    dirty: dirty ?? this.dirty,
  );
  LineUpSongCapoRow copyWithCompanion(LineUpSongCaposCompanion data) {
    return LineUpSongCapoRow(
      lineUpSongId: data.lineUpSongId.present
          ? data.lineUpSongId.value
          : this.lineUpSongId,
      lineUpId: data.lineUpId.present ? data.lineUpId.value : this.lineUpId,
      capo: data.capo.present ? data.capo.value : this.capo,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineUpSongCapoRow(')
          ..write('lineUpSongId: $lineUpSongId, ')
          ..write('lineUpId: $lineUpId, ')
          ..write('capo: $capo, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lineUpSongId, lineUpId, capo, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineUpSongCapoRow &&
          other.lineUpSongId == this.lineUpSongId &&
          other.lineUpId == this.lineUpId &&
          other.capo == this.capo &&
          other.dirty == this.dirty);
}

class LineUpSongCaposCompanion extends UpdateCompanion<LineUpSongCapoRow> {
  final Value<int> lineUpSongId;
  final Value<int> lineUpId;
  final Value<int> capo;
  final Value<bool> dirty;
  const LineUpSongCaposCompanion({
    this.lineUpSongId = const Value.absent(),
    this.lineUpId = const Value.absent(),
    this.capo = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  LineUpSongCaposCompanion.insert({
    this.lineUpSongId = const Value.absent(),
    required int lineUpId,
    this.capo = const Value.absent(),
    this.dirty = const Value.absent(),
  }) : lineUpId = Value(lineUpId);
  static Insertable<LineUpSongCapoRow> custom({
    Expression<int>? lineUpSongId,
    Expression<int>? lineUpId,
    Expression<int>? capo,
    Expression<bool>? dirty,
  }) {
    return RawValuesInsertable({
      if (lineUpSongId != null) 'line_up_song_id': lineUpSongId,
      if (lineUpId != null) 'line_up_id': lineUpId,
      if (capo != null) 'capo': capo,
      if (dirty != null) 'dirty': dirty,
    });
  }

  LineUpSongCaposCompanion copyWith({
    Value<int>? lineUpSongId,
    Value<int>? lineUpId,
    Value<int>? capo,
    Value<bool>? dirty,
  }) {
    return LineUpSongCaposCompanion(
      lineUpSongId: lineUpSongId ?? this.lineUpSongId,
      lineUpId: lineUpId ?? this.lineUpId,
      capo: capo ?? this.capo,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lineUpSongId.present) {
      map['line_up_song_id'] = Variable<int>(lineUpSongId.value);
    }
    if (lineUpId.present) {
      map['line_up_id'] = Variable<int>(lineUpId.value);
    }
    if (capo.present) {
      map['capo'] = Variable<int>(capo.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineUpSongCaposCompanion(')
          ..write('lineUpSongId: $lineUpSongId, ')
          ..write('lineUpId: $lineUpId, ')
          ..write('capo: $capo, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }
}

class $LineUpOutboxTable extends LineUpOutbox
    with TableInfo<$LineUpOutboxTable, LineUpOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineUpOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lineUpIdMeta = const VerificationMeta(
    'lineUpId',
  );
  @override
  late final GeneratedColumn<int> lineUpId = GeneratedColumn<int>(
    'line_up_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedColumn<bool> isNew = GeneratedColumn<bool>(
    'is_new',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_new" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detailsDirtyMeta = const VerificationMeta(
    'detailsDirty',
  );
  @override
  late final GeneratedColumn<bool> detailsDirty = GeneratedColumn<bool>(
    'details_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("details_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _songsDirtyMeta = const VerificationMeta(
    'songsDirty',
  );
  @override
  late final GeneratedColumn<bool> songsDirty = GeneratedColumn<bool>(
    'songs_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("songs_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _baseSongIdsMeta = const VerificationMeta(
    'baseSongIds',
  );
  @override
  late final GeneratedColumn<String> baseSongIds = GeneratedColumn<String>(
    'base_song_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lineUpId,
    workspaceId,
    isNew,
    detailsDirty,
    songsDirty,
    baseSongIds,
    createdAt,
    updatedAt,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_up_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineUpOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('line_up_id')) {
      context.handle(
        _lineUpIdMeta,
        lineUpId.isAcceptableOrUnknown(data['line_up_id']!, _lineUpIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('is_new')) {
      context.handle(
        _isNewMeta,
        isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta),
      );
    }
    if (data.containsKey('details_dirty')) {
      context.handle(
        _detailsDirtyMeta,
        detailsDirty.isAcceptableOrUnknown(
          data['details_dirty']!,
          _detailsDirtyMeta,
        ),
      );
    }
    if (data.containsKey('songs_dirty')) {
      context.handle(
        _songsDirtyMeta,
        songsDirty.isAcceptableOrUnknown(data['songs_dirty']!, _songsDirtyMeta),
      );
    }
    if (data.containsKey('base_song_ids')) {
      context.handle(
        _baseSongIdsMeta,
        baseSongIds.isAcceptableOrUnknown(
          data['base_song_ids']!,
          _baseSongIdsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lineUpId};
  @override
  LineUpOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineUpOutboxRow(
      lineUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      isNew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_new'],
      )!,
      detailsDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}details_dirty'],
      )!,
      songsDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}songs_dirty'],
      )!,
      baseSongIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_song_ids'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $LineUpOutboxTable createAlias(String alias) {
    return $LineUpOutboxTable(attachedDatabase, alias);
  }
}

class LineUpOutboxRow extends DataClass implements Insertable<LineUpOutboxRow> {
  final int lineUpId;
  final int workspaceId;
  final bool isNew;
  final bool detailsDirty;
  final bool songsDirty;

  /// JSON list of the set's song ids as the server had them when [songsDirty]
  /// was first set — the set PUT's `base_song_ids`.
  final String? baseSongIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Why the server last refused it (null: just waiting).
  final String? error;
  const LineUpOutboxRow({
    required this.lineUpId,
    required this.workspaceId,
    required this.isNew,
    required this.detailsDirty,
    required this.songsDirty,
    this.baseSongIds,
    required this.createdAt,
    required this.updatedAt,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['line_up_id'] = Variable<int>(lineUpId);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['is_new'] = Variable<bool>(isNew);
    map['details_dirty'] = Variable<bool>(detailsDirty);
    map['songs_dirty'] = Variable<bool>(songsDirty);
    if (!nullToAbsent || baseSongIds != null) {
      map['base_song_ids'] = Variable<String>(baseSongIds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  LineUpOutboxCompanion toCompanion(bool nullToAbsent) {
    return LineUpOutboxCompanion(
      lineUpId: Value(lineUpId),
      workspaceId: Value(workspaceId),
      isNew: Value(isNew),
      detailsDirty: Value(detailsDirty),
      songsDirty: Value(songsDirty),
      baseSongIds: baseSongIds == null && nullToAbsent
          ? const Value.absent()
          : Value(baseSongIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory LineUpOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineUpOutboxRow(
      lineUpId: serializer.fromJson<int>(json['lineUpId']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      isNew: serializer.fromJson<bool>(json['isNew']),
      detailsDirty: serializer.fromJson<bool>(json['detailsDirty']),
      songsDirty: serializer.fromJson<bool>(json['songsDirty']),
      baseSongIds: serializer.fromJson<String?>(json['baseSongIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lineUpId': serializer.toJson<int>(lineUpId),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'isNew': serializer.toJson<bool>(isNew),
      'detailsDirty': serializer.toJson<bool>(detailsDirty),
      'songsDirty': serializer.toJson<bool>(songsDirty),
      'baseSongIds': serializer.toJson<String?>(baseSongIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'error': serializer.toJson<String?>(error),
    };
  }

  LineUpOutboxRow copyWith({
    int? lineUpId,
    int? workspaceId,
    bool? isNew,
    bool? detailsDirty,
    bool? songsDirty,
    Value<String?> baseSongIds = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> error = const Value.absent(),
  }) => LineUpOutboxRow(
    lineUpId: lineUpId ?? this.lineUpId,
    workspaceId: workspaceId ?? this.workspaceId,
    isNew: isNew ?? this.isNew,
    detailsDirty: detailsDirty ?? this.detailsDirty,
    songsDirty: songsDirty ?? this.songsDirty,
    baseSongIds: baseSongIds.present ? baseSongIds.value : this.baseSongIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    error: error.present ? error.value : this.error,
  );
  LineUpOutboxRow copyWithCompanion(LineUpOutboxCompanion data) {
    return LineUpOutboxRow(
      lineUpId: data.lineUpId.present ? data.lineUpId.value : this.lineUpId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      isNew: data.isNew.present ? data.isNew.value : this.isNew,
      detailsDirty: data.detailsDirty.present
          ? data.detailsDirty.value
          : this.detailsDirty,
      songsDirty: data.songsDirty.present
          ? data.songsDirty.value
          : this.songsDirty,
      baseSongIds: data.baseSongIds.present
          ? data.baseSongIds.value
          : this.baseSongIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineUpOutboxRow(')
          ..write('lineUpId: $lineUpId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('isNew: $isNew, ')
          ..write('detailsDirty: $detailsDirty, ')
          ..write('songsDirty: $songsDirty, ')
          ..write('baseSongIds: $baseSongIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lineUpId,
    workspaceId,
    isNew,
    detailsDirty,
    songsDirty,
    baseSongIds,
    createdAt,
    updatedAt,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineUpOutboxRow &&
          other.lineUpId == this.lineUpId &&
          other.workspaceId == this.workspaceId &&
          other.isNew == this.isNew &&
          other.detailsDirty == this.detailsDirty &&
          other.songsDirty == this.songsDirty &&
          other.baseSongIds == this.baseSongIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.error == this.error);
}

class LineUpOutboxCompanion extends UpdateCompanion<LineUpOutboxRow> {
  final Value<int> lineUpId;
  final Value<int> workspaceId;
  final Value<bool> isNew;
  final Value<bool> detailsDirty;
  final Value<bool> songsDirty;
  final Value<String?> baseSongIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> error;
  const LineUpOutboxCompanion({
    this.lineUpId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.isNew = const Value.absent(),
    this.detailsDirty = const Value.absent(),
    this.songsDirty = const Value.absent(),
    this.baseSongIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.error = const Value.absent(),
  });
  LineUpOutboxCompanion.insert({
    this.lineUpId = const Value.absent(),
    required int workspaceId,
    this.isNew = const Value.absent(),
    this.detailsDirty = const Value.absent(),
    this.songsDirty = const Value.absent(),
    this.baseSongIds = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.error = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LineUpOutboxRow> custom({
    Expression<int>? lineUpId,
    Expression<int>? workspaceId,
    Expression<bool>? isNew,
    Expression<bool>? detailsDirty,
    Expression<bool>? songsDirty,
    Expression<String>? baseSongIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (lineUpId != null) 'line_up_id': lineUpId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (isNew != null) 'is_new': isNew,
      if (detailsDirty != null) 'details_dirty': detailsDirty,
      if (songsDirty != null) 'songs_dirty': songsDirty,
      if (baseSongIds != null) 'base_song_ids': baseSongIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (error != null) 'error': error,
    });
  }

  LineUpOutboxCompanion copyWith({
    Value<int>? lineUpId,
    Value<int>? workspaceId,
    Value<bool>? isNew,
    Value<bool>? detailsDirty,
    Value<bool>? songsDirty,
    Value<String?>? baseSongIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? error,
  }) {
    return LineUpOutboxCompanion(
      lineUpId: lineUpId ?? this.lineUpId,
      workspaceId: workspaceId ?? this.workspaceId,
      isNew: isNew ?? this.isNew,
      detailsDirty: detailsDirty ?? this.detailsDirty,
      songsDirty: songsDirty ?? this.songsDirty,
      baseSongIds: baseSongIds ?? this.baseSongIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lineUpId.present) {
      map['line_up_id'] = Variable<int>(lineUpId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (detailsDirty.present) {
      map['details_dirty'] = Variable<bool>(detailsDirty.value);
    }
    if (songsDirty.present) {
      map['songs_dirty'] = Variable<bool>(songsDirty.value);
    }
    if (baseSongIds.present) {
      map['base_song_ids'] = Variable<String>(baseSongIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineUpOutboxCompanion(')
          ..write('lineUpId: $lineUpId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('isNew: $isNew, ')
          ..write('detailsDirty: $detailsDirty, ')
          ..write('songsDirty: $songsDirty, ')
          ..write('baseSongIds: $baseSongIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $LineUpPrepOutboxTable extends LineUpPrepOutbox
    with TableInfo<$LineUpPrepOutboxTable, LineUpPrepOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineUpPrepOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lineUpIdMeta = const VerificationMeta(
    'lineUpId',
  );
  @override
  late final GeneratedColumn<int> lineUpId = GeneratedColumn<int>(
    'line_up_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<String> base = GeneratedColumn<String>(
    'base',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lineUpId,
    songId,
    kind,
    updatedAt,
    base,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_up_prep_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineUpPrepOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('line_up_id')) {
      context.handle(
        _lineUpIdMeta,
        lineUpId.isAcceptableOrUnknown(data['line_up_id']!, _lineUpIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineUpIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('base')) {
      context.handle(
        _baseMeta,
        base.isAcceptableOrUnknown(data['base']!, _baseMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lineUpId, songId, kind};
  @override
  LineUpPrepOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineUpPrepOutboxRow(
      lineUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_up_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      base: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $LineUpPrepOutboxTable createAlias(String alias) {
    return $LineUpPrepOutboxTable(attachedDatabase, alias);
  }
}

class LineUpPrepOutboxRow extends DataClass
    implements Insertable<LineUpPrepOutboxRow> {
  final int lineUpId;
  final int songId;

  /// `note:<id>` (one note, added/edited or deleted), `notes` (the whole
  /// list, from before schema 10), or an arrangement view: `chords` / `lyrics`.
  final String kind;
  final DateTime updatedAt;

  /// For an arrangement: JSON `{order, removed}` as the server had the view
  /// when this device first changed it — the PATCH's `base`.
  final String? base;

  /// Why the server last refused it (null: just waiting).
  final String? error;
  const LineUpPrepOutboxRow({
    required this.lineUpId,
    required this.songId,
    required this.kind,
    required this.updatedAt,
    this.base,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['line_up_id'] = Variable<int>(lineUpId);
    map['song_id'] = Variable<int>(songId);
    map['kind'] = Variable<String>(kind);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || base != null) {
      map['base'] = Variable<String>(base);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  LineUpPrepOutboxCompanion toCompanion(bool nullToAbsent) {
    return LineUpPrepOutboxCompanion(
      lineUpId: Value(lineUpId),
      songId: Value(songId),
      kind: Value(kind),
      updatedAt: Value(updatedAt),
      base: base == null && nullToAbsent ? const Value.absent() : Value(base),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory LineUpPrepOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineUpPrepOutboxRow(
      lineUpId: serializer.fromJson<int>(json['lineUpId']),
      songId: serializer.fromJson<int>(json['songId']),
      kind: serializer.fromJson<String>(json['kind']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      base: serializer.fromJson<String?>(json['base']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lineUpId': serializer.toJson<int>(lineUpId),
      'songId': serializer.toJson<int>(songId),
      'kind': serializer.toJson<String>(kind),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'base': serializer.toJson<String?>(base),
      'error': serializer.toJson<String?>(error),
    };
  }

  LineUpPrepOutboxRow copyWith({
    int? lineUpId,
    int? songId,
    String? kind,
    DateTime? updatedAt,
    Value<String?> base = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => LineUpPrepOutboxRow(
    lineUpId: lineUpId ?? this.lineUpId,
    songId: songId ?? this.songId,
    kind: kind ?? this.kind,
    updatedAt: updatedAt ?? this.updatedAt,
    base: base.present ? base.value : this.base,
    error: error.present ? error.value : this.error,
  );
  LineUpPrepOutboxRow copyWithCompanion(LineUpPrepOutboxCompanion data) {
    return LineUpPrepOutboxRow(
      lineUpId: data.lineUpId.present ? data.lineUpId.value : this.lineUpId,
      songId: data.songId.present ? data.songId.value : this.songId,
      kind: data.kind.present ? data.kind.value : this.kind,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      base: data.base.present ? data.base.value : this.base,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineUpPrepOutboxRow(')
          ..write('lineUpId: $lineUpId, ')
          ..write('songId: $songId, ')
          ..write('kind: $kind, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('base: $base, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(lineUpId, songId, kind, updatedAt, base, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineUpPrepOutboxRow &&
          other.lineUpId == this.lineUpId &&
          other.songId == this.songId &&
          other.kind == this.kind &&
          other.updatedAt == this.updatedAt &&
          other.base == this.base &&
          other.error == this.error);
}

class LineUpPrepOutboxCompanion extends UpdateCompanion<LineUpPrepOutboxRow> {
  final Value<int> lineUpId;
  final Value<int> songId;
  final Value<String> kind;
  final Value<DateTime> updatedAt;
  final Value<String?> base;
  final Value<String?> error;
  final Value<int> rowid;
  const LineUpPrepOutboxCompanion({
    this.lineUpId = const Value.absent(),
    this.songId = const Value.absent(),
    this.kind = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.base = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineUpPrepOutboxCompanion.insert({
    required int lineUpId,
    required int songId,
    required String kind,
    required DateTime updatedAt,
    this.base = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lineUpId = Value(lineUpId),
       songId = Value(songId),
       kind = Value(kind),
       updatedAt = Value(updatedAt);
  static Insertable<LineUpPrepOutboxRow> custom({
    Expression<int>? lineUpId,
    Expression<int>? songId,
    Expression<String>? kind,
    Expression<DateTime>? updatedAt,
    Expression<String>? base,
    Expression<String>? error,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lineUpId != null) 'line_up_id': lineUpId,
      if (songId != null) 'song_id': songId,
      if (kind != null) 'kind': kind,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (base != null) 'base': base,
      if (error != null) 'error': error,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineUpPrepOutboxCompanion copyWith({
    Value<int>? lineUpId,
    Value<int>? songId,
    Value<String>? kind,
    Value<DateTime>? updatedAt,
    Value<String?>? base,
    Value<String?>? error,
    Value<int>? rowid,
  }) {
    return LineUpPrepOutboxCompanion(
      lineUpId: lineUpId ?? this.lineUpId,
      songId: songId ?? this.songId,
      kind: kind ?? this.kind,
      updatedAt: updatedAt ?? this.updatedAt,
      base: base ?? this.base,
      error: error ?? this.error,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lineUpId.present) {
      map['line_up_id'] = Variable<int>(lineUpId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (base.present) {
      map['base'] = Variable<String>(base.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineUpPrepOutboxCompanion(')
          ..write('lineUpId: $lineUpId, ')
          ..write('songId: $songId, ')
          ..write('kind: $kind, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('base: $base, ')
          ..write('error: $error, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, WorkspaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMemberMeta = const VerificationMeta(
    'isMember',
  );
  @override
  late final GeneratedColumn<bool> isMember = GeneratedColumn<bool>(
    'is_member',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_member" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, role, isMember];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_member')) {
      context.handle(
        _isMemberMeta,
        isMember.isAcceptableOrUnknown(data['is_member']!, _isMemberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isMember: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_member'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class WorkspaceRow extends DataClass implements Insertable<WorkspaceRow> {
  final int id;
  final String name;
  final String role;
  final bool isMember;
  const WorkspaceRow({
    required this.id,
    required this.name,
    required this.role,
    required this.isMember,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['is_member'] = Variable<bool>(isMember);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      isMember: Value(isMember),
    );
  }

  factory WorkspaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      isMember: serializer.fromJson<bool>(json['isMember']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'isMember': serializer.toJson<bool>(isMember),
    };
  }

  WorkspaceRow copyWith({
    int? id,
    String? name,
    String? role,
    bool? isMember,
  }) => WorkspaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    isMember: isMember ?? this.isMember,
  );
  WorkspaceRow copyWithCompanion(WorkspacesCompanion data) {
    return WorkspaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      isMember: data.isMember.present ? data.isMember.value : this.isMember,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('isMember: $isMember')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, role, isMember);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.isMember == this.isMember);
}

class WorkspacesCompanion extends UpdateCompanion<WorkspaceRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> role;
  final Value<bool> isMember;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.isMember = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String role,
    this.isMember = const Value.absent(),
  }) : name = Value(name),
       role = Value(role);
  static Insertable<WorkspaceRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<bool>? isMember,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (isMember != null) 'is_member': isMember,
    });
  }

  WorkspacesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? role,
    Value<bool>? isMember,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isMember: isMember ?? this.isMember,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isMember.present) {
      map['is_member'] = Variable<bool>(isMember.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('isMember: $isMember')
          ..write(')'))
        .toString();
  }
}

class $RecentSongAccessesTable extends RecentSongAccesses
    with TableInfo<$RecentSongAccessesTable, RecentSongAccessRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSongAccessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [songId, workspaceId, lastAccessedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_song_accesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSongAccessRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  RecentSongAccessRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSongAccessRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $RecentSongAccessesTable createAlias(String alias) {
    return $RecentSongAccessesTable(attachedDatabase, alias);
  }
}

class RecentSongAccessRow extends DataClass
    implements Insertable<RecentSongAccessRow> {
  final int songId;
  final int workspaceId;
  final DateTime lastAccessedAt;
  const RecentSongAccessRow({
    required this.songId,
    required this.workspaceId,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  RecentSongAccessesCompanion toCompanion(bool nullToAbsent) {
    return RecentSongAccessesCompanion(
      songId: Value(songId),
      workspaceId: Value(workspaceId),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory RecentSongAccessRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSongAccessRow(
      songId: serializer.fromJson<int>(json['songId']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  RecentSongAccessRow copyWith({
    int? songId,
    int? workspaceId,
    DateTime? lastAccessedAt,
  }) => RecentSongAccessRow(
    songId: songId ?? this.songId,
    workspaceId: workspaceId ?? this.workspaceId,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  RecentSongAccessRow copyWithCompanion(RecentSongAccessesCompanion data) {
    return RecentSongAccessRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSongAccessRow(')
          ..write('songId: $songId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, workspaceId, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSongAccessRow &&
          other.songId == this.songId &&
          other.workspaceId == this.workspaceId &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class RecentSongAccessesCompanion extends UpdateCompanion<RecentSongAccessRow> {
  final Value<int> songId;
  final Value<int> workspaceId;
  final Value<DateTime> lastAccessedAt;
  const RecentSongAccessesCompanion({
    this.songId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
  });
  RecentSongAccessesCompanion.insert({
    this.songId = const Value.absent(),
    required int workspaceId,
    required DateTime lastAccessedAt,
  }) : workspaceId = Value(workspaceId),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<RecentSongAccessRow> custom({
    Expression<int>? songId,
    Expression<int>? workspaceId,
    Expression<DateTime>? lastAccessedAt,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
    });
  }

  RecentSongAccessesCompanion copyWith({
    Value<int>? songId,
    Value<int>? workspaceId,
    Value<DateTime>? lastAccessedAt,
  }) {
    return RecentSongAccessesCompanion(
      songId: songId ?? this.songId,
      workspaceId: workspaceId ?? this.workspaceId,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSongAccessesCompanion(')
          ..write('songId: $songId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetasTable extends SyncMetas
    with TableInfo<$SyncMetasTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [workspaceId, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncMetasTable createAlias(String alias) {
    return $SyncMetasTable(attachedDatabase, alias);
  }
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final int workspaceId;
  final DateTime? lastSyncedAt;
  const SyncMetaRow({required this.workspaceId, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<int>(workspaceId);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncMetasCompanion toCompanion(bool nullToAbsent) {
    return SyncMetasCompanion(
      workspaceId: Value(workspaceId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<int>(workspaceId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncMetaRow copyWith({
    int? workspaceId,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncMetaRow(
    workspaceId: workspaceId ?? this.workspaceId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncMetaRow copyWithCompanion(SyncMetasCompanion data) {
    return SyncMetaRow(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.workspaceId == this.workspaceId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncMetasCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<int> workspaceId;
  final Value<DateTime?> lastSyncedAt;
  const SyncMetasCompanion({
    this.workspaceId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncMetasCompanion.insert({
    this.workspaceId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<SyncMetaRow> custom({
    Expression<int>? workspaceId,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncMetasCompanion copyWith({
    Value<int>? workspaceId,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return SyncMetasCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetasCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [workspaceId, query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId, query};
  @override
  RecentSearchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearchRow(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearchRow extends DataClass implements Insertable<RecentSearchRow> {
  final int workspaceId;
  final String query;
  final DateTime searchedAt;
  const RecentSearchRow({
    required this.workspaceId,
    required this.query,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<int>(workspaceId);
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      workspaceId: Value(workspaceId),
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearchRow(
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<int>(workspaceId),
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearchRow copyWith({
    int? workspaceId,
    String? query,
    DateTime? searchedAt,
  }) => RecentSearchRow(
    workspaceId: workspaceId ?? this.workspaceId,
    query: query ?? this.query,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  RecentSearchRow copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearchRow(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchRow(')
          ..write('workspaceId: $workspaceId, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearchRow &&
          other.workspaceId == this.workspaceId &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearchRow> {
  final Value<int> workspaceId;
  final Value<String> query;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.workspaceId = const Value.absent(),
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required int workspaceId,
    required String query,
    required DateTime searchedAt,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearchRow> custom({
    Expression<int>? workspaceId,
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<int>? workspaceId,
    Value<String>? query,
    Value<DateTime>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongSearchQueueTable extends SongSearchQueue
    with TableInfo<$SongSearchQueueTable, SongSearchQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongSearchQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [songId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_search_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongSearchQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  SongSearchQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongSearchQueueRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
    );
  }

  @override
  $SongSearchQueueTable createAlias(String alias) {
    return $SongSearchQueueTable(attachedDatabase, alias);
  }
}

class SongSearchQueueRow extends DataClass
    implements Insertable<SongSearchQueueRow> {
  final int songId;
  const SongSearchQueueRow({required this.songId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    return map;
  }

  SongSearchQueueCompanion toCompanion(bool nullToAbsent) {
    return SongSearchQueueCompanion(songId: Value(songId));
  }

  factory SongSearchQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongSearchQueueRow(songId: serializer.fromJson<int>(json['songId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'songId': serializer.toJson<int>(songId)};
  }

  SongSearchQueueRow copyWith({int? songId}) =>
      SongSearchQueueRow(songId: songId ?? this.songId);
  SongSearchQueueRow copyWithCompanion(SongSearchQueueCompanion data) {
    return SongSearchQueueRow(
      songId: data.songId.present ? data.songId.value : this.songId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongSearchQueueRow(')
          ..write('songId: $songId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => songId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongSearchQueueRow && other.songId == this.songId);
}

class SongSearchQueueCompanion extends UpdateCompanion<SongSearchQueueRow> {
  final Value<int> songId;
  const SongSearchQueueCompanion({this.songId = const Value.absent()});
  SongSearchQueueCompanion.insert({this.songId = const Value.absent()});
  static Insertable<SongSearchQueueRow> custom({Expression<int>? songId}) {
    return RawValuesInsertable({if (songId != null) 'song_id': songId});
  }

  SongSearchQueueCompanion copyWith({Value<int>? songId}) {
    return SongSearchQueueCompanion(songId: songId ?? this.songId);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongSearchQueueCompanion(')
          ..write('songId: $songId')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsQueueTable extends AnalyticsQueue
    with TableInfo<$AnalyticsQueueTable, AnalyticsQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screenMeta = const VerificationMeta('screen');
  @override
  late final GeneratedColumn<String> screen = GeneratedColumn<String>(
    'screen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propertiesMeta = const VerificationMeta(
    'properties',
  );
  @override
  late final GeneratedColumn<String> properties = GeneratedColumn<String>(
    'properties',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    screen,
    workspaceId,
    sessionId,
    properties,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('screen')) {
      context.handle(
        _screenMeta,
        screen.isAcceptableOrUnknown(data['screen']!, _screenMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('properties')) {
      context.handle(
        _propertiesMeta,
        properties.isAcceptableOrUnknown(data['properties']!, _propertiesMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      screen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screen'],
      ),
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      properties: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}properties'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $AnalyticsQueueTable createAlias(String alias) {
    return $AnalyticsQueueTable(attachedDatabase, alias);
  }
}

class AnalyticsQueueRow extends DataClass
    implements Insertable<AnalyticsQueueRow> {
  final String id;
  final int userId;
  final String name;
  final String? screen;
  final int? workspaceId;
  final String sessionId;

  /// JSON object of flat values, or null.
  final String? properties;
  final DateTime occurredAt;
  const AnalyticsQueueRow({
    required this.id,
    required this.userId,
    required this.name,
    this.screen,
    this.workspaceId,
    required this.sessionId,
    this.properties,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<int>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || screen != null) {
      map['screen'] = Variable<String>(screen);
    }
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<int>(workspaceId);
    }
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || properties != null) {
      map['properties'] = Variable<String>(properties);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  AnalyticsQueueCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsQueueCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      screen: screen == null && nullToAbsent
          ? const Value.absent()
          : Value(screen),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      sessionId: Value(sessionId),
      properties: properties == null && nullToAbsent
          ? const Value.absent()
          : Value(properties),
      occurredAt: Value(occurredAt),
    );
  }

  factory AnalyticsQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsQueueRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      screen: serializer.fromJson<String?>(json['screen']),
      workspaceId: serializer.fromJson<int?>(json['workspaceId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      properties: serializer.fromJson<String?>(json['properties']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<int>(userId),
      'name': serializer.toJson<String>(name),
      'screen': serializer.toJson<String?>(screen),
      'workspaceId': serializer.toJson<int?>(workspaceId),
      'sessionId': serializer.toJson<String>(sessionId),
      'properties': serializer.toJson<String?>(properties),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  AnalyticsQueueRow copyWith({
    String? id,
    int? userId,
    String? name,
    Value<String?> screen = const Value.absent(),
    Value<int?> workspaceId = const Value.absent(),
    String? sessionId,
    Value<String?> properties = const Value.absent(),
    DateTime? occurredAt,
  }) => AnalyticsQueueRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    screen: screen.present ? screen.value : this.screen,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
    sessionId: sessionId ?? this.sessionId,
    properties: properties.present ? properties.value : this.properties,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  AnalyticsQueueRow copyWithCompanion(AnalyticsQueueCompanion data) {
    return AnalyticsQueueRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      screen: data.screen.present ? data.screen.value : this.screen,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      properties: data.properties.present
          ? data.properties.value
          : this.properties,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsQueueRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('screen: $screen, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sessionId: $sessionId, ')
          ..write('properties: $properties, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    screen,
    workspaceId,
    sessionId,
    properties,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsQueueRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.screen == this.screen &&
          other.workspaceId == this.workspaceId &&
          other.sessionId == this.sessionId &&
          other.properties == this.properties &&
          other.occurredAt == this.occurredAt);
}

class AnalyticsQueueCompanion extends UpdateCompanion<AnalyticsQueueRow> {
  final Value<String> id;
  final Value<int> userId;
  final Value<String> name;
  final Value<String?> screen;
  final Value<int?> workspaceId;
  final Value<String> sessionId;
  final Value<String?> properties;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const AnalyticsQueueCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.screen = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.properties = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalyticsQueueCompanion.insert({
    required String id,
    required int userId,
    required String name,
    this.screen = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String sessionId,
    this.properties = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       sessionId = Value(sessionId),
       occurredAt = Value(occurredAt);
  static Insertable<AnalyticsQueueRow> custom({
    Expression<String>? id,
    Expression<int>? userId,
    Expression<String>? name,
    Expression<String>? screen,
    Expression<int>? workspaceId,
    Expression<String>? sessionId,
    Expression<String>? properties,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (screen != null) 'screen': screen,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (sessionId != null) 'session_id': sessionId,
      if (properties != null) 'properties': properties,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalyticsQueueCompanion copyWith({
    Value<String>? id,
    Value<int>? userId,
    Value<String>? name,
    Value<String?>? screen,
    Value<int?>? workspaceId,
    Value<String>? sessionId,
    Value<String?>? properties,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return AnalyticsQueueCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      screen: screen ?? this.screen,
      workspaceId: workspaceId ?? this.workspaceId,
      sessionId: sessionId ?? this.sessionId,
      properties: properties ?? this.properties,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (screen.present) {
      map['screen'] = Variable<String>(screen.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (properties.present) {
      map['properties'] = Variable<String>(properties.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsQueueCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('screen: $screen, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sessionId: $sessionId, ')
          ..write('properties: $properties, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $SongOutboxTable songOutbox = $SongOutboxTable(this);
  late final $SongEditsTable songEdits = $SongEditsTable(this);
  late final $SongCaposTable songCapos = $SongCaposTable(this);
  late final $SongUpcomingLineUpsTable songUpcomingLineUps =
      $SongUpcomingLineUpsTable(this);
  late final $DisplayPrefsTable displayPrefs = $DisplayPrefsTable(this);
  late final $LineUpsTable lineUps = $LineUpsTable(this);
  late final $LineUpSongsTable lineUpSongs = $LineUpSongsTable(this);
  late final $LineUpSongCaposTable lineUpSongCapos = $LineUpSongCaposTable(
    this,
  );
  late final $LineUpOutboxTable lineUpOutbox = $LineUpOutboxTable(this);
  late final $LineUpPrepOutboxTable lineUpPrepOutbox = $LineUpPrepOutboxTable(
    this,
  );
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $RecentSongAccessesTable recentSongAccesses =
      $RecentSongAccessesTable(this);
  late final $SyncMetasTable syncMetas = $SyncMetasTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $SongSearchQueueTable songSearchQueue = $SongSearchQueueTable(
    this,
  );
  late final $AnalyticsQueueTable analyticsQueue = $AnalyticsQueueTable(this);
  late final Index songsWorkspace = Index(
    'songs_workspace',
    'CREATE INDEX songs_workspace ON songs (workspace_id)',
  );
  late final Index lineUpsWorkspace = Index(
    'line_ups_workspace',
    'CREATE INDEX line_ups_workspace ON line_ups (workspace_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    songOutbox,
    songEdits,
    songCapos,
    songUpcomingLineUps,
    displayPrefs,
    lineUps,
    lineUpSongs,
    lineUpSongCapos,
    lineUpOutbox,
    lineUpPrepOutbox,
    workspaces,
    recentSongAccesses,
    syncMetas,
    recentSearches,
    songSearchQueue,
    analyticsQueue,
    songsWorkspace,
    lineUpsWorkspace,
  ];
}

typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String title,
  Value<String?> artist,
  Value<String?> key,
  Value<int?> transposition,
  Value<int?> bpm,
  Value<String?> timeSignature,
  Value<String?> content,
  Value<String?> lyrics,
  Value<String?> youtubeUrl,
  Value<String?> spotifyUrl,
  Value<String?> appleMusicUrl,
  Value<String?> otherUrl,
  Value<bool> isPublic,
  Value<DateTime?> createdAt,
  Value<DateTime?> lastUsedAt,
  Value<int> version,
});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> title,
  Value<String?> artist,
  Value<String?> key,
  Value<int?> transposition,
  Value<int?> bpm,
  Value<String?> timeSignature,
  Value<String?> content,
  Value<String?> lyrics,
  Value<String?> youtubeUrl,
  Value<String?> spotifyUrl,
  Value<String?> appleMusicUrl,
  Value<String?> otherUrl,
  Value<bool> isPublic,
  Value<DateTime?> createdAt,
  Value<DateTime?> lastUsedAt,
  Value<int> version,
});

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spotifyUrl => $composableBuilder(
    column: $table.spotifyUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appleMusicUrl => $composableBuilder(
    column: $table.appleMusicUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherUrl => $composableBuilder(
    column: $table.otherUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spotifyUrl => $composableBuilder(
    column: $table.spotifyUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appleMusicUrl => $composableBuilder(
    column: $table.appleMusicUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherUrl => $composableBuilder(
    column: $table.otherUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  GeneratedColumn<String> get timeSignature => $composableBuilder(
    column: $table.timeSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

  GeneratedColumn<String> get youtubeUrl => $composableBuilder(
    column: $table.youtubeUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spotifyUrl => $composableBuilder(
    column: $table.spotifyUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appleMusicUrl => $composableBuilder(
    column: $table.appleMusicUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherUrl =>
      $composableBuilder(column: $table.otherUrl, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          SongRow,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
          SongRow,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> key = const Value.absent(),
                Value<int?> transposition = const Value.absent(),
                Value<int?> bpm = const Value.absent(),
                Value<String?> timeSignature = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
                Value<String?> youtubeUrl = const Value.absent(),
                Value<String?> spotifyUrl = const Value.absent(),
                Value<String?> appleMusicUrl = const Value.absent(),
                Value<String?> otherUrl = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                workspaceId: workspaceId,
                title: title,
                artist: artist,
                key: key,
                transposition: transposition,
                bpm: bpm,
                timeSignature: timeSignature,
                content: content,
                lyrics: lyrics,
                youtubeUrl: youtubeUrl,
                spotifyUrl: spotifyUrl,
                appleMusicUrl: appleMusicUrl,
                otherUrl: otherUrl,
                isPublic: isPublic,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                version: version,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workspaceId,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> key = const Value.absent(),
                Value<int?> transposition = const Value.absent(),
                Value<int?> bpm = const Value.absent(),
                Value<String?> timeSignature = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
                Value<String?> youtubeUrl = const Value.absent(),
                Value<String?> spotifyUrl = const Value.absent(),
                Value<String?> appleMusicUrl = const Value.absent(),
                Value<String?> otherUrl = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                title: title,
                artist: artist,
                key: key,
                transposition: transposition,
                bpm: bpm,
                timeSignature: timeSignature,
                content: content,
                lyrics: lyrics,
                youtubeUrl: youtubeUrl,
                spotifyUrl: spotifyUrl,
                appleMusicUrl: appleMusicUrl,
                otherUrl: otherUrl,
                isPublic: isPublic,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                version: version,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongsTable, SongRow>(table),
                  BaseReferences<_$AppDatabase, $SongsTable, SongRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      SongRow,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
      SongRow,
      PrefetchHooks Function()
    >;
typedef $$SongOutboxTableCreateCompanionBuilder = SongOutboxCompanion Function({
  Value<int> localId,
  required int workspaceId,
  Value<String?> error,
  required DateTime createdAt,
});
typedef $$SongOutboxTableUpdateCompanionBuilder = SongOutboxCompanion Function({
  Value<int> localId,
  Value<int> workspaceId,
  Value<String?> error,
  Value<DateTime> createdAt,
});

class $$SongOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SongOutboxTable> {
  $$SongOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SongOutboxTable> {
  $$SongOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongOutboxTable> {
  $$SongOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SongOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongOutboxTable,
          SongOutboxRow,
          $$SongOutboxTableFilterComposer,
          $$SongOutboxTableOrderingComposer,
          $$SongOutboxTableAnnotationComposer,
          $$SongOutboxTableCreateCompanionBuilder,
          $$SongOutboxTableUpdateCompanionBuilder,
          (
            SongOutboxRow,
            BaseReferences<_$AppDatabase, $SongOutboxTable, SongOutboxRow>,
          ),
          SongOutboxRow,
          PrefetchHooks Function()
        > {
  $$SongOutboxTableTableManager(_$AppDatabase db, $SongOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SongOutboxCompanion(
                localId: localId,
                workspaceId: workspaceId,
                error: error,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int workspaceId,
                Value<String?> error = const Value.absent(),
                required DateTime createdAt,
              }) => SongOutboxCompanion.insert(
                localId: localId,
                workspaceId: workspaceId,
                error: error,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongOutboxTable, SongOutboxRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SongOutboxTable,
                    SongOutboxRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongOutboxTable,
      SongOutboxRow,
      $$SongOutboxTableFilterComposer,
      $$SongOutboxTableOrderingComposer,
      $$SongOutboxTableAnnotationComposer,
      $$SongOutboxTableCreateCompanionBuilder,
      $$SongOutboxTableUpdateCompanionBuilder,
      (
        SongOutboxRow,
        BaseReferences<_$AppDatabase, $SongOutboxTable, SongOutboxRow>,
      ),
      SongOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SongEditsTableCreateCompanionBuilder = SongEditsCompanion Function({
  Value<int> songId,
  required int workspaceId,
  required DateTime updatedAt,
  Value<String?> error,
  Value<String?> base,
  Value<String?> conflicts,
});
typedef $$SongEditsTableUpdateCompanionBuilder = SongEditsCompanion Function({
  Value<int> songId,
  Value<int> workspaceId,
  Value<DateTime> updatedAt,
  Value<String?> error,
  Value<String?> base,
  Value<String?> conflicts,
});

class $$SongEditsTableFilterComposer
    extends Composer<_$AppDatabase, $SongEditsTable> {
  $$SongEditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflicts => $composableBuilder(
    column: $table.conflicts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongEditsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongEditsTable> {
  $$SongEditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflicts => $composableBuilder(
    column: $table.conflicts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongEditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongEditsTable> {
  $$SongEditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<String> get conflicts =>
      $composableBuilder(column: $table.conflicts, builder: (column) => column);
}

class $$SongEditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongEditsTable,
          SongEditRow,
          $$SongEditsTableFilterComposer,
          $$SongEditsTableOrderingComposer,
          $$SongEditsTableAnnotationComposer,
          $$SongEditsTableCreateCompanionBuilder,
          $$SongEditsTableUpdateCompanionBuilder,
          (
            SongEditRow,
            BaseReferences<_$AppDatabase, $SongEditsTable, SongEditRow>,
          ),
          SongEditRow,
          PrefetchHooks Function()
        > {
  $$SongEditsTableTableManager(_$AppDatabase db, $SongEditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongEditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongEditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongEditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> base = const Value.absent(),
                Value<String?> conflicts = const Value.absent(),
              }) => SongEditsCompanion(
                songId: songId,
                workspaceId: workspaceId,
                updatedAt: updatedAt,
                error: error,
                base: base,
                conflicts: conflicts,
              ),
          createCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                required int workspaceId,
                required DateTime updatedAt,
                Value<String?> error = const Value.absent(),
                Value<String?> base = const Value.absent(),
                Value<String?> conflicts = const Value.absent(),
              }) => SongEditsCompanion.insert(
                songId: songId,
                workspaceId: workspaceId,
                updatedAt: updatedAt,
                error: error,
                base: base,
                conflicts: conflicts,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongEditsTable, SongEditRow>(table),
                  BaseReferences<_$AppDatabase, $SongEditsTable, SongEditRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongEditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongEditsTable,
      SongEditRow,
      $$SongEditsTableFilterComposer,
      $$SongEditsTableOrderingComposer,
      $$SongEditsTableAnnotationComposer,
      $$SongEditsTableCreateCompanionBuilder,
      $$SongEditsTableUpdateCompanionBuilder,
      (
        SongEditRow,
        BaseReferences<_$AppDatabase, $SongEditsTable, SongEditRow>,
      ),
      SongEditRow,
      PrefetchHooks Function()
    >;
typedef $$SongCaposTableCreateCompanionBuilder = SongCaposCompanion Function({
  Value<int> songId,
  Value<int> capo,
  Value<bool> dirty,
});
typedef $$SongCaposTableUpdateCompanionBuilder = SongCaposCompanion Function({
  Value<int> songId,
  Value<int> capo,
  Value<bool> dirty,
});

class $$SongCaposTableFilterComposer
    extends Composer<_$AppDatabase, $SongCaposTable> {
  $$SongCaposTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capo => $composableBuilder(
    column: $table.capo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongCaposTableOrderingComposer
    extends Composer<_$AppDatabase, $SongCaposTable> {
  $$SongCaposTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capo => $composableBuilder(
    column: $table.capo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongCaposTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongCaposTable> {
  $$SongCaposTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get capo =>
      $composableBuilder(column: $table.capo, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$SongCaposTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongCaposTable,
          SongCapoRow,
          $$SongCaposTableFilterComposer,
          $$SongCaposTableOrderingComposer,
          $$SongCaposTableAnnotationComposer,
          $$SongCaposTableCreateCompanionBuilder,
          $$SongCaposTableUpdateCompanionBuilder,
          (
            SongCapoRow,
            BaseReferences<_$AppDatabase, $SongCaposTable, SongCapoRow>,
          ),
          SongCapoRow,
          PrefetchHooks Function()
        > {
  $$SongCaposTableTableManager(_$AppDatabase db, $SongCaposTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongCaposTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongCaposTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongCaposTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> songId = const Value.absent(),
            Value<int> capo = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
          }) => SongCaposCompanion(songId: songId, capo: capo, dirty: dirty),
          createCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> capo = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
              }) => SongCaposCompanion.insert(
                songId: songId,
                capo: capo,
                dirty: dirty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongCaposTable, SongCapoRow>(table),
                  BaseReferences<_$AppDatabase, $SongCaposTable, SongCapoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongCaposTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongCaposTable,
      SongCapoRow,
      $$SongCaposTableFilterComposer,
      $$SongCaposTableOrderingComposer,
      $$SongCaposTableAnnotationComposer,
      $$SongCaposTableCreateCompanionBuilder,
      $$SongCaposTableUpdateCompanionBuilder,
      (
        SongCapoRow,
        BaseReferences<_$AppDatabase, $SongCaposTable, SongCapoRow>,
      ),
      SongCapoRow,
      PrefetchHooks Function()
    >;
typedef $$SongUpcomingLineUpsTableCreateCompanionBuilder =
    SongUpcomingLineUpsCompanion Function({
      required int songId,
      required int lineUpId,
      required String title,
      required String date,
      Value<int> rowid,
    });
typedef $$SongUpcomingLineUpsTableUpdateCompanionBuilder =
    SongUpcomingLineUpsCompanion Function({
      Value<int> songId,
      Value<int> lineUpId,
      Value<String> title,
      Value<String> date,
      Value<int> rowid,
    });

class $$SongUpcomingLineUpsTableFilterComposer
    extends Composer<_$AppDatabase, $SongUpcomingLineUpsTable> {
  $$SongUpcomingLineUpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongUpcomingLineUpsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongUpcomingLineUpsTable> {
  $$SongUpcomingLineUpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongUpcomingLineUpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongUpcomingLineUpsTable> {
  $$SongUpcomingLineUpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get lineUpId =>
      $composableBuilder(column: $table.lineUpId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$SongUpcomingLineUpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongUpcomingLineUpsTable,
          SongUpcomingLineUpRow,
          $$SongUpcomingLineUpsTableFilterComposer,
          $$SongUpcomingLineUpsTableOrderingComposer,
          $$SongUpcomingLineUpsTableAnnotationComposer,
          $$SongUpcomingLineUpsTableCreateCompanionBuilder,
          $$SongUpcomingLineUpsTableUpdateCompanionBuilder,
          (
            SongUpcomingLineUpRow,
            BaseReferences<
              _$AppDatabase,
              $SongUpcomingLineUpsTable,
              SongUpcomingLineUpRow
            >,
          ),
          SongUpcomingLineUpRow,
          PrefetchHooks Function()
        > {
  $$SongUpcomingLineUpsTableTableManager(
    _$AppDatabase db,
    $SongUpcomingLineUpsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongUpcomingLineUpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongUpcomingLineUpsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SongUpcomingLineUpsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> lineUpId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongUpcomingLineUpsCompanion(
                songId: songId,
                lineUpId: lineUpId,
                title: title,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int songId,
                required int lineUpId,
                required String title,
                required String date,
                Value<int> rowid = const Value.absent(),
              }) => SongUpcomingLineUpsCompanion.insert(
                songId: songId,
                lineUpId: lineUpId,
                title: title,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongUpcomingLineUpsTable, SongUpcomingLineUpRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SongUpcomingLineUpsTable,
                    SongUpcomingLineUpRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongUpcomingLineUpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongUpcomingLineUpsTable,
      SongUpcomingLineUpRow,
      $$SongUpcomingLineUpsTableFilterComposer,
      $$SongUpcomingLineUpsTableOrderingComposer,
      $$SongUpcomingLineUpsTableAnnotationComposer,
      $$SongUpcomingLineUpsTableCreateCompanionBuilder,
      $$SongUpcomingLineUpsTableUpdateCompanionBuilder,
      (
        SongUpcomingLineUpRow,
        BaseReferences<
          _$AppDatabase,
          $SongUpcomingLineUpsTable,
          SongUpcomingLineUpRow
        >,
      ),
      SongUpcomingLineUpRow,
      PrefetchHooks Function()
    >;
typedef $$DisplayPrefsTableCreateCompanionBuilder =
    DisplayPrefsCompanion Function({
      Value<int> id,
      Value<String> viewMode,
      Value<int> zoom,
      Value<String?> chordNotation,
      Value<String?> performTheme,
      Value<bool> performAutoHide,
      Value<bool> performNotes,
      Value<bool> liveAutoReturn,
      Value<bool> practiceClick,
      Value<bool> practiceHaptics,
      Value<bool> practiceFlash,
    });
typedef $$DisplayPrefsTableUpdateCompanionBuilder =
    DisplayPrefsCompanion Function({
      Value<int> id,
      Value<String> viewMode,
      Value<int> zoom,
      Value<String?> chordNotation,
      Value<String?> performTheme,
      Value<bool> performAutoHide,
      Value<bool> performNotes,
      Value<bool> liveAutoReturn,
      Value<bool> practiceClick,
      Value<bool> practiceHaptics,
      Value<bool> practiceFlash,
    });

class $$DisplayPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $DisplayPrefsTable> {
  $$DisplayPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zoom => $composableBuilder(
    column: $table.zoom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chordNotation => $composableBuilder(
    column: $table.chordNotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get performTheme => $composableBuilder(
    column: $table.performTheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get performAutoHide => $composableBuilder(
    column: $table.performAutoHide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get performNotes => $composableBuilder(
    column: $table.performNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get liveAutoReturn => $composableBuilder(
    column: $table.liveAutoReturn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get practiceClick => $composableBuilder(
    column: $table.practiceClick,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get practiceHaptics => $composableBuilder(
    column: $table.practiceHaptics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get practiceFlash => $composableBuilder(
    column: $table.practiceFlash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DisplayPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $DisplayPrefsTable> {
  $$DisplayPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoom => $composableBuilder(
    column: $table.zoom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chordNotation => $composableBuilder(
    column: $table.chordNotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get performTheme => $composableBuilder(
    column: $table.performTheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get performAutoHide => $composableBuilder(
    column: $table.performAutoHide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get performNotes => $composableBuilder(
    column: $table.performNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get liveAutoReturn => $composableBuilder(
    column: $table.liveAutoReturn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get practiceClick => $composableBuilder(
    column: $table.practiceClick,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get practiceHaptics => $composableBuilder(
    column: $table.practiceHaptics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get practiceFlash => $composableBuilder(
    column: $table.practiceFlash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DisplayPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DisplayPrefsTable> {
  $$DisplayPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get viewMode =>
      $composableBuilder(column: $table.viewMode, builder: (column) => column);

  GeneratedColumn<int> get zoom =>
      $composableBuilder(column: $table.zoom, builder: (column) => column);

  GeneratedColumn<String> get chordNotation => $composableBuilder(
    column: $table.chordNotation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get performTheme => $composableBuilder(
    column: $table.performTheme,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get performAutoHide => $composableBuilder(
    column: $table.performAutoHide,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get performNotes => $composableBuilder(
    column: $table.performNotes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get liveAutoReturn => $composableBuilder(
    column: $table.liveAutoReturn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get practiceClick => $composableBuilder(
    column: $table.practiceClick,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get practiceHaptics => $composableBuilder(
    column: $table.practiceHaptics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get practiceFlash => $composableBuilder(
    column: $table.practiceFlash,
    builder: (column) => column,
  );
}

class $$DisplayPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DisplayPrefsTable,
          DisplayPrefsRow,
          $$DisplayPrefsTableFilterComposer,
          $$DisplayPrefsTableOrderingComposer,
          $$DisplayPrefsTableAnnotationComposer,
          $$DisplayPrefsTableCreateCompanionBuilder,
          $$DisplayPrefsTableUpdateCompanionBuilder,
          (
            DisplayPrefsRow,
            BaseReferences<_$AppDatabase, $DisplayPrefsTable, DisplayPrefsRow>,
          ),
          DisplayPrefsRow,
          PrefetchHooks Function()
        > {
  $$DisplayPrefsTableTableManager(_$AppDatabase db, $DisplayPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisplayPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisplayPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisplayPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> viewMode = const Value.absent(),
                Value<int> zoom = const Value.absent(),
                Value<String?> chordNotation = const Value.absent(),
                Value<String?> performTheme = const Value.absent(),
                Value<bool> performAutoHide = const Value.absent(),
                Value<bool> performNotes = const Value.absent(),
                Value<bool> liveAutoReturn = const Value.absent(),
                Value<bool> practiceClick = const Value.absent(),
                Value<bool> practiceHaptics = const Value.absent(),
                Value<bool> practiceFlash = const Value.absent(),
              }) => DisplayPrefsCompanion(
                id: id,
                viewMode: viewMode,
                zoom: zoom,
                chordNotation: chordNotation,
                performTheme: performTheme,
                performAutoHide: performAutoHide,
                performNotes: performNotes,
                liveAutoReturn: liveAutoReturn,
                practiceClick: practiceClick,
                practiceHaptics: practiceHaptics,
                practiceFlash: practiceFlash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> viewMode = const Value.absent(),
                Value<int> zoom = const Value.absent(),
                Value<String?> chordNotation = const Value.absent(),
                Value<String?> performTheme = const Value.absent(),
                Value<bool> performAutoHide = const Value.absent(),
                Value<bool> performNotes = const Value.absent(),
                Value<bool> liveAutoReturn = const Value.absent(),
                Value<bool> practiceClick = const Value.absent(),
                Value<bool> practiceHaptics = const Value.absent(),
                Value<bool> practiceFlash = const Value.absent(),
              }) => DisplayPrefsCompanion.insert(
                id: id,
                viewMode: viewMode,
                zoom: zoom,
                chordNotation: chordNotation,
                performTheme: performTheme,
                performAutoHide: performAutoHide,
                performNotes: performNotes,
                liveAutoReturn: liveAutoReturn,
                practiceClick: practiceClick,
                practiceHaptics: practiceHaptics,
                practiceFlash: practiceFlash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DisplayPrefsTable, DisplayPrefsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DisplayPrefsTable,
                    DisplayPrefsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DisplayPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DisplayPrefsTable,
      DisplayPrefsRow,
      $$DisplayPrefsTableFilterComposer,
      $$DisplayPrefsTableOrderingComposer,
      $$DisplayPrefsTableAnnotationComposer,
      $$DisplayPrefsTableCreateCompanionBuilder,
      $$DisplayPrefsTableUpdateCompanionBuilder,
      (
        DisplayPrefsRow,
        BaseReferences<_$AppDatabase, $DisplayPrefsTable, DisplayPrefsRow>,
      ),
      DisplayPrefsRow,
      PrefetchHooks Function()
    >;
typedef $$LineUpsTableCreateCompanionBuilder = LineUpsCompanion Function({
  Value<int> id,
  required int workspaceId,
  required String title,
  required String date,
  Value<String?> worshipLeader,
  Value<int> songsCount,
  Value<int> version,
  Value<int?> songsVersion,
  Value<bool> songsLoaded,
});
typedef $$LineUpsTableUpdateCompanionBuilder = LineUpsCompanion Function({
  Value<int> id,
  Value<int> workspaceId,
  Value<String> title,
  Value<String> date,
  Value<String?> worshipLeader,
  Value<int> songsCount,
  Value<int> version,
  Value<int?> songsVersion,
  Value<bool> songsLoaded,
});

class $$LineUpsTableFilterComposer
    extends Composer<_$AppDatabase, $LineUpsTable> {
  $$LineUpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get worshipLeader => $composableBuilder(
    column: $table.worshipLeader,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songsCount => $composableBuilder(
    column: $table.songsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songsVersion => $composableBuilder(
    column: $table.songsVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get songsLoaded => $composableBuilder(
    column: $table.songsLoaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineUpsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineUpsTable> {
  $$LineUpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get worshipLeader => $composableBuilder(
    column: $table.worshipLeader,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songsCount => $composableBuilder(
    column: $table.songsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songsVersion => $composableBuilder(
    column: $table.songsVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get songsLoaded => $composableBuilder(
    column: $table.songsLoaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineUpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineUpsTable> {
  $$LineUpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get worshipLeader => $composableBuilder(
    column: $table.worshipLeader,
    builder: (column) => column,
  );

  GeneratedColumn<int> get songsCount => $composableBuilder(
    column: $table.songsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get songsVersion => $composableBuilder(
    column: $table.songsVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get songsLoaded => $composableBuilder(
    column: $table.songsLoaded,
    builder: (column) => column,
  );
}

class $$LineUpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineUpsTable,
          LineUpRow,
          $$LineUpsTableFilterComposer,
          $$LineUpsTableOrderingComposer,
          $$LineUpsTableAnnotationComposer,
          $$LineUpsTableCreateCompanionBuilder,
          $$LineUpsTableUpdateCompanionBuilder,
          (LineUpRow, BaseReferences<_$AppDatabase, $LineUpsTable, LineUpRow>),
          LineUpRow,
          PrefetchHooks Function()
        > {
  $$LineUpsTableTableManager(_$AppDatabase db, $LineUpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineUpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineUpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineUpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> worshipLeader = const Value.absent(),
                Value<int> songsCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> songsVersion = const Value.absent(),
                Value<bool> songsLoaded = const Value.absent(),
              }) => LineUpsCompanion(
                id: id,
                workspaceId: workspaceId,
                title: title,
                date: date,
                worshipLeader: worshipLeader,
                songsCount: songsCount,
                version: version,
                songsVersion: songsVersion,
                songsLoaded: songsLoaded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workspaceId,
                required String title,
                required String date,
                Value<String?> worshipLeader = const Value.absent(),
                Value<int> songsCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> songsVersion = const Value.absent(),
                Value<bool> songsLoaded = const Value.absent(),
              }) => LineUpsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                title: title,
                date: date,
                worshipLeader: worshipLeader,
                songsCount: songsCount,
                version: version,
                songsVersion: songsVersion,
                songsLoaded: songsLoaded,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineUpsTable, LineUpRow>(table),
                  BaseReferences<_$AppDatabase, $LineUpsTable, LineUpRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineUpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineUpsTable,
      LineUpRow,
      $$LineUpsTableFilterComposer,
      $$LineUpsTableOrderingComposer,
      $$LineUpsTableAnnotationComposer,
      $$LineUpsTableCreateCompanionBuilder,
      $$LineUpsTableUpdateCompanionBuilder,
      (LineUpRow, BaseReferences<_$AppDatabase, $LineUpsTable, LineUpRow>),
      LineUpRow,
      PrefetchHooks Function()
    >;
typedef $$LineUpSongsTableCreateCompanionBuilder =
    LineUpSongsCompanion Function({
      required int lineUpId,
      required int position,
      required int songId,
      Value<int> transposition,
      Value<int?> lineUpSongId,
      Value<String?> notes,
      Value<String?> sectionArrangement,
      Value<int> rowid,
    });
typedef $$LineUpSongsTableUpdateCompanionBuilder =
    LineUpSongsCompanion Function({
      Value<int> lineUpId,
      Value<int> position,
      Value<int> songId,
      Value<int> transposition,
      Value<int?> lineUpSongId,
      Value<String?> notes,
      Value<String?> sectionArrangement,
      Value<int> rowid,
    });

class $$LineUpSongsTableFilterComposer
    extends Composer<_$AppDatabase, $LineUpSongsTable> {
  $$LineUpSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionArrangement => $composableBuilder(
    column: $table.sectionArrangement,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineUpSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineUpSongsTable> {
  $$LineUpSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionArrangement => $composableBuilder(
    column: $table.sectionArrangement,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineUpSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineUpSongsTable> {
  $$LineUpSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineUpId =>
      $composableBuilder(column: $table.lineUpId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get transposition => $composableBuilder(
    column: $table.transposition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sectionArrangement => $composableBuilder(
    column: $table.sectionArrangement,
    builder: (column) => column,
  );
}

class $$LineUpSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineUpSongsTable,
          LineUpSongRow,
          $$LineUpSongsTableFilterComposer,
          $$LineUpSongsTableOrderingComposer,
          $$LineUpSongsTableAnnotationComposer,
          $$LineUpSongsTableCreateCompanionBuilder,
          $$LineUpSongsTableUpdateCompanionBuilder,
          (
            LineUpSongRow,
            BaseReferences<_$AppDatabase, $LineUpSongsTable, LineUpSongRow>,
          ),
          LineUpSongRow,
          PrefetchHooks Function()
        > {
  $$LineUpSongsTableTableManager(_$AppDatabase db, $LineUpSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineUpSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineUpSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineUpSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lineUpId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<int> transposition = const Value.absent(),
                Value<int?> lineUpSongId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> sectionArrangement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineUpSongsCompanion(
                lineUpId: lineUpId,
                position: position,
                songId: songId,
                transposition: transposition,
                lineUpSongId: lineUpSongId,
                notes: notes,
                sectionArrangement: sectionArrangement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int lineUpId,
                required int position,
                required int songId,
                Value<int> transposition = const Value.absent(),
                Value<int?> lineUpSongId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> sectionArrangement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineUpSongsCompanion.insert(
                lineUpId: lineUpId,
                position: position,
                songId: songId,
                transposition: transposition,
                lineUpSongId: lineUpSongId,
                notes: notes,
                sectionArrangement: sectionArrangement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineUpSongsTable, LineUpSongRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LineUpSongsTable,
                    LineUpSongRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineUpSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineUpSongsTable,
      LineUpSongRow,
      $$LineUpSongsTableFilterComposer,
      $$LineUpSongsTableOrderingComposer,
      $$LineUpSongsTableAnnotationComposer,
      $$LineUpSongsTableCreateCompanionBuilder,
      $$LineUpSongsTableUpdateCompanionBuilder,
      (
        LineUpSongRow,
        BaseReferences<_$AppDatabase, $LineUpSongsTable, LineUpSongRow>,
      ),
      LineUpSongRow,
      PrefetchHooks Function()
    >;
typedef $$LineUpSongCaposTableCreateCompanionBuilder =
    LineUpSongCaposCompanion Function({
      Value<int> lineUpSongId,
      required int lineUpId,
      Value<int> capo,
      Value<bool> dirty,
    });
typedef $$LineUpSongCaposTableUpdateCompanionBuilder =
    LineUpSongCaposCompanion Function({
      Value<int> lineUpSongId,
      Value<int> lineUpId,
      Value<int> capo,
      Value<bool> dirty,
    });

class $$LineUpSongCaposTableFilterComposer
    extends Composer<_$AppDatabase, $LineUpSongCaposTable> {
  $$LineUpSongCaposTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capo => $composableBuilder(
    column: $table.capo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineUpSongCaposTableOrderingComposer
    extends Composer<_$AppDatabase, $LineUpSongCaposTable> {
  $$LineUpSongCaposTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capo => $composableBuilder(
    column: $table.capo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineUpSongCaposTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineUpSongCaposTable> {
  $$LineUpSongCaposTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineUpSongId => $composableBuilder(
    column: $table.lineUpSongId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineUpId =>
      $composableBuilder(column: $table.lineUpId, builder: (column) => column);

  GeneratedColumn<int> get capo =>
      $composableBuilder(column: $table.capo, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$LineUpSongCaposTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineUpSongCaposTable,
          LineUpSongCapoRow,
          $$LineUpSongCaposTableFilterComposer,
          $$LineUpSongCaposTableOrderingComposer,
          $$LineUpSongCaposTableAnnotationComposer,
          $$LineUpSongCaposTableCreateCompanionBuilder,
          $$LineUpSongCaposTableUpdateCompanionBuilder,
          (
            LineUpSongCapoRow,
            BaseReferences<
              _$AppDatabase,
              $LineUpSongCaposTable,
              LineUpSongCapoRow
            >,
          ),
          LineUpSongCapoRow,
          PrefetchHooks Function()
        > {
  $$LineUpSongCaposTableTableManager(
    _$AppDatabase db,
    $LineUpSongCaposTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineUpSongCaposTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineUpSongCaposTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineUpSongCaposTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lineUpSongId = const Value.absent(),
                Value<int> lineUpId = const Value.absent(),
                Value<int> capo = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
              }) => LineUpSongCaposCompanion(
                lineUpSongId: lineUpSongId,
                lineUpId: lineUpId,
                capo: capo,
                dirty: dirty,
              ),
          createCompanionCallback:
              ({
                Value<int> lineUpSongId = const Value.absent(),
                required int lineUpId,
                Value<int> capo = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
              }) => LineUpSongCaposCompanion.insert(
                lineUpSongId: lineUpSongId,
                lineUpId: lineUpId,
                capo: capo,
                dirty: dirty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineUpSongCaposTable, LineUpSongCapoRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LineUpSongCaposTable,
                    LineUpSongCapoRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineUpSongCaposTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineUpSongCaposTable,
      LineUpSongCapoRow,
      $$LineUpSongCaposTableFilterComposer,
      $$LineUpSongCaposTableOrderingComposer,
      $$LineUpSongCaposTableAnnotationComposer,
      $$LineUpSongCaposTableCreateCompanionBuilder,
      $$LineUpSongCaposTableUpdateCompanionBuilder,
      (
        LineUpSongCapoRow,
        BaseReferences<_$AppDatabase, $LineUpSongCaposTable, LineUpSongCapoRow>,
      ),
      LineUpSongCapoRow,
      PrefetchHooks Function()
    >;
typedef $$LineUpOutboxTableCreateCompanionBuilder =
    LineUpOutboxCompanion Function({
      Value<int> lineUpId,
      required int workspaceId,
      Value<bool> isNew,
      Value<bool> detailsDirty,
      Value<bool> songsDirty,
      Value<String?> baseSongIds,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> error,
    });
typedef $$LineUpOutboxTableUpdateCompanionBuilder =
    LineUpOutboxCompanion Function({
      Value<int> lineUpId,
      Value<int> workspaceId,
      Value<bool> isNew,
      Value<bool> detailsDirty,
      Value<bool> songsDirty,
      Value<String?> baseSongIds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> error,
    });

class $$LineUpOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $LineUpOutboxTable> {
  $$LineUpOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detailsDirty => $composableBuilder(
    column: $table.detailsDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get songsDirty => $composableBuilder(
    column: $table.songsDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseSongIds => $composableBuilder(
    column: $table.baseSongIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineUpOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $LineUpOutboxTable> {
  $$LineUpOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detailsDirty => $composableBuilder(
    column: $table.detailsDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get songsDirty => $composableBuilder(
    column: $table.songsDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseSongIds => $composableBuilder(
    column: $table.baseSongIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineUpOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineUpOutboxTable> {
  $$LineUpOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineUpId =>
      $composableBuilder(column: $table.lineUpId, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNew =>
      $composableBuilder(column: $table.isNew, builder: (column) => column);

  GeneratedColumn<bool> get detailsDirty => $composableBuilder(
    column: $table.detailsDirty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get songsDirty => $composableBuilder(
    column: $table.songsDirty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseSongIds => $composableBuilder(
    column: $table.baseSongIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$LineUpOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineUpOutboxTable,
          LineUpOutboxRow,
          $$LineUpOutboxTableFilterComposer,
          $$LineUpOutboxTableOrderingComposer,
          $$LineUpOutboxTableAnnotationComposer,
          $$LineUpOutboxTableCreateCompanionBuilder,
          $$LineUpOutboxTableUpdateCompanionBuilder,
          (
            LineUpOutboxRow,
            BaseReferences<_$AppDatabase, $LineUpOutboxTable, LineUpOutboxRow>,
          ),
          LineUpOutboxRow,
          PrefetchHooks Function()
        > {
  $$LineUpOutboxTableTableManager(_$AppDatabase db, $LineUpOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineUpOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineUpOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineUpOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lineUpId = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<bool> detailsDirty = const Value.absent(),
                Value<bool> songsDirty = const Value.absent(),
                Value<String?> baseSongIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => LineUpOutboxCompanion(
                lineUpId: lineUpId,
                workspaceId: workspaceId,
                isNew: isNew,
                detailsDirty: detailsDirty,
                songsDirty: songsDirty,
                baseSongIds: baseSongIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> lineUpId = const Value.absent(),
                required int workspaceId,
                Value<bool> isNew = const Value.absent(),
                Value<bool> detailsDirty = const Value.absent(),
                Value<bool> songsDirty = const Value.absent(),
                Value<String?> baseSongIds = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> error = const Value.absent(),
              }) => LineUpOutboxCompanion.insert(
                lineUpId: lineUpId,
                workspaceId: workspaceId,
                isNew: isNew,
                detailsDirty: detailsDirty,
                songsDirty: songsDirty,
                baseSongIds: baseSongIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineUpOutboxTable, LineUpOutboxRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LineUpOutboxTable,
                    LineUpOutboxRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineUpOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineUpOutboxTable,
      LineUpOutboxRow,
      $$LineUpOutboxTableFilterComposer,
      $$LineUpOutboxTableOrderingComposer,
      $$LineUpOutboxTableAnnotationComposer,
      $$LineUpOutboxTableCreateCompanionBuilder,
      $$LineUpOutboxTableUpdateCompanionBuilder,
      (
        LineUpOutboxRow,
        BaseReferences<_$AppDatabase, $LineUpOutboxTable, LineUpOutboxRow>,
      ),
      LineUpOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$LineUpPrepOutboxTableCreateCompanionBuilder =
    LineUpPrepOutboxCompanion Function({
      required int lineUpId,
      required int songId,
      required String kind,
      required DateTime updatedAt,
      Value<String?> base,
      Value<String?> error,
      Value<int> rowid,
    });
typedef $$LineUpPrepOutboxTableUpdateCompanionBuilder =
    LineUpPrepOutboxCompanion Function({
      Value<int> lineUpId,
      Value<int> songId,
      Value<String> kind,
      Value<DateTime> updatedAt,
      Value<String?> base,
      Value<String?> error,
      Value<int> rowid,
    });

class $$LineUpPrepOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $LineUpPrepOutboxTable> {
  $$LineUpPrepOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineUpPrepOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $LineUpPrepOutboxTable> {
  $$LineUpPrepOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineUpId => $composableBuilder(
    column: $table.lineUpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineUpPrepOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineUpPrepOutboxTable> {
  $$LineUpPrepOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineUpId =>
      $composableBuilder(column: $table.lineUpId, builder: (column) => column);

  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$LineUpPrepOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineUpPrepOutboxTable,
          LineUpPrepOutboxRow,
          $$LineUpPrepOutboxTableFilterComposer,
          $$LineUpPrepOutboxTableOrderingComposer,
          $$LineUpPrepOutboxTableAnnotationComposer,
          $$LineUpPrepOutboxTableCreateCompanionBuilder,
          $$LineUpPrepOutboxTableUpdateCompanionBuilder,
          (
            LineUpPrepOutboxRow,
            BaseReferences<
              _$AppDatabase,
              $LineUpPrepOutboxTable,
              LineUpPrepOutboxRow
            >,
          ),
          LineUpPrepOutboxRow,
          PrefetchHooks Function()
        > {
  $$LineUpPrepOutboxTableTableManager(
    _$AppDatabase db,
    $LineUpPrepOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineUpPrepOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineUpPrepOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineUpPrepOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lineUpId = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> base = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineUpPrepOutboxCompanion(
                lineUpId: lineUpId,
                songId: songId,
                kind: kind,
                updatedAt: updatedAt,
                base: base,
                error: error,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int lineUpId,
                required int songId,
                required String kind,
                required DateTime updatedAt,
                Value<String?> base = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineUpPrepOutboxCompanion.insert(
                lineUpId: lineUpId,
                songId: songId,
                kind: kind,
                updatedAt: updatedAt,
                base: base,
                error: error,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineUpPrepOutboxTable, LineUpPrepOutboxRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LineUpPrepOutboxTable,
                    LineUpPrepOutboxRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineUpPrepOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineUpPrepOutboxTable,
      LineUpPrepOutboxRow,
      $$LineUpPrepOutboxTableFilterComposer,
      $$LineUpPrepOutboxTableOrderingComposer,
      $$LineUpPrepOutboxTableAnnotationComposer,
      $$LineUpPrepOutboxTableCreateCompanionBuilder,
      $$LineUpPrepOutboxTableUpdateCompanionBuilder,
      (
        LineUpPrepOutboxRow,
        BaseReferences<
          _$AppDatabase,
          $LineUpPrepOutboxTable,
          LineUpPrepOutboxRow
        >,
      ),
      LineUpPrepOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$WorkspacesTableCreateCompanionBuilder = WorkspacesCompanion Function({
  Value<int> id,
  required String name,
  required String role,
  Value<bool> isMember,
});
typedef $$WorkspacesTableUpdateCompanionBuilder = WorkspacesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> role,
  Value<bool> isMember,
});

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMember => $composableBuilder(
    column: $table.isMember,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMember => $composableBuilder(
    column: $table.isMember,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isMember =>
      $composableBuilder(column: $table.isMember, builder: (column) => column);
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          WorkspaceRow,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            WorkspaceRow,
            BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow>,
          ),
          WorkspaceRow,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isMember = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                role: role,
                isMember: isMember,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String role,
                Value<bool> isMember = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                role: role,
                isMember: isMember,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkspacesTable, WorkspaceRow>(table),
                  BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      WorkspaceRow,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (
        WorkspaceRow,
        BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow>,
      ),
      WorkspaceRow,
      PrefetchHooks Function()
    >;
typedef $$RecentSongAccessesTableCreateCompanionBuilder =
    RecentSongAccessesCompanion Function({
      Value<int> songId,
      required int workspaceId,
      required DateTime lastAccessedAt,
    });
typedef $$RecentSongAccessesTableUpdateCompanionBuilder =
    RecentSongAccessesCompanion Function({
      Value<int> songId,
      Value<int> workspaceId,
      Value<DateTime> lastAccessedAt,
    });

class $$RecentSongAccessesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSongAccessesTable> {
  $$RecentSongAccessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSongAccessesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSongAccessesTable> {
  $$RecentSongAccessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSongAccessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSongAccessesTable> {
  $$RecentSongAccessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$RecentSongAccessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSongAccessesTable,
          RecentSongAccessRow,
          $$RecentSongAccessesTableFilterComposer,
          $$RecentSongAccessesTableOrderingComposer,
          $$RecentSongAccessesTableAnnotationComposer,
          $$RecentSongAccessesTableCreateCompanionBuilder,
          $$RecentSongAccessesTableUpdateCompanionBuilder,
          (
            RecentSongAccessRow,
            BaseReferences<
              _$AppDatabase,
              $RecentSongAccessesTable,
              RecentSongAccessRow
            >,
          ),
          RecentSongAccessRow,
          PrefetchHooks Function()
        > {
  $$RecentSongAccessesTableTableManager(
    _$AppDatabase db,
    $RecentSongAccessesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSongAccessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSongAccessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSongAccessesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
              }) => RecentSongAccessesCompanion(
                songId: songId,
                workspaceId: workspaceId,
                lastAccessedAt: lastAccessedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                required int workspaceId,
                required DateTime lastAccessedAt,
              }) => RecentSongAccessesCompanion.insert(
                songId: songId,
                workspaceId: workspaceId,
                lastAccessedAt: lastAccessedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSongAccessesTable, RecentSongAccessRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSongAccessesTable,
                    RecentSongAccessRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSongAccessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSongAccessesTable,
      RecentSongAccessRow,
      $$RecentSongAccessesTableFilterComposer,
      $$RecentSongAccessesTableOrderingComposer,
      $$RecentSongAccessesTableAnnotationComposer,
      $$RecentSongAccessesTableCreateCompanionBuilder,
      $$RecentSongAccessesTableUpdateCompanionBuilder,
      (
        RecentSongAccessRow,
        BaseReferences<
          _$AppDatabase,
          $RecentSongAccessesTable,
          RecentSongAccessRow
        >,
      ),
      RecentSongAccessRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetasTableCreateCompanionBuilder = SyncMetasCompanion Function({
  Value<int> workspaceId,
  Value<DateTime?> lastSyncedAt,
});
typedef $$SyncMetasTableUpdateCompanionBuilder = SyncMetasCompanion Function({
  Value<int> workspaceId,
  Value<DateTime?> lastSyncedAt,
});

class $$SyncMetasTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetasTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncMetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetasTable,
          SyncMetaRow,
          $$SyncMetasTableFilterComposer,
          $$SyncMetasTableOrderingComposer,
          $$SyncMetasTableAnnotationComposer,
          $$SyncMetasTableCreateCompanionBuilder,
          $$SyncMetasTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetasTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetasTableTableManager(_$AppDatabase db, $SyncMetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workspaceId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncMetasCompanion(
                workspaceId: workspaceId,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> workspaceId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncMetasCompanion.insert(
                workspaceId: workspaceId,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetasTable, SyncMetaRow>(table),
                  BaseReferences<_$AppDatabase, $SyncMetasTable, SyncMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetasTable,
      SyncMetaRow,
      $$SyncMetasTableFilterComposer,
      $$SyncMetasTableOrderingComposer,
      $$SyncMetasTableAnnotationComposer,
      $$SyncMetasTableCreateCompanionBuilder,
      $$SyncMetasTableUpdateCompanionBuilder,
      (
        SyncMetaRow,
        BaseReferences<_$AppDatabase, $SyncMetasTable, SyncMetaRow>,
      ),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required int workspaceId,
      required String query,
      required DateTime searchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> workspaceId,
      Value<String> query,
      Value<DateTime> searchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearchRow,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearchRow,
            BaseReferences<
              _$AppDatabase,
              $RecentSearchesTable,
              RecentSearchRow
            >,
          ),
          RecentSearchRow,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workspaceId = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                workspaceId: workspaceId,
                query: query,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int workspaceId,
                required String query,
                required DateTime searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                workspaceId: workspaceId,
                query: query,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearchRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearchRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearchRow,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearchRow,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearchRow>,
      ),
      RecentSearchRow,
      PrefetchHooks Function()
    >;
typedef $$SongSearchQueueTableCreateCompanionBuilder =
    SongSearchQueueCompanion Function({Value<int> songId});
typedef $$SongSearchQueueTableUpdateCompanionBuilder =
    SongSearchQueueCompanion Function({Value<int> songId});

class $$SongSearchQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SongSearchQueueTable> {
  $$SongSearchQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongSearchQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SongSearchQueueTable> {
  $$SongSearchQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongSearchQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongSearchQueueTable> {
  $$SongSearchQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);
}

class $$SongSearchQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongSearchQueueTable,
          SongSearchQueueRow,
          $$SongSearchQueueTableFilterComposer,
          $$SongSearchQueueTableOrderingComposer,
          $$SongSearchQueueTableAnnotationComposer,
          $$SongSearchQueueTableCreateCompanionBuilder,
          $$SongSearchQueueTableUpdateCompanionBuilder,
          (
            SongSearchQueueRow,
            BaseReferences<
              _$AppDatabase,
              $SongSearchQueueTable,
              SongSearchQueueRow
            >,
          ),
          SongSearchQueueRow,
          PrefetchHooks Function()
        > {
  $$SongSearchQueueTableTableManager(
    _$AppDatabase db,
    $SongSearchQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongSearchQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongSearchQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongSearchQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> songId = const Value.absent(),
          }) => SongSearchQueueCompanion(songId: songId),
          createCompanionCallback: ({
            Value<int> songId = const Value.absent(),
          }) => SongSearchQueueCompanion.insert(songId: songId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongSearchQueueTable, SongSearchQueueRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SongSearchQueueTable,
                    SongSearchQueueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongSearchQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongSearchQueueTable,
      SongSearchQueueRow,
      $$SongSearchQueueTableFilterComposer,
      $$SongSearchQueueTableOrderingComposer,
      $$SongSearchQueueTableAnnotationComposer,
      $$SongSearchQueueTableCreateCompanionBuilder,
      $$SongSearchQueueTableUpdateCompanionBuilder,
      (
        SongSearchQueueRow,
        BaseReferences<
          _$AppDatabase,
          $SongSearchQueueTable,
          SongSearchQueueRow
        >,
      ),
      SongSearchQueueRow,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsQueueTableCreateCompanionBuilder =
    AnalyticsQueueCompanion Function({
      required String id,
      required int userId,
      required String name,
      Value<String?> screen,
      Value<int?> workspaceId,
      required String sessionId,
      Value<String?> properties,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$AnalyticsQueueTableUpdateCompanionBuilder =
    AnalyticsQueueCompanion Function({
      Value<String> id,
      Value<int> userId,
      Value<String> name,
      Value<String?> screen,
      Value<int?> workspaceId,
      Value<String> sessionId,
      Value<String?> properties,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

class $$AnalyticsQueueTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsQueueTable> {
  $$AnalyticsQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsQueueTable> {
  $$AnalyticsQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsQueueTable> {
  $$AnalyticsQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get screen =>
      $composableBuilder(column: $table.screen, builder: (column) => column);

  GeneratedColumn<int> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$AnalyticsQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsQueueTable,
          AnalyticsQueueRow,
          $$AnalyticsQueueTableFilterComposer,
          $$AnalyticsQueueTableOrderingComposer,
          $$AnalyticsQueueTableAnnotationComposer,
          $$AnalyticsQueueTableCreateCompanionBuilder,
          $$AnalyticsQueueTableUpdateCompanionBuilder,
          (
            AnalyticsQueueRow,
            BaseReferences<
              _$AppDatabase,
              $AnalyticsQueueTable,
              AnalyticsQueueRow
            >,
          ),
          AnalyticsQueueRow,
          PrefetchHooks Function()
        > {
  $$AnalyticsQueueTableTableManager(
    _$AppDatabase db,
    $AnalyticsQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalyticsQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> screen = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> properties = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalyticsQueueCompanion(
                id: id,
                userId: userId,
                name: name,
                screen: screen,
                workspaceId: workspaceId,
                sessionId: sessionId,
                properties: properties,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int userId,
                required String name,
                Value<String?> screen = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                required String sessionId,
                Value<String?> properties = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => AnalyticsQueueCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                screen: screen,
                workspaceId: workspaceId,
                sessionId: sessionId,
                properties: properties,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnalyticsQueueTable, AnalyticsQueueRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AnalyticsQueueTable,
                    AnalyticsQueueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsQueueTable,
      AnalyticsQueueRow,
      $$AnalyticsQueueTableFilterComposer,
      $$AnalyticsQueueTableOrderingComposer,
      $$AnalyticsQueueTableAnnotationComposer,
      $$AnalyticsQueueTableCreateCompanionBuilder,
      $$AnalyticsQueueTableUpdateCompanionBuilder,
      (
        AnalyticsQueueRow,
        BaseReferences<_$AppDatabase, $AnalyticsQueueTable, AnalyticsQueueRow>,
      ),
      AnalyticsQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$SongOutboxTableTableManager get songOutbox =>
      $$SongOutboxTableTableManager(_db, _db.songOutbox);
  $$SongEditsTableTableManager get songEdits =>
      $$SongEditsTableTableManager(_db, _db.songEdits);
  $$SongCaposTableTableManager get songCapos =>
      $$SongCaposTableTableManager(_db, _db.songCapos);
  $$SongUpcomingLineUpsTableTableManager get songUpcomingLineUps =>
      $$SongUpcomingLineUpsTableTableManager(_db, _db.songUpcomingLineUps);
  $$DisplayPrefsTableTableManager get displayPrefs =>
      $$DisplayPrefsTableTableManager(_db, _db.displayPrefs);
  $$LineUpsTableTableManager get lineUps =>
      $$LineUpsTableTableManager(_db, _db.lineUps);
  $$LineUpSongsTableTableManager get lineUpSongs =>
      $$LineUpSongsTableTableManager(_db, _db.lineUpSongs);
  $$LineUpSongCaposTableTableManager get lineUpSongCapos =>
      $$LineUpSongCaposTableTableManager(_db, _db.lineUpSongCapos);
  $$LineUpOutboxTableTableManager get lineUpOutbox =>
      $$LineUpOutboxTableTableManager(_db, _db.lineUpOutbox);
  $$LineUpPrepOutboxTableTableManager get lineUpPrepOutbox =>
      $$LineUpPrepOutboxTableTableManager(_db, _db.lineUpPrepOutbox);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$RecentSongAccessesTableTableManager get recentSongAccesses =>
      $$RecentSongAccessesTableTableManager(_db, _db.recentSongAccesses);
  $$SyncMetasTableTableManager get syncMetas =>
      $$SyncMetasTableTableManager(_db, _db.syncMetas);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$SongSearchQueueTableTableManager get songSearchQueue =>
      $$SongSearchQueueTableTableManager(_db, _db.songSearchQueue);
  $$AnalyticsQueueTableTableManager get analyticsQueue =>
      $$AnalyticsQueueTableTableManager(_db, _db.analyticsQueue);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
