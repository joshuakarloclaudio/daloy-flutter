// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveSession {

 int get id; int get lineUpId; int get currentSongIndex; String? get activeSectionIdChords; String? get activeSectionIdLyrics; int get participantCount; int get startedByUserId; String get startedByUserName; DateTime get startedAt;/// Who moves the session, when someone has taken the lead (opt-in).
 int? get leaderUserId; String? get leaderName;
/// Create a copy of LiveSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveSessionCopyWith<LiveSession> get copyWith => _$LiveSessionCopyWithImpl<LiveSession>(this as LiveSession, _$identity);

  /// Serializes this LiveSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineUpId, _this.lineUpId) || other.lineUpId == _this.lineUpId)&&(identical(other.currentSongIndex, _this.currentSongIndex) || other.currentSongIndex == _this.currentSongIndex)&&(identical(other.activeSectionIdChords, _this.activeSectionIdChords) || other.activeSectionIdChords == _this.activeSectionIdChords)&&(identical(other.activeSectionIdLyrics, _this.activeSectionIdLyrics) || other.activeSectionIdLyrics == _this.activeSectionIdLyrics)&&(identical(other.participantCount, _this.participantCount) || other.participantCount == _this.participantCount)&&(identical(other.startedByUserId, _this.startedByUserId) || other.startedByUserId == _this.startedByUserId)&&(identical(other.startedByUserName, _this.startedByUserName) || other.startedByUserName == _this.startedByUserName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.leaderUserId, _this.leaderUserId) || other.leaderUserId == _this.leaderUserId)&&(identical(other.leaderName, _this.leaderName) || other.leaderName == _this.leaderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveSession;
  return Object.hash(runtimeType,_this.id,_this.lineUpId,_this.currentSongIndex,_this.activeSectionIdChords,_this.activeSectionIdLyrics,_this.participantCount,_this.startedByUserId,_this.startedByUserName,_this.startedAt,_this.leaderUserId,_this.leaderName);
}

@override
String toString() {
  final _this = this as LiveSession;
  return 'LiveSession(id: ${_this.id}, lineUpId: ${_this.lineUpId}, currentSongIndex: ${_this.currentSongIndex}, activeSectionIdChords: ${_this.activeSectionIdChords}, activeSectionIdLyrics: ${_this.activeSectionIdLyrics}, participantCount: ${_this.participantCount}, startedByUserId: ${_this.startedByUserId}, startedByUserName: ${_this.startedByUserName}, startedAt: ${_this.startedAt}, leaderUserId: ${_this.leaderUserId}, leaderName: ${_this.leaderName})';
}


}

/// @nodoc
abstract mixin class $LiveSessionCopyWith<$Res>  {
  factory $LiveSessionCopyWith(LiveSession value, $Res Function(LiveSession) _then) = _$LiveSessionCopyWithImpl;
@useResult
$Res call({
 int id, int lineUpId, int currentSongIndex, String? activeSectionIdChords, String? activeSectionIdLyrics, int participantCount, int startedByUserId, String startedByUserName, DateTime startedAt, int? leaderUserId, String? leaderName
});




}
/// @nodoc
class _$LiveSessionCopyWithImpl<$Res>
    implements $LiveSessionCopyWith<$Res> {
  _$LiveSessionCopyWithImpl(this._self, this._then);

  final LiveSession _self;
  final $Res Function(LiveSession) _then;

/// Create a copy of LiveSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineUpId = null,Object? currentSongIndex = null,Object? activeSectionIdChords = freezed,Object? activeSectionIdLyrics = freezed,Object? participantCount = null,Object? startedByUserId = null,Object? startedByUserName = null,Object? startedAt = null,Object? leaderUserId = freezed,Object? leaderName = freezed,}) {
  return _then(LiveSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineUpId: null == lineUpId ? _self.lineUpId : lineUpId // ignore: cast_nullable_to_non_nullable
as int,currentSongIndex: null == currentSongIndex ? _self.currentSongIndex : currentSongIndex // ignore: cast_nullable_to_non_nullable
as int,activeSectionIdChords: freezed == activeSectionIdChords ? _self.activeSectionIdChords : activeSectionIdChords // ignore: cast_nullable_to_non_nullable
as String?,activeSectionIdLyrics: freezed == activeSectionIdLyrics ? _self.activeSectionIdLyrics : activeSectionIdLyrics // ignore: cast_nullable_to_non_nullable
as String?,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,startedByUserId: null == startedByUserId ? _self.startedByUserId : startedByUserId // ignore: cast_nullable_to_non_nullable
as int,startedByUserName: null == startedByUserName ? _self.startedByUserName : startedByUserName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leaderUserId: freezed == leaderUserId ? _self.leaderUserId : leaderUserId // ignore: cast_nullable_to_non_nullable
as int?,leaderName: freezed == leaderName ? _self.leaderName : leaderName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveSession].
extension LiveSessionPatterns on LiveSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveSession value)  $default,){
final _that = this;
switch (_that) {
case _LiveSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveSession value)?  $default,){
final _that = this;
switch (_that) {
case _LiveSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lineUpId,  int currentSongIndex,  String? activeSectionIdChords,  String? activeSectionIdLyrics,  int participantCount,  int startedByUserId,  String startedByUserName,  DateTime startedAt,  int? leaderUserId,  String? leaderName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveSession() when $default != null:
return $default(_that.id,_that.lineUpId,_that.currentSongIndex,_that.activeSectionIdChords,_that.activeSectionIdLyrics,_that.participantCount,_that.startedByUserId,_that.startedByUserName,_that.startedAt,_that.leaderUserId,_that.leaderName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lineUpId,  int currentSongIndex,  String? activeSectionIdChords,  String? activeSectionIdLyrics,  int participantCount,  int startedByUserId,  String startedByUserName,  DateTime startedAt,  int? leaderUserId,  String? leaderName)  $default,) {final _that = this;
switch (_that) {
case _LiveSession():
return $default(_that.id,_that.lineUpId,_that.currentSongIndex,_that.activeSectionIdChords,_that.activeSectionIdLyrics,_that.participantCount,_that.startedByUserId,_that.startedByUserName,_that.startedAt,_that.leaderUserId,_that.leaderName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lineUpId,  int currentSongIndex,  String? activeSectionIdChords,  String? activeSectionIdLyrics,  int participantCount,  int startedByUserId,  String startedByUserName,  DateTime startedAt,  int? leaderUserId,  String? leaderName)?  $default,) {final _that = this;
switch (_that) {
case _LiveSession() when $default != null:
return $default(_that.id,_that.lineUpId,_that.currentSongIndex,_that.activeSectionIdChords,_that.activeSectionIdLyrics,_that.participantCount,_that.startedByUserId,_that.startedByUserName,_that.startedAt,_that.leaderUserId,_that.leaderName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveSession implements LiveSession {
  const _LiveSession({required this.id, required this.lineUpId, this.currentSongIndex = 0, this.activeSectionIdChords, this.activeSectionIdLyrics, this.participantCount = 0, required this.startedByUserId, required this.startedByUserName, required this.startedAt, this.leaderUserId, this.leaderName});
  factory _LiveSession.fromJson(Map<String, dynamic> json) => _$LiveSessionFromJson(json);

@override final  int id;
@override final  int lineUpId;
@override@JsonKey() final  int currentSongIndex;
@override final  String? activeSectionIdChords;
@override final  String? activeSectionIdLyrics;
@override@JsonKey() final  int participantCount;
@override final  int startedByUserId;
@override final  String startedByUserName;
@override final  DateTime startedAt;
/// Who moves the session, when someone has taken the lead (opt-in).
@override final  int? leaderUserId;
@override final  String? leaderName;

/// Create a copy of LiveSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveSessionCopyWith<_LiveSession> get copyWith => __$LiveSessionCopyWithImpl<_LiveSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveSession&&(identical(other.id, id) || other.id == id)&&(identical(other.lineUpId, lineUpId) || other.lineUpId == lineUpId)&&(identical(other.currentSongIndex, currentSongIndex) || other.currentSongIndex == currentSongIndex)&&(identical(other.activeSectionIdChords, activeSectionIdChords) || other.activeSectionIdChords == activeSectionIdChords)&&(identical(other.activeSectionIdLyrics, activeSectionIdLyrics) || other.activeSectionIdLyrics == activeSectionIdLyrics)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.startedByUserId, startedByUserId) || other.startedByUserId == startedByUserId)&&(identical(other.startedByUserName, startedByUserName) || other.startedByUserName == startedByUserName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.leaderUserId, leaderUserId) || other.leaderUserId == leaderUserId)&&(identical(other.leaderName, leaderName) || other.leaderName == leaderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lineUpId,currentSongIndex,activeSectionIdChords,activeSectionIdLyrics,participantCount,startedByUserId,startedByUserName,startedAt,leaderUserId,leaderName);
}

@override
String toString() {
    return 'LiveSession(id: $id, lineUpId: $lineUpId, currentSongIndex: $currentSongIndex, activeSectionIdChords: $activeSectionIdChords, activeSectionIdLyrics: $activeSectionIdLyrics, participantCount: $participantCount, startedByUserId: $startedByUserId, startedByUserName: $startedByUserName, startedAt: $startedAt, leaderUserId: $leaderUserId, leaderName: $leaderName)';
}


}

/// @nodoc
abstract mixin class _$LiveSessionCopyWith<$Res> implements $LiveSessionCopyWith<$Res> {
  factory _$LiveSessionCopyWith(_LiveSession value, $Res Function(_LiveSession) _then) = __$LiveSessionCopyWithImpl;
@override @useResult
$Res call({
 int id, int lineUpId, int currentSongIndex, String? activeSectionIdChords, String? activeSectionIdLyrics, int participantCount, int startedByUserId, String startedByUserName, DateTime startedAt, int? leaderUserId, String? leaderName
});




}
/// @nodoc
class __$LiveSessionCopyWithImpl<$Res>
    implements _$LiveSessionCopyWith<$Res> {
  __$LiveSessionCopyWithImpl(this._self, this._then);

  final _LiveSession _self;
  final $Res Function(_LiveSession) _then;

/// Create a copy of LiveSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineUpId = null,Object? currentSongIndex = null,Object? activeSectionIdChords = freezed,Object? activeSectionIdLyrics = freezed,Object? participantCount = null,Object? startedByUserId = null,Object? startedByUserName = null,Object? startedAt = null,Object? leaderUserId = freezed,Object? leaderName = freezed,}) {
  return _then(_LiveSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lineUpId: null == lineUpId ? _self.lineUpId : lineUpId // ignore: cast_nullable_to_non_nullable
as int,currentSongIndex: null == currentSongIndex ? _self.currentSongIndex : currentSongIndex // ignore: cast_nullable_to_non_nullable
as int,activeSectionIdChords: freezed == activeSectionIdChords ? _self.activeSectionIdChords : activeSectionIdChords // ignore: cast_nullable_to_non_nullable
as String?,activeSectionIdLyrics: freezed == activeSectionIdLyrics ? _self.activeSectionIdLyrics : activeSectionIdLyrics // ignore: cast_nullable_to_non_nullable
as String?,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,startedByUserId: null == startedByUserId ? _self.startedByUserId : startedByUserId // ignore: cast_nullable_to_non_nullable
as int,startedByUserName: null == startedByUserName ? _self.startedByUserName : startedByUserName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leaderUserId: freezed == leaderUserId ? _self.leaderUserId : leaderUserId // ignore: cast_nullable_to_non_nullable
as int?,leaderName: freezed == leaderName ? _self.leaderName : leaderName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
