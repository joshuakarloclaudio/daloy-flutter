// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NetworkSong {

 int get id; String get title; String? get artist; String? get key; int? get bpm; String? get timeSignature;/// The first lyric lines, for a card's teaser (the list only).
 String? get preview; bool get hasMedia; String get workspaceName; bool get isOwnWorkspace; int get importCount;/// This workspace already has a copy.
 bool get alreadyAdded; String? get content; String? get lyrics; String? get youtubeUrl; String? get spotifyUrl; String? get appleMusicUrl; String? get otherUrl; DateTime? get createdAt;
/// Create a copy of NetworkSong
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkSongCopyWith<NetworkSong> get copyWith => _$NetworkSongCopyWithImpl<NetworkSong>(this as NetworkSong, _$identity);

  /// Serializes this NetworkSong to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkSong;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkSong&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.bpm, _this.bpm) || other.bpm == _this.bpm)&&(identical(other.timeSignature, _this.timeSignature) || other.timeSignature == _this.timeSignature)&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&(identical(other.hasMedia, _this.hasMedia) || other.hasMedia == _this.hasMedia)&&(identical(other.workspaceName, _this.workspaceName) || other.workspaceName == _this.workspaceName)&&(identical(other.isOwnWorkspace, _this.isOwnWorkspace) || other.isOwnWorkspace == _this.isOwnWorkspace)&&(identical(other.importCount, _this.importCount) || other.importCount == _this.importCount)&&(identical(other.alreadyAdded, _this.alreadyAdded) || other.alreadyAdded == _this.alreadyAdded)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.lyrics, _this.lyrics) || other.lyrics == _this.lyrics)&&(identical(other.youtubeUrl, _this.youtubeUrl) || other.youtubeUrl == _this.youtubeUrl)&&(identical(other.spotifyUrl, _this.spotifyUrl) || other.spotifyUrl == _this.spotifyUrl)&&(identical(other.appleMusicUrl, _this.appleMusicUrl) || other.appleMusicUrl == _this.appleMusicUrl)&&(identical(other.otherUrl, _this.otherUrl) || other.otherUrl == _this.otherUrl)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkSong;
  return Object.hashAll([runtimeType,_this.id,_this.title,_this.artist,_this.key,_this.bpm,_this.timeSignature,_this.preview,_this.hasMedia,_this.workspaceName,_this.isOwnWorkspace,_this.importCount,_this.alreadyAdded,_this.content,_this.lyrics,_this.youtubeUrl,_this.spotifyUrl,_this.appleMusicUrl,_this.otherUrl,_this.createdAt]);
}

@override
String toString() {
  final _this = this as NetworkSong;
  return 'NetworkSong(id: ${_this.id}, title: ${_this.title}, artist: ${_this.artist}, key: ${_this.key}, bpm: ${_this.bpm}, timeSignature: ${_this.timeSignature}, preview: ${_this.preview}, hasMedia: ${_this.hasMedia}, workspaceName: ${_this.workspaceName}, isOwnWorkspace: ${_this.isOwnWorkspace}, importCount: ${_this.importCount}, alreadyAdded: ${_this.alreadyAdded}, content: ${_this.content}, lyrics: ${_this.lyrics}, youtubeUrl: ${_this.youtubeUrl}, spotifyUrl: ${_this.spotifyUrl}, appleMusicUrl: ${_this.appleMusicUrl}, otherUrl: ${_this.otherUrl}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NetworkSongCopyWith<$Res>  {
  factory $NetworkSongCopyWith(NetworkSong value, $Res Function(NetworkSong) _then) = _$NetworkSongCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? artist, String? key, int? bpm, String? timeSignature, String? preview, bool hasMedia, String workspaceName, bool isOwnWorkspace, int importCount, bool alreadyAdded, String? content, String? lyrics, String? youtubeUrl, String? spotifyUrl, String? appleMusicUrl, String? otherUrl, DateTime? createdAt
});




}
/// @nodoc
class _$NetworkSongCopyWithImpl<$Res>
    implements $NetworkSongCopyWith<$Res> {
  _$NetworkSongCopyWithImpl(this._self, this._then);

  final NetworkSong _self;
  final $Res Function(NetworkSong) _then;

/// Create a copy of NetworkSong
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = freezed,Object? key = freezed,Object? bpm = freezed,Object? timeSignature = freezed,Object? preview = freezed,Object? hasMedia = null,Object? workspaceName = null,Object? isOwnWorkspace = null,Object? importCount = null,Object? alreadyAdded = null,Object? content = freezed,Object? lyrics = freezed,Object? youtubeUrl = freezed,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? otherUrl = freezed,Object? createdAt = freezed,}) {
  return _then(NetworkSong(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,timeSignature: freezed == timeSignature ? _self.timeSignature : timeSignature // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,hasMedia: null == hasMedia ? _self.hasMedia : hasMedia // ignore: cast_nullable_to_non_nullable
as bool,workspaceName: null == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String,isOwnWorkspace: null == isOwnWorkspace ? _self.isOwnWorkspace : isOwnWorkspace // ignore: cast_nullable_to_non_nullable
as bool,importCount: null == importCount ? _self.importCount : importCount // ignore: cast_nullable_to_non_nullable
as int,alreadyAdded: null == alreadyAdded ? _self.alreadyAdded : alreadyAdded // ignore: cast_nullable_to_non_nullable
as bool,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,otherUrl: freezed == otherUrl ? _self.otherUrl : otherUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkSong].
extension NetworkSongPatterns on NetworkSong {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkSong value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkSong() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkSong value)  $default,){
final _that = this;
switch (_that) {
case _NetworkSong():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkSong value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkSong() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? artist,  String? key,  int? bpm,  String? timeSignature,  String? preview,  bool hasMedia,  String workspaceName,  bool isOwnWorkspace,  int importCount,  bool alreadyAdded,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkSong() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.key,_that.bpm,_that.timeSignature,_that.preview,_that.hasMedia,_that.workspaceName,_that.isOwnWorkspace,_that.importCount,_that.alreadyAdded,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? artist,  String? key,  int? bpm,  String? timeSignature,  String? preview,  bool hasMedia,  String workspaceName,  bool isOwnWorkspace,  int importCount,  bool alreadyAdded,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _NetworkSong():
return $default(_that.id,_that.title,_that.artist,_that.key,_that.bpm,_that.timeSignature,_that.preview,_that.hasMedia,_that.workspaceName,_that.isOwnWorkspace,_that.importCount,_that.alreadyAdded,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? artist,  String? key,  int? bpm,  String? timeSignature,  String? preview,  bool hasMedia,  String workspaceName,  bool isOwnWorkspace,  int importCount,  bool alreadyAdded,  String? content,  String? lyrics,  String? youtubeUrl,  String? spotifyUrl,  String? appleMusicUrl,  String? otherUrl,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NetworkSong() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.key,_that.bpm,_that.timeSignature,_that.preview,_that.hasMedia,_that.workspaceName,_that.isOwnWorkspace,_that.importCount,_that.alreadyAdded,_that.content,_that.lyrics,_that.youtubeUrl,_that.spotifyUrl,_that.appleMusicUrl,_that.otherUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkSong implements NetworkSong {
  const _NetworkSong({required this.id, required this.title, this.artist, this.key, this.bpm, this.timeSignature, this.preview, this.hasMedia = false, required this.workspaceName, this.isOwnWorkspace = false, this.importCount = 0, this.alreadyAdded = false, this.content, this.lyrics, this.youtubeUrl, this.spotifyUrl, this.appleMusicUrl, this.otherUrl, this.createdAt});
  factory _NetworkSong.fromJson(Map<String, dynamic> json) => _$NetworkSongFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? artist;
@override final  String? key;
@override final  int? bpm;
@override final  String? timeSignature;
/// The first lyric lines, for a card's teaser (the list only).
@override final  String? preview;
@override@JsonKey() final  bool hasMedia;
@override final  String workspaceName;
@override@JsonKey() final  bool isOwnWorkspace;
@override@JsonKey() final  int importCount;
/// This workspace already has a copy.
@override@JsonKey() final  bool alreadyAdded;
@override final  String? content;
@override final  String? lyrics;
@override final  String? youtubeUrl;
@override final  String? spotifyUrl;
@override final  String? appleMusicUrl;
@override final  String? otherUrl;
@override final  DateTime? createdAt;

/// Create a copy of NetworkSong
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkSongCopyWith<_NetworkSong> get copyWith => __$NetworkSongCopyWithImpl<_NetworkSong>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkSongToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkSong&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.key, key) || other.key == key)&&(identical(other.bpm, bpm) || other.bpm == bpm)&&(identical(other.timeSignature, timeSignature) || other.timeSignature == timeSignature)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.hasMedia, hasMedia) || other.hasMedia == hasMedia)&&(identical(other.workspaceName, workspaceName) || other.workspaceName == workspaceName)&&(identical(other.isOwnWorkspace, isOwnWorkspace) || other.isOwnWorkspace == isOwnWorkspace)&&(identical(other.importCount, importCount) || other.importCount == importCount)&&(identical(other.alreadyAdded, alreadyAdded) || other.alreadyAdded == alreadyAdded)&&(identical(other.content, content) || other.content == content)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.spotifyUrl, spotifyUrl) || other.spotifyUrl == spotifyUrl)&&(identical(other.appleMusicUrl, appleMusicUrl) || other.appleMusicUrl == appleMusicUrl)&&(identical(other.otherUrl, otherUrl) || other.otherUrl == otherUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,title,artist,key,bpm,timeSignature,preview,hasMedia,workspaceName,isOwnWorkspace,importCount,alreadyAdded,content,lyrics,youtubeUrl,spotifyUrl,appleMusicUrl,otherUrl,createdAt]);
}

@override
String toString() {
    return 'NetworkSong(id: $id, title: $title, artist: $artist, key: $key, bpm: $bpm, timeSignature: $timeSignature, preview: $preview, hasMedia: $hasMedia, workspaceName: $workspaceName, isOwnWorkspace: $isOwnWorkspace, importCount: $importCount, alreadyAdded: $alreadyAdded, content: $content, lyrics: $lyrics, youtubeUrl: $youtubeUrl, spotifyUrl: $spotifyUrl, appleMusicUrl: $appleMusicUrl, otherUrl: $otherUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NetworkSongCopyWith<$Res> implements $NetworkSongCopyWith<$Res> {
  factory _$NetworkSongCopyWith(_NetworkSong value, $Res Function(_NetworkSong) _then) = __$NetworkSongCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? artist, String? key, int? bpm, String? timeSignature, String? preview, bool hasMedia, String workspaceName, bool isOwnWorkspace, int importCount, bool alreadyAdded, String? content, String? lyrics, String? youtubeUrl, String? spotifyUrl, String? appleMusicUrl, String? otherUrl, DateTime? createdAt
});




}
/// @nodoc
class __$NetworkSongCopyWithImpl<$Res>
    implements _$NetworkSongCopyWith<$Res> {
  __$NetworkSongCopyWithImpl(this._self, this._then);

  final _NetworkSong _self;
  final $Res Function(_NetworkSong) _then;

/// Create a copy of NetworkSong
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = freezed,Object? key = freezed,Object? bpm = freezed,Object? timeSignature = freezed,Object? preview = freezed,Object? hasMedia = null,Object? workspaceName = null,Object? isOwnWorkspace = null,Object? importCount = null,Object? alreadyAdded = null,Object? content = freezed,Object? lyrics = freezed,Object? youtubeUrl = freezed,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? otherUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_NetworkSong(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,timeSignature: freezed == timeSignature ? _self.timeSignature : timeSignature // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,hasMedia: null == hasMedia ? _self.hasMedia : hasMedia // ignore: cast_nullable_to_non_nullable
as bool,workspaceName: null == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String,isOwnWorkspace: null == isOwnWorkspace ? _self.isOwnWorkspace : isOwnWorkspace // ignore: cast_nullable_to_non_nullable
as bool,importCount: null == importCount ? _self.importCount : importCount // ignore: cast_nullable_to_non_nullable
as int,alreadyAdded: null == alreadyAdded ? _self.alreadyAdded : alreadyAdded // ignore: cast_nullable_to_non_nullable
as bool,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,otherUrl: freezed == otherUrl ? _self.otherUrl : otherUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NetworkSongPage {

 List<NetworkSong> get songs; String? get nextCursor;
/// Create a copy of NetworkSongPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkSongPageCopyWith<NetworkSongPage> get copyWith => _$NetworkSongPageCopyWithImpl<NetworkSongPage>(this as NetworkSongPage, _$identity);

  /// Serializes this NetworkSongPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkSongPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkSongPage&&const DeepCollectionEquality().equals(other.songs, _this.songs)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkSongPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.songs),_this.nextCursor);
}

@override
String toString() {
  final _this = this as NetworkSongPage;
  return 'NetworkSongPage(songs: ${_this.songs}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $NetworkSongPageCopyWith<$Res>  {
  factory $NetworkSongPageCopyWith(NetworkSongPage value, $Res Function(NetworkSongPage) _then) = _$NetworkSongPageCopyWithImpl;
@useResult
$Res call({
 List<NetworkSong> songs, String? nextCursor
});




}
/// @nodoc
class _$NetworkSongPageCopyWithImpl<$Res>
    implements $NetworkSongPageCopyWith<$Res> {
  _$NetworkSongPageCopyWithImpl(this._self, this._then);

  final NetworkSongPage _self;
  final $Res Function(NetworkSongPage) _then;

/// Create a copy of NetworkSongPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? songs = null,Object? nextCursor = freezed,}) {
  return _then(NetworkSongPage(
songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as List<NetworkSong>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkSongPage].
extension NetworkSongPagePatterns on NetworkSongPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkSongPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkSongPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkSongPage value)  $default,){
final _that = this;
switch (_that) {
case _NetworkSongPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkSongPage value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkSongPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NetworkSong> songs,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkSongPage() when $default != null:
return $default(_that.songs,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NetworkSong> songs,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _NetworkSongPage():
return $default(_that.songs,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NetworkSong> songs,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _NetworkSongPage() when $default != null:
return $default(_that.songs,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkSongPage implements NetworkSongPage {
  const _NetworkSongPage({required  List<NetworkSong> songs, this.nextCursor}): _songs = songs;
  factory _NetworkSongPage.fromJson(Map<String, dynamic> json) => _$NetworkSongPageFromJson(json);

 final  List<NetworkSong> _songs;
@override List<NetworkSong> get songs {
  if (_songs is EqualUnmodifiableListView) return _songs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songs);
}

@override final  String? nextCursor;

/// Create a copy of NetworkSongPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkSongPageCopyWith<_NetworkSongPage> get copyWith => __$NetworkSongPageCopyWithImpl<_NetworkSongPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkSongPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkSongPage&&const DeepCollectionEquality().equals(other.songs, _songs)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_songs),nextCursor);
}

@override
String toString() {
    return 'NetworkSongPage(songs: $songs, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$NetworkSongPageCopyWith<$Res> implements $NetworkSongPageCopyWith<$Res> {
  factory _$NetworkSongPageCopyWith(_NetworkSongPage value, $Res Function(_NetworkSongPage) _then) = __$NetworkSongPageCopyWithImpl;
@override @useResult
$Res call({
 List<NetworkSong> songs, String? nextCursor
});




}
/// @nodoc
class __$NetworkSongPageCopyWithImpl<$Res>
    implements _$NetworkSongPageCopyWith<$Res> {
  __$NetworkSongPageCopyWithImpl(this._self, this._then);

  final _NetworkSongPage _self;
  final $Res Function(_NetworkSongPage) _then;

/// Create a copy of NetworkSongPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? songs = null,Object? nextCursor = freezed,}) {
  return _then(_NetworkSongPage(
songs: null == songs ? _self._songs : songs // ignore: cast_nullable_to_non_nullable
as List<NetworkSong>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
