// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {

 int get id; String get title; String? get artist; String? get key; int? get transposition; int? get bpm; String? get timeSignature; String? get content; String? get lyrics; String? get youtubeUrl; String? get spotifyUrl; String? get appleMusicUrl; String? get otherUrl; bool get isPublic; DateTime? get createdAt;/// When it was last added to a line-up. Only the library list carries it.
 DateTime? get lastUsedAt;/// Bumped by the server on every change.
 int get version;
/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongCopyWith<Song> get copyWith => _$SongCopyWithImpl<Song>(this as Song, _$identity);

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Song;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Song&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.transposition, _this.transposition) || other.transposition == _this.transposition)&&(identical(other.bpm, _this.bpm) || other.bpm == _this.bpm)&&(identical(other.timeSignature, _this.timeSignature) || other.timeSignature == _this.timeSignature)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.lyrics, _this.lyrics) || other.lyrics == _this.lyrics)&&(identical(other.youtubeUrl, _this.youtubeUrl) || other.youtubeUrl == _this.youtubeUrl)&&(identical(other.spotifyUrl, _this.spotifyUrl) || other.spotifyUrl == _this.spotifyUrl)&&(identical(other.appleMusicUrl, _this.appleMusicUrl) || other.appleMusicUrl == _this.appleMusicUrl)&&(identical(other.otherUrl, _this.otherUrl) || other.otherUrl == _this.otherUrl)&&(identical(other.isPublic, _this.isPublic) || other.isPublic == _this.isPublic)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Song;
  return Object.hash(runtimeType,_this.id,_this.title,_this.artist,_this.key,_this.transposition,_this.bpm,_this.timeSignature,_this.content,_this.lyrics,_this.youtubeUrl,_this.spotifyUrl,_this.appleMusicUrl,_this.otherUrl,_this.isPublic,_this.createdAt,_this.lastUsedAt,_this.version);
}

@override
String toString() {
  final _this = this as Song;
  return 'Song(id: ${_this.id}, title: ${_this.title}, artist: ${_this.artist}, key: ${_this.key}, transposition: ${_this.transposition}, bpm: ${_this.bpm}, timeSignature: ${_this.timeSignature}, content: ${_this.content}, lyrics: ${_this.lyrics}, youtubeUrl: ${_this.youtubeUrl}, spotifyUrl: ${_this.spotifyUrl}, appleMusicUrl: ${_this.appleMusicUrl}, otherUrl: ${_this.otherUrl}, isPublic: ${_this.isPublic}, createdAt: ${_this.createdAt}, lastUsedAt: ${_this.lastUsedAt}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $SongCopyWith<$Res>  {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) = _$SongCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? artist, String? key, int? transposition, int? bpm, String? timeSignature, String? content, String? lyrics, String? youtubeUrl, String? spotifyUrl, String? appleMusicUrl, String? otherUrl, bool isPublic, DateTime? createdAt, DateTime? lastUsedAt, int version
});




}
/// @nodoc
class _$SongCopyWithImpl<$Res>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = freezed,Object? key = freezed,Object? transposition = freezed,Object? bpm = freezed,Object? timeSignature = freezed,Object? content = freezed,Object? lyrics = freezed,Object? youtubeUrl = freezed,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? otherUrl = freezed,Object? isPublic = null,Object? createdAt = freezed,Object? lastUsedAt = freezed,Object? version = null,}) {
  return _then(Song(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,transposition: freezed == transposition ? _self.transposition : transposition // ignore: cast_nullable_to_non_nullable
as int?,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,timeSignature: freezed == timeSignature ? _self.timeSignature : timeSignature // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,otherUrl: freezed == otherUrl ? _self.otherUrl : otherUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Song value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Song value)  $default,){
final _that = this;
switch (_that) {
case _Song():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Song value)?  $default,){
final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? artist,  String? key,  int? transposition,  int? bpm,  String? timeSignature,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  bool isPublic,  DateTime? createdAt,  DateTime? lastUsedAt,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.key,_that.transposition,_that.bpm,_that.timeSignature,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.isPublic,_that.createdAt,_that.lastUsedAt,_that.version);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? artist,  String? key,  int? transposition,  int? bpm,  String? timeSignature,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  bool isPublic,  DateTime? createdAt,  DateTime? lastUsedAt,  int version)  $default,) {final _that = this;
switch (_that) {
case _Song():
return $default(_that.id,_that.title,_that.artist,_that.key,_that.transposition,_that.bpm,_that.timeSignature,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.isPublic,_that.createdAt,_that.lastUsedAt,_that.version);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? artist,  String? key,  int? transposition,  int? bpm,  String? timeSignature,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  bool isPublic,  DateTime? createdAt,  DateTime? lastUsedAt,  int version)?  $default,) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.key,_that.transposition,_that.bpm,_that.timeSignature,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.isPublic,_that.createdAt,_that.lastUsedAt,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Song extends Song {
  const _Song({required this.id, required this.title, this.artist, this.key, this.transposition, this.bpm, this.timeSignature, this.content, this.lyrics, this.youtubeUrl, this.spotifyUrl, this.appleMusicUrl, this.otherUrl, this.isPublic = false, this.createdAt, this.lastUsedAt, this.version = 1}): super._();
  factory _Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? artist;
@override final  String? key;
@override final  int? transposition;
@override final  int? bpm;
@override final  String? timeSignature;
@override final  String? content;
@override final  String? lyrics;
@override final  String? youtubeUrl;
@override final  String? spotifyUrl;
@override final  String? appleMusicUrl;
@override final  String? otherUrl;
@override@JsonKey() final  bool isPublic;
@override final  DateTime? createdAt;
/// When it was last added to a line-up. Only the library list carries it.
@override final  DateTime? lastUsedAt;
/// Bumped by the server on every change.
@override@JsonKey() final  int version;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongCopyWith<_Song> get copyWith => __$SongCopyWithImpl<_Song>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.key, key) || other.key == key)&&(identical(other.transposition, transposition) || other.transposition == transposition)&&(identical(other.bpm, bpm) || other.bpm == bpm)&&(identical(other.timeSignature, timeSignature) || other.timeSignature == timeSignature)&&(identical(other.content, content) || other.content == content)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.spotifyUrl, spotifyUrl) || other.spotifyUrl == spotifyUrl)&&(identical(other.appleMusicUrl, appleMusicUrl) || other.appleMusicUrl == appleMusicUrl)&&(identical(other.otherUrl, otherUrl) || other.otherUrl == otherUrl)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,artist,key,transposition,bpm,timeSignature,content,lyrics,youtubeUrl,spotifyUrl,appleMusicUrl,otherUrl,isPublic,createdAt,lastUsedAt,version);
}

@override
String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, key: $key, transposition: $transposition, bpm: $bpm, timeSignature: $timeSignature, content: $content, lyrics: $lyrics, youtubeUrl: $youtubeUrl, spotifyUrl: $spotifyUrl, appleMusicUrl: $appleMusicUrl, otherUrl: $otherUrl, isPublic: $isPublic, createdAt: $createdAt, lastUsedAt: $lastUsedAt, version: $version)';
}


}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) = __$SongCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? artist, String? key, int? transposition, int? bpm, String? timeSignature, String? content, String? lyrics, String? youtubeUrl, String? spotifyUrl, String? appleMusicUrl, String? otherUrl, bool isPublic, DateTime? createdAt, DateTime? lastUsedAt, int version
});




}
/// @nodoc
class __$SongCopyWithImpl<$Res>
    implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = freezed,Object? key = freezed,Object? transposition = freezed,Object? bpm = freezed,Object? timeSignature = freezed,Object? content = freezed,Object? lyrics = freezed,Object? youtubeUrl = freezed,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? otherUrl = freezed,Object? isPublic = null,Object? createdAt = freezed,Object? lastUsedAt = freezed,Object? version = null,}) {
  return _then(_Song(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,transposition: freezed == transposition ? _self.transposition : transposition // ignore: cast_nullable_to_non_nullable
as int?,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,timeSignature: freezed == timeSignature ? _self.timeSignature : timeSignature // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,otherUrl: freezed == otherUrl ? _self.otherUrl : otherUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SongsPage {

 List<Song> get data; PageMeta get meta;
/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongsPageCopyWith<SongsPage> get copyWith => _$SongsPageCopyWithImpl<SongsPage>(this as SongsPage, _$identity);

  /// Serializes this SongsPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SongsPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongsPage&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.meta, _this.meta) || other.meta == _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SongsPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.meta);
}

@override
String toString() {
  final _this = this as SongsPage;
  return 'SongsPage(data: ${_this.data}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $SongsPageCopyWith<$Res>  {
  factory $SongsPageCopyWith(SongsPage value, $Res Function(SongsPage) _then) = _$SongsPageCopyWithImpl;
@useResult
$Res call({
 List<Song> data, PageMeta meta
});


$PageMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$SongsPageCopyWithImpl<$Res>
    implements $SongsPageCopyWith<$Res> {
  _$SongsPageCopyWithImpl(this._self, this._then);

  final SongsPage _self;
  final $Res Function(SongsPage) _then;

/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? meta = null,}) {
  return _then(SongsPage(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<Song>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PageMeta,
  ));
}
/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageMetaCopyWith<$Res> get meta {
  
  return $PageMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [SongsPage].
extension SongsPagePatterns on SongsPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongsPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongsPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongsPage value)  $default,){
final _that = this;
switch (_that) {
case _SongsPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongsPage value)?  $default,){
final _that = this;
switch (_that) {
case _SongsPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Song> data,  PageMeta meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongsPage() when $default != null:
return $default(_that.data,_that.meta);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Song> data,  PageMeta meta)  $default,) {final _that = this;
switch (_that) {
case _SongsPage():
return $default(_that.data,_that.meta);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Song> data,  PageMeta meta)?  $default,) {final _that = this;
switch (_that) {
case _SongsPage() when $default != null:
return $default(_that.data,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongsPage implements SongsPage {
  const _SongsPage({required  List<Song> data, required this.meta}): _data = data;
  factory _SongsPage.fromJson(Map<String, dynamic> json) => _$SongsPageFromJson(json);

 final  List<Song> _data;
@override List<Song> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  PageMeta meta;

/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongsPageCopyWith<_SongsPage> get copyWith => __$SongsPageCopyWithImpl<_SongsPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongsPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongsPage&&const DeepCollectionEquality().equals(other.data, _data)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),meta);
}

@override
String toString() {
    return 'SongsPage(data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$SongsPageCopyWith<$Res> implements $SongsPageCopyWith<$Res> {
  factory _$SongsPageCopyWith(_SongsPage value, $Res Function(_SongsPage) _then) = __$SongsPageCopyWithImpl;
@override @useResult
$Res call({
 List<Song> data, PageMeta meta
});


@override $PageMetaCopyWith<$Res> get meta;

}
/// @nodoc
class __$SongsPageCopyWithImpl<$Res>
    implements _$SongsPageCopyWith<$Res> {
  __$SongsPageCopyWithImpl(this._self, this._then);

  final _SongsPage _self;
  final $Res Function(_SongsPage) _then;

/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? meta = null,}) {
  return _then(_SongsPage(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<Song>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PageMeta,
  ));
}

/// Create a copy of SongsPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageMetaCopyWith<$Res> get meta {
  
  return $PageMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$PageMeta {

 int get currentPage; int get lastPage; int get total;
/// Create a copy of PageMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageMetaCopyWith<PageMeta> get copyWith => _$PageMetaCopyWithImpl<PageMeta>(this as PageMeta, _$identity);

  /// Serializes this PageMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PageMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageMeta&&(identical(other.currentPage, _this.currentPage) || other.currentPage == _this.currentPage)&&(identical(other.lastPage, _this.lastPage) || other.lastPage == _this.lastPage)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PageMeta;
  return Object.hash(runtimeType,_this.currentPage,_this.lastPage,_this.total);
}

@override
String toString() {
  final _this = this as PageMeta;
  return 'PageMeta(currentPage: ${_this.currentPage}, lastPage: ${_this.lastPage}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $PageMetaCopyWith<$Res>  {
  factory $PageMetaCopyWith(PageMeta value, $Res Function(PageMeta) _then) = _$PageMetaCopyWithImpl;
@useResult
$Res call({
 int currentPage, int lastPage, int total
});




}
/// @nodoc
class _$PageMetaCopyWithImpl<$Res>
    implements $PageMetaCopyWith<$Res> {
  _$PageMetaCopyWithImpl(this._self, this._then);

  final PageMeta _self;
  final $Res Function(PageMeta) _then;

/// Create a copy of PageMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? lastPage = null,Object? total = null,}) {
  return _then(PageMeta(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageMeta].
extension PageMetaPatterns on PageMeta {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageMeta() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageMeta value)  $default,){
final _that = this;
switch (_that) {
case _PageMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageMeta value)?  $default,){
final _that = this;
switch (_that) {
case _PageMeta() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentPage,  int lastPage,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageMeta() when $default != null:
return $default(_that.currentPage,_that.lastPage,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentPage,  int lastPage,  int total)  $default,) {final _that = this;
switch (_that) {
case _PageMeta():
return $default(_that.currentPage,_that.lastPage,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentPage,  int lastPage,  int total)?  $default,) {final _that = this;
switch (_that) {
case _PageMeta() when $default != null:
return $default(_that.currentPage,_that.lastPage,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageMeta implements PageMeta {
  const _PageMeta({required this.currentPage, required this.lastPage, required this.total});
  factory _PageMeta.fromJson(Map<String, dynamic> json) => _$PageMetaFromJson(json);

@override final  int currentPage;
@override final  int lastPage;
@override final  int total;

/// Create a copy of PageMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageMetaCopyWith<_PageMeta> get copyWith => __$PageMetaCopyWithImpl<_PageMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageMeta&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentPage,lastPage,total);
}

@override
String toString() {
    return 'PageMeta(currentPage: $currentPage, lastPage: $lastPage, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PageMetaCopyWith<$Res> implements $PageMetaCopyWith<$Res> {
  factory _$PageMetaCopyWith(_PageMeta value, $Res Function(_PageMeta) _then) = __$PageMetaCopyWithImpl;
@override @useResult
$Res call({
 int currentPage, int lastPage, int total
});




}
/// @nodoc
class __$PageMetaCopyWithImpl<$Res>
    implements _$PageMetaCopyWith<$Res> {
  __$PageMetaCopyWithImpl(this._self, this._then);

  final _PageMeta _self;
  final $Res Function(_PageMeta) _then;

/// Create a copy of PageMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? lastPage = null,Object? total = null,}) {
  return _then(_PageMeta(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
