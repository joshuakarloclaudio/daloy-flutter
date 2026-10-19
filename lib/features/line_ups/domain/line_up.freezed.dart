// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_up.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LineUp {

 int get id; String get title;/// `YYYY-MM-DD`.
 String get date; String? get worshipLeader; int get songsCount; int get version;
/// Create a copy of LineUp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpCopyWith<LineUp> get copyWith => _$LineUpCopyWithImpl<LineUp>(this as LineUp, _$identity);

  /// Serializes this LineUp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUp&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.worshipLeader, _this.worshipLeader) || other.worshipLeader == _this.worshipLeader)&&(identical(other.songsCount, _this.songsCount) || other.songsCount == _this.songsCount)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUp;
  return Object.hash(runtimeType,_this.id,_this.title,_this.date,_this.worshipLeader,_this.songsCount,_this.version);
}

@override
String toString() {
  final _this = this as LineUp;
  return 'LineUp(id: ${_this.id}, title: ${_this.title}, date: ${_this.date}, worshipLeader: ${_this.worshipLeader}, songsCount: ${_this.songsCount}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $LineUpCopyWith<$Res>  {
  factory $LineUpCopyWith(LineUp value, $Res Function(LineUp) _then) = _$LineUpCopyWithImpl;
@useResult
$Res call({
 int id, String title, String date, String? worshipLeader, int songsCount, int version
});




}
/// @nodoc
class _$LineUpCopyWithImpl<$Res>
    implements $LineUpCopyWith<$Res> {
  _$LineUpCopyWithImpl(this._self, this._then);

  final LineUp _self;
  final $Res Function(LineUp) _then;

/// Create a copy of LineUp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? worshipLeader = freezed,Object? songsCount = null,Object? version = null,}) {
  return _then(LineUp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: freezed == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String?,songsCount: null == songsCount ? _self.songsCount : songsCount // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUp].
extension LineUpPatterns on LineUp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUp value)  $default,){
final _that = this;
switch (_that) {
case _LineUp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUp value)?  $default,){
final _that = this;
switch (_that) {
case _LineUp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUp() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  int version)  $default,) {final _that = this;
switch (_that) {
case _LineUp():
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  int version)?  $default,) {final _that = this;
switch (_that) {
case _LineUp() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUp extends LineUp {
  const _LineUp({required this.id, required this.title, required this.date, this.worshipLeader, this.songsCount = 0, this.version = 1}): super._();
  factory _LineUp.fromJson(Map<String, dynamic> json) => _$LineUpFromJson(json);

@override final  int id;
@override final  String title;
/// `YYYY-MM-DD`.
@override final  String date;
@override final  String? worshipLeader;
@override@JsonKey() final  int songsCount;
@override@JsonKey() final  int version;

/// Create a copy of LineUp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpCopyWith<_LineUp> get copyWith => __$LineUpCopyWithImpl<_LineUp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUp&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.worshipLeader, worshipLeader) || other.worshipLeader == worshipLeader)&&(identical(other.songsCount, songsCount) || other.songsCount == songsCount)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,date,worshipLeader,songsCount,version);
}

@override
String toString() {
    return 'LineUp(id: $id, title: $title, date: $date, worshipLeader: $worshipLeader, songsCount: $songsCount, version: $version)';
}


}

/// @nodoc
abstract mixin class _$LineUpCopyWith<$Res> implements $LineUpCopyWith<$Res> {
  factory _$LineUpCopyWith(_LineUp value, $Res Function(_LineUp) _then) = __$LineUpCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String date, String? worshipLeader, int songsCount, int version
});




}
/// @nodoc
class __$LineUpCopyWithImpl<$Res>
    implements _$LineUpCopyWith<$Res> {
  __$LineUpCopyWithImpl(this._self, this._then);

  final _LineUp _self;
  final $Res Function(_LineUp) _then;

/// Create a copy of LineUp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? worshipLeader = freezed,Object? songsCount = null,Object? version = null,}) {
  return _then(_LineUp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: freezed == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String?,songsCount: null == songsCount ? _self.songsCount : songsCount // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LineUpListPage {

 List<LineUp> get lineUps;
/// Create a copy of LineUpListPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpListPageCopyWith<LineUpListPage> get copyWith => _$LineUpListPageCopyWithImpl<LineUpListPage>(this as LineUpListPage, _$identity);

  /// Serializes this LineUpListPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUpListPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpListPage&&const DeepCollectionEquality().equals(other.lineUps, _this.lineUps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUpListPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lineUps));
}

@override
String toString() {
  final _this = this as LineUpListPage;
  return 'LineUpListPage(lineUps: ${_this.lineUps})';
}


}

/// @nodoc
abstract mixin class $LineUpListPageCopyWith<$Res>  {
  factory $LineUpListPageCopyWith(LineUpListPage value, $Res Function(LineUpListPage) _then) = _$LineUpListPageCopyWithImpl;
@useResult
$Res call({
 List<LineUp> lineUps
});




}
/// @nodoc
class _$LineUpListPageCopyWithImpl<$Res>
    implements $LineUpListPageCopyWith<$Res> {
  _$LineUpListPageCopyWithImpl(this._self, this._then);

  final LineUpListPage _self;
  final $Res Function(LineUpListPage) _then;

/// Create a copy of LineUpListPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUps = null,}) {
  return _then(LineUpListPage(
lineUps: null == lineUps ? _self.lineUps : lineUps // ignore: cast_nullable_to_non_nullable
as List<LineUp>,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUpListPage].
extension LineUpListPagePatterns on LineUpListPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpListPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpListPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpListPage value)  $default,){
final _that = this;
switch (_that) {
case _LineUpListPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpListPage value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpListPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LineUp> lineUps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpListPage() when $default != null:
return $default(_that.lineUps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LineUp> lineUps)  $default,) {final _that = this;
switch (_that) {
case _LineUpListPage():
return $default(_that.lineUps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LineUp> lineUps)?  $default,) {final _that = this;
switch (_that) {
case _LineUpListPage() when $default != null:
return $default(_that.lineUps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUpListPage implements LineUpListPage {
  const _LineUpListPage({required  List<LineUp> lineUps}): _lineUps = lineUps;
  factory _LineUpListPage.fromJson(Map<String, dynamic> json) => _$LineUpListPageFromJson(json);

 final  List<LineUp> _lineUps;
@override List<LineUp> get lineUps {
  if (_lineUps is EqualUnmodifiableListView) return _lineUps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineUps);
}


/// Create a copy of LineUpListPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpListPageCopyWith<_LineUpListPage> get copyWith => __$LineUpListPageCopyWithImpl<_LineUpListPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpListPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpListPage&&const DeepCollectionEquality().equals(other.lineUps, _lineUps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lineUps));
}

@override
String toString() {
    return 'LineUpListPage(lineUps: $lineUps)';
}


}

/// @nodoc
abstract mixin class _$LineUpListPageCopyWith<$Res> implements $LineUpListPageCopyWith<$Res> {
  factory _$LineUpListPageCopyWith(_LineUpListPage value, $Res Function(_LineUpListPage) _then) = __$LineUpListPageCopyWithImpl;
@override @useResult
$Res call({
 List<LineUp> lineUps
});




}
/// @nodoc
class __$LineUpListPageCopyWithImpl<$Res>
    implements _$LineUpListPageCopyWith<$Res> {
  __$LineUpListPageCopyWithImpl(this._self, this._then);

  final _LineUpListPage _self;
  final $Res Function(_LineUpListPage) _then;

/// Create a copy of LineUpListPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineUps = null,}) {
  return _then(_LineUpListPage(
lineUps: null == lineUps ? _self._lineUps : lineUps // ignore: cast_nullable_to_non_nullable
as List<LineUp>,
  ));
}


}


/// @nodoc
mixin _$LineUpDetail {

 int get id; String get title; String get date; String? get worshipLeader; int get songsCount; List<LineUpSongEntry> get songs; int get version;
/// Create a copy of LineUpDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpDetailCopyWith<LineUpDetail> get copyWith => _$LineUpDetailCopyWithImpl<LineUpDetail>(this as LineUpDetail, _$identity);

  /// Serializes this LineUpDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUpDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.worshipLeader, _this.worshipLeader) || other.worshipLeader == _this.worshipLeader)&&(identical(other.songsCount, _this.songsCount) || other.songsCount == _this.songsCount)&&const DeepCollectionEquality().equals(other.songs, _this.songs)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUpDetail;
  return Object.hash(runtimeType,_this.id,_this.title,_this.date,_this.worshipLeader,_this.songsCount,const DeepCollectionEquality().hash(_this.songs),_this.version);
}

@override
String toString() {
  final _this = this as LineUpDetail;
  return 'LineUpDetail(id: ${_this.id}, title: ${_this.title}, date: ${_this.date}, worshipLeader: ${_this.worshipLeader}, songsCount: ${_this.songsCount}, songs: ${_this.songs}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $LineUpDetailCopyWith<$Res>  {
  factory $LineUpDetailCopyWith(LineUpDetail value, $Res Function(LineUpDetail) _then) = _$LineUpDetailCopyWithImpl;
@useResult
$Res call({
 int id, String title, String date, String? worshipLeader, int songsCount, List<LineUpSongEntry> songs, int version
});




}
/// @nodoc
class _$LineUpDetailCopyWithImpl<$Res>
    implements $LineUpDetailCopyWith<$Res> {
  _$LineUpDetailCopyWithImpl(this._self, this._then);

  final LineUpDetail _self;
  final $Res Function(LineUpDetail) _then;

/// Create a copy of LineUpDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? worshipLeader = freezed,Object? songsCount = null,Object? songs = null,Object? version = null,}) {
  return _then(LineUpDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: freezed == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String?,songsCount: null == songsCount ? _self.songsCount : songsCount // ignore: cast_nullable_to_non_nullable
as int,songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineUpSongEntry>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUpDetail].
extension LineUpDetailPatterns on LineUpDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpDetail value)  $default,){
final _that = this;
switch (_that) {
case _LineUpDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpDetail value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  List<LineUpSongEntry> songs,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpDetail() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.songs,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  List<LineUpSongEntry> songs,  int version)  $default,) {final _that = this;
switch (_that) {
case _LineUpDetail():
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.songs,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String date,  String? worshipLeader,  int songsCount,  List<LineUpSongEntry> songs,  int version)?  $default,) {final _that = this;
switch (_that) {
case _LineUpDetail() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.worshipLeader,_that.songsCount,_that.songs,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUpDetail extends LineUpDetail {
  const _LineUpDetail({required this.id, required this.title, required this.date, this.worshipLeader, this.songsCount = 0,  List<LineUpSongEntry> songs = const <LineUpSongEntry>[], this.version = 1}): _songs = songs,super._();
  factory _LineUpDetail.fromJson(Map<String, dynamic> json) => _$LineUpDetailFromJson(json);

@override final  int id;
@override final  String title;
@override final  String date;
@override final  String? worshipLeader;
@override@JsonKey() final  int songsCount;
 final  List<LineUpSongEntry> _songs;
@override@JsonKey() List<LineUpSongEntry> get songs {
  if (_songs is EqualUnmodifiableListView) return _songs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songs);
}

@override@JsonKey() final  int version;

/// Create a copy of LineUpDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpDetailCopyWith<_LineUpDetail> get copyWith => __$LineUpDetailCopyWithImpl<_LineUpDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.worshipLeader, worshipLeader) || other.worshipLeader == worshipLeader)&&(identical(other.songsCount, songsCount) || other.songsCount == songsCount)&&const DeepCollectionEquality().equals(other.songs, _songs)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,date,worshipLeader,songsCount,const DeepCollectionEquality().hash(_songs),version);
}

@override
String toString() {
    return 'LineUpDetail(id: $id, title: $title, date: $date, worshipLeader: $worshipLeader, songsCount: $songsCount, songs: $songs, version: $version)';
}


}

/// @nodoc
abstract mixin class _$LineUpDetailCopyWith<$Res> implements $LineUpDetailCopyWith<$Res> {
  factory _$LineUpDetailCopyWith(_LineUpDetail value, $Res Function(_LineUpDetail) _then) = __$LineUpDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String date, String? worshipLeader, int songsCount, List<LineUpSongEntry> songs, int version
});




}
/// @nodoc
class __$LineUpDetailCopyWithImpl<$Res>
    implements _$LineUpDetailCopyWith<$Res> {
  __$LineUpDetailCopyWithImpl(this._self, this._then);

  final _LineUpDetail _self;
  final $Res Function(_LineUpDetail) _then;

/// Create a copy of LineUpDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? worshipLeader = freezed,Object? songsCount = null,Object? songs = null,Object? version = null,}) {
  return _then(_LineUpDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: freezed == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String?,songsCount: null == songsCount ? _self.songsCount : songsCount // ignore: cast_nullable_to_non_nullable
as int,songs: null == songs ? _self._songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineUpSongEntry>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LineUpSongEntry {

 int get lineUpSongId; int get order; int get transposition; Song get song; List<LineUpSongNote> get notes; SectionArrangement? get sectionArrangement;
/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpSongEntryCopyWith<LineUpSongEntry> get copyWith => _$LineUpSongEntryCopyWithImpl<LineUpSongEntry>(this as LineUpSongEntry, _$identity);

  /// Serializes this LineUpSongEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUpSongEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpSongEntry&&(identical(other.lineUpSongId, _this.lineUpSongId) || other.lineUpSongId == _this.lineUpSongId)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.transposition, _this.transposition) || other.transposition == _this.transposition)&&(identical(other.song, _this.song) || other.song == _this.song)&&const DeepCollectionEquality().equals(other.notes, _this.notes)&&(identical(other.sectionArrangement, _this.sectionArrangement) || other.sectionArrangement == _this.sectionArrangement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUpSongEntry;
  return Object.hash(runtimeType,_this.lineUpSongId,_this.order,_this.transposition,_this.song,const DeepCollectionEquality().hash(_this.notes),_this.sectionArrangement);
}

@override
String toString() {
  final _this = this as LineUpSongEntry;
  return 'LineUpSongEntry(lineUpSongId: ${_this.lineUpSongId}, order: ${_this.order}, transposition: ${_this.transposition}, song: ${_this.song}, notes: ${_this.notes}, sectionArrangement: ${_this.sectionArrangement})';
}


}

/// @nodoc
abstract mixin class $LineUpSongEntryCopyWith<$Res>  {
  factory $LineUpSongEntryCopyWith(LineUpSongEntry value, $Res Function(LineUpSongEntry) _then) = _$LineUpSongEntryCopyWithImpl;
@useResult
$Res call({
 int lineUpSongId, int order, int transposition, Song song, List<LineUpSongNote> notes, SectionArrangement? sectionArrangement
});


$SongCopyWith<$Res> get song;$SectionArrangementCopyWith<$Res>? get sectionArrangement;

}
/// @nodoc
class _$LineUpSongEntryCopyWithImpl<$Res>
    implements $LineUpSongEntryCopyWith<$Res> {
  _$LineUpSongEntryCopyWithImpl(this._self, this._then);

  final LineUpSongEntry _self;
  final $Res Function(LineUpSongEntry) _then;

/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUpSongId = null,Object? order = null,Object? transposition = null,Object? song = null,Object? notes = null,Object? sectionArrangement = freezed,}) {
  return _then(LineUpSongEntry(
lineUpSongId: null == lineUpSongId ? _self.lineUpSongId : lineUpSongId // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,transposition: null == transposition ? _self.transposition : transposition // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<LineUpSongNote>,sectionArrangement: freezed == sectionArrangement ? _self.sectionArrangement : sectionArrangement // ignore: cast_nullable_to_non_nullable
as SectionArrangement?,
  ));
}
/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementCopyWith<$Res>? get sectionArrangement {
    if (_self.sectionArrangement == null) {
    return null;
  }

  return $SectionArrangementCopyWith<$Res>(_self.sectionArrangement!, (value) {
    return _then(_self.copyWith(sectionArrangement: value));
  });
}
}


/// Adds pattern-matching-related methods to [LineUpSongEntry].
extension LineUpSongEntryPatterns on LineUpSongEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpSongEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpSongEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpSongEntry value)  $default,){
final _that = this;
switch (_that) {
case _LineUpSongEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpSongEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpSongEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lineUpSongId,  int order,  int transposition,  Song song,  List<LineUpSongNote> notes,  SectionArrangement? sectionArrangement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpSongEntry() when $default != null:
return $default(_that.lineUpSongId,_that.order,_that.transposition,_that.song,_that.notes,_that.sectionArrangement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lineUpSongId,  int order,  int transposition,  Song song,  List<LineUpSongNote> notes,  SectionArrangement? sectionArrangement)  $default,) {final _that = this;
switch (_that) {
case _LineUpSongEntry():
return $default(_that.lineUpSongId,_that.order,_that.transposition,_that.song,_that.notes,_that.sectionArrangement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lineUpSongId,  int order,  int transposition,  Song song,  List<LineUpSongNote> notes,  SectionArrangement? sectionArrangement)?  $default,) {final _that = this;
switch (_that) {
case _LineUpSongEntry() when $default != null:
return $default(_that.lineUpSongId,_that.order,_that.transposition,_that.song,_that.notes,_that.sectionArrangement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUpSongEntry implements LineUpSongEntry {
  const _LineUpSongEntry({required this.lineUpSongId, required this.order, this.transposition = 0, required this.song,  List<LineUpSongNote> notes = const <LineUpSongNote>[], this.sectionArrangement}): _notes = notes;
  factory _LineUpSongEntry.fromJson(Map<String, dynamic> json) => _$LineUpSongEntryFromJson(json);

@override final  int lineUpSongId;
@override final  int order;
@override@JsonKey() final  int transposition;
@override final  Song song;
 final  List<LineUpSongNote> _notes;
@override@JsonKey() List<LineUpSongNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  SectionArrangement? sectionArrangement;

/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpSongEntryCopyWith<_LineUpSongEntry> get copyWith => __$LineUpSongEntryCopyWithImpl<_LineUpSongEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpSongEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpSongEntry&&(identical(other.lineUpSongId, lineUpSongId) || other.lineUpSongId == lineUpSongId)&&(identical(other.order, order) || other.order == order)&&(identical(other.transposition, transposition) || other.transposition == transposition)&&(identical(other.song, song) || other.song == song)&&const DeepCollectionEquality().equals(other.notes, _notes)&&(identical(other.sectionArrangement, sectionArrangement) || other.sectionArrangement == sectionArrangement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lineUpSongId,order,transposition,song,const DeepCollectionEquality().hash(_notes),sectionArrangement);
}

@override
String toString() {
    return 'LineUpSongEntry(lineUpSongId: $lineUpSongId, order: $order, transposition: $transposition, song: $song, notes: $notes, sectionArrangement: $sectionArrangement)';
}


}

/// @nodoc
abstract mixin class _$LineUpSongEntryCopyWith<$Res> implements $LineUpSongEntryCopyWith<$Res> {
  factory _$LineUpSongEntryCopyWith(_LineUpSongEntry value, $Res Function(_LineUpSongEntry) _then) = __$LineUpSongEntryCopyWithImpl;
@override @useResult
$Res call({
 int lineUpSongId, int order, int transposition, Song song, List<LineUpSongNote> notes, SectionArrangement? sectionArrangement
});


@override $SongCopyWith<$Res> get song;@override $SectionArrangementCopyWith<$Res>? get sectionArrangement;

}
/// @nodoc
class __$LineUpSongEntryCopyWithImpl<$Res>
    implements _$LineUpSongEntryCopyWith<$Res> {
  __$LineUpSongEntryCopyWithImpl(this._self, this._then);

  final _LineUpSongEntry _self;
  final $Res Function(_LineUpSongEntry) _then;

/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineUpSongId = null,Object? order = null,Object? transposition = null,Object? song = null,Object? notes = null,Object? sectionArrangement = freezed,}) {
  return _then(_LineUpSongEntry(
lineUpSongId: null == lineUpSongId ? _self.lineUpSongId : lineUpSongId // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,transposition: null == transposition ? _self.transposition : transposition // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<LineUpSongNote>,sectionArrangement: freezed == sectionArrangement ? _self.sectionArrangement : sectionArrangement // ignore: cast_nullable_to_non_nullable
as SectionArrangement?,
  ));
}

/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}/// Create a copy of LineUpSongEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementCopyWith<$Res>? get sectionArrangement {
    if (_self.sectionArrangement == null) {
    return null;
  }

  return $SectionArrangementCopyWith<$Res>(_self.sectionArrangement!, (value) {
    return _then(_self.copyWith(sectionArrangement: value));
  });
}
}


/// @nodoc
mixin _$LineUpSongNote {

 String get id; int get line; String get text;
/// Create a copy of LineUpSongNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpSongNoteCopyWith<LineUpSongNote> get copyWith => _$LineUpSongNoteCopyWithImpl<LineUpSongNote>(this as LineUpSongNote, _$identity);

  /// Serializes this LineUpSongNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUpSongNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpSongNote&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.line, _this.line) || other.line == _this.line)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUpSongNote;
  return Object.hash(runtimeType,_this.id,_this.line,_this.text);
}

@override
String toString() {
  final _this = this as LineUpSongNote;
  return 'LineUpSongNote(id: ${_this.id}, line: ${_this.line}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $LineUpSongNoteCopyWith<$Res>  {
  factory $LineUpSongNoteCopyWith(LineUpSongNote value, $Res Function(LineUpSongNote) _then) = _$LineUpSongNoteCopyWithImpl;
@useResult
$Res call({
 String id, int line, String text
});




}
/// @nodoc
class _$LineUpSongNoteCopyWithImpl<$Res>
    implements $LineUpSongNoteCopyWith<$Res> {
  _$LineUpSongNoteCopyWithImpl(this._self, this._then);

  final LineUpSongNote _self;
  final $Res Function(LineUpSongNote) _then;

/// Create a copy of LineUpSongNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? line = null,Object? text = null,}) {
  return _then(LineUpSongNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUpSongNote].
extension LineUpSongNotePatterns on LineUpSongNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpSongNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpSongNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpSongNote value)  $default,){
final _that = this;
switch (_that) {
case _LineUpSongNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpSongNote value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpSongNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int line,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpSongNote() when $default != null:
return $default(_that.id,_that.line,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int line,  String text)  $default,) {final _that = this;
switch (_that) {
case _LineUpSongNote():
return $default(_that.id,_that.line,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int line,  String text)?  $default,) {final _that = this;
switch (_that) {
case _LineUpSongNote() when $default != null:
return $default(_that.id,_that.line,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUpSongNote implements LineUpSongNote {
  const _LineUpSongNote({required this.id, required this.line, required this.text});
  factory _LineUpSongNote.fromJson(Map<String, dynamic> json) => _$LineUpSongNoteFromJson(json);

@override final  String id;
@override final  int line;
@override final  String text;

/// Create a copy of LineUpSongNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpSongNoteCopyWith<_LineUpSongNote> get copyWith => __$LineUpSongNoteCopyWithImpl<_LineUpSongNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpSongNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpSongNote&&(identical(other.id, id) || other.id == id)&&(identical(other.line, line) || other.line == line)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,line,text);
}

@override
String toString() {
    return 'LineUpSongNote(id: $id, line: $line, text: $text)';
}


}

/// @nodoc
abstract mixin class _$LineUpSongNoteCopyWith<$Res> implements $LineUpSongNoteCopyWith<$Res> {
  factory _$LineUpSongNoteCopyWith(_LineUpSongNote value, $Res Function(_LineUpSongNote) _then) = __$LineUpSongNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, int line, String text
});




}
/// @nodoc
class __$LineUpSongNoteCopyWithImpl<$Res>
    implements _$LineUpSongNoteCopyWith<$Res> {
  __$LineUpSongNoteCopyWithImpl(this._self, this._then);

  final _LineUpSongNote _self;
  final $Res Function(_LineUpSongNote) _then;

/// Create a copy of LineUpSongNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? line = null,Object? text = null,}) {
  return _then(_LineUpSongNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SectionArrangement {

 SectionArrangementField get chords; SectionArrangementField get lyrics;
/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionArrangementCopyWith<SectionArrangement> get copyWith => _$SectionArrangementCopyWithImpl<SectionArrangement>(this as SectionArrangement, _$identity);

  /// Serializes this SectionArrangement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SectionArrangement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionArrangement&&(identical(other.chords, _this.chords) || other.chords == _this.chords)&&(identical(other.lyrics, _this.lyrics) || other.lyrics == _this.lyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SectionArrangement;
  return Object.hash(runtimeType,_this.chords,_this.lyrics);
}

@override
String toString() {
  final _this = this as SectionArrangement;
  return 'SectionArrangement(chords: ${_this.chords}, lyrics: ${_this.lyrics})';
}


}

/// @nodoc
abstract mixin class $SectionArrangementCopyWith<$Res>  {
  factory $SectionArrangementCopyWith(SectionArrangement value, $Res Function(SectionArrangement) _then) = _$SectionArrangementCopyWithImpl;
@useResult
$Res call({
 SectionArrangementField chords, SectionArrangementField lyrics
});


$SectionArrangementFieldCopyWith<$Res> get chords;$SectionArrangementFieldCopyWith<$Res> get lyrics;

}
/// @nodoc
class _$SectionArrangementCopyWithImpl<$Res>
    implements $SectionArrangementCopyWith<$Res> {
  _$SectionArrangementCopyWithImpl(this._self, this._then);

  final SectionArrangement _self;
  final $Res Function(SectionArrangement) _then;

/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chords = null,Object? lyrics = null,}) {
  return _then(SectionArrangement(
chords: null == chords ? _self.chords : chords // ignore: cast_nullable_to_non_nullable
as SectionArrangementField,lyrics: null == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as SectionArrangementField,
  ));
}
/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementFieldCopyWith<$Res> get chords {
  
  return $SectionArrangementFieldCopyWith<$Res>(_self.chords, (value) {
    return _then(_self.copyWith(chords: value));
  });
}/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementFieldCopyWith<$Res> get lyrics {
  
  return $SectionArrangementFieldCopyWith<$Res>(_self.lyrics, (value) {
    return _then(_self.copyWith(lyrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [SectionArrangement].
extension SectionArrangementPatterns on SectionArrangement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionArrangement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionArrangement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionArrangement value)  $default,){
final _that = this;
switch (_that) {
case _SectionArrangement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionArrangement value)?  $default,){
final _that = this;
switch (_that) {
case _SectionArrangement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SectionArrangementField chords,  SectionArrangementField lyrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionArrangement() when $default != null:
return $default(_that.chords,_that.lyrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SectionArrangementField chords,  SectionArrangementField lyrics)  $default,) {final _that = this;
switch (_that) {
case _SectionArrangement():
return $default(_that.chords,_that.lyrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SectionArrangementField chords,  SectionArrangementField lyrics)?  $default,) {final _that = this;
switch (_that) {
case _SectionArrangement() when $default != null:
return $default(_that.chords,_that.lyrics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SectionArrangement extends SectionArrangement {
  const _SectionArrangement({this.chords = const SectionArrangementField(), this.lyrics = const SectionArrangementField()}): super._();
  factory _SectionArrangement.fromJson(Map<String, dynamic> json) => _$SectionArrangementFromJson(json);

@override@JsonKey() final  SectionArrangementField chords;
@override@JsonKey() final  SectionArrangementField lyrics;

/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionArrangementCopyWith<_SectionArrangement> get copyWith => __$SectionArrangementCopyWithImpl<_SectionArrangement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SectionArrangementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionArrangement&&(identical(other.chords, chords) || other.chords == chords)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,chords,lyrics);
}

@override
String toString() {
    return 'SectionArrangement(chords: $chords, lyrics: $lyrics)';
}


}

/// @nodoc
abstract mixin class _$SectionArrangementCopyWith<$Res> implements $SectionArrangementCopyWith<$Res> {
  factory _$SectionArrangementCopyWith(_SectionArrangement value, $Res Function(_SectionArrangement) _then) = __$SectionArrangementCopyWithImpl;
@override @useResult
$Res call({
 SectionArrangementField chords, SectionArrangementField lyrics
});


@override $SectionArrangementFieldCopyWith<$Res> get chords;@override $SectionArrangementFieldCopyWith<$Res> get lyrics;

}
/// @nodoc
class __$SectionArrangementCopyWithImpl<$Res>
    implements _$SectionArrangementCopyWith<$Res> {
  __$SectionArrangementCopyWithImpl(this._self, this._then);

  final _SectionArrangement _self;
  final $Res Function(_SectionArrangement) _then;

/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chords = null,Object? lyrics = null,}) {
  return _then(_SectionArrangement(
chords: null == chords ? _self.chords : chords // ignore: cast_nullable_to_non_nullable
as SectionArrangementField,lyrics: null == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as SectionArrangementField,
  ));
}

/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementFieldCopyWith<$Res> get chords {
  
  return $SectionArrangementFieldCopyWith<$Res>(_self.chords, (value) {
    return _then(_self.copyWith(chords: value));
  });
}/// Create a copy of SectionArrangement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionArrangementFieldCopyWith<$Res> get lyrics {
  
  return $SectionArrangementFieldCopyWith<$Res>(_self.lyrics, (value) {
    return _then(_self.copyWith(lyrics: value));
  });
}
}


/// @nodoc
mixin _$SectionArrangementField {

 List<int> get order; List<int> get removed;
/// Create a copy of SectionArrangementField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionArrangementFieldCopyWith<SectionArrangementField> get copyWith => _$SectionArrangementFieldCopyWithImpl<SectionArrangementField>(this as SectionArrangementField, _$identity);

  /// Serializes this SectionArrangementField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SectionArrangementField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionArrangementField&&const DeepCollectionEquality().equals(other.order, _this.order)&&const DeepCollectionEquality().equals(other.removed, _this.removed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SectionArrangementField;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.order),const DeepCollectionEquality().hash(_this.removed));
}

@override
String toString() {
  final _this = this as SectionArrangementField;
  return 'SectionArrangementField(order: ${_this.order}, removed: ${_this.removed})';
}


}

/// @nodoc
abstract mixin class $SectionArrangementFieldCopyWith<$Res>  {
  factory $SectionArrangementFieldCopyWith(SectionArrangementField value, $Res Function(SectionArrangementField) _then) = _$SectionArrangementFieldCopyWithImpl;
@useResult
$Res call({
 List<int> order, List<int> removed
});




}
/// @nodoc
class _$SectionArrangementFieldCopyWithImpl<$Res>
    implements $SectionArrangementFieldCopyWith<$Res> {
  _$SectionArrangementFieldCopyWithImpl(this._self, this._then);

  final SectionArrangementField _self;
  final $Res Function(SectionArrangementField) _then;

/// Create a copy of SectionArrangementField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? removed = null,}) {
  return _then(SectionArrangementField(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as List<int>,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SectionArrangementField].
extension SectionArrangementFieldPatterns on SectionArrangementField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionArrangementField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionArrangementField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionArrangementField value)  $default,){
final _that = this;
switch (_that) {
case _SectionArrangementField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionArrangementField value)?  $default,){
final _that = this;
switch (_that) {
case _SectionArrangementField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> order,  List<int> removed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionArrangementField() when $default != null:
return $default(_that.order,_that.removed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> order,  List<int> removed)  $default,) {final _that = this;
switch (_that) {
case _SectionArrangementField():
return $default(_that.order,_that.removed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> order,  List<int> removed)?  $default,) {final _that = this;
switch (_that) {
case _SectionArrangementField() when $default != null:
return $default(_that.order,_that.removed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SectionArrangementField extends SectionArrangementField {
  const _SectionArrangementField({ List<int> order = const <int>[],  List<int> removed = const <int>[]}): _order = order,_removed = removed,super._();
  factory _SectionArrangementField.fromJson(Map<String, dynamic> json) => _$SectionArrangementFieldFromJson(json);

 final  List<int> _order;
@override@JsonKey() List<int> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

 final  List<int> _removed;
@override@JsonKey() List<int> get removed {
  if (_removed is EqualUnmodifiableListView) return _removed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_removed);
}


/// Create a copy of SectionArrangementField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionArrangementFieldCopyWith<_SectionArrangementField> get copyWith => __$SectionArrangementFieldCopyWithImpl<_SectionArrangementField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SectionArrangementFieldToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionArrangementField&&const DeepCollectionEquality().equals(other.order, _order)&&const DeepCollectionEquality().equals(other.removed, _removed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_order),const DeepCollectionEquality().hash(_removed));
}

@override
String toString() {
    return 'SectionArrangementField(order: $order, removed: $removed)';
}


}

/// @nodoc
abstract mixin class _$SectionArrangementFieldCopyWith<$Res> implements $SectionArrangementFieldCopyWith<$Res> {
  factory _$SectionArrangementFieldCopyWith(_SectionArrangementField value, $Res Function(_SectionArrangementField) _then) = __$SectionArrangementFieldCopyWithImpl;
@override @useResult
$Res call({
 List<int> order, List<int> removed
});




}
/// @nodoc
class __$SectionArrangementFieldCopyWithImpl<$Res>
    implements _$SectionArrangementFieldCopyWith<$Res> {
  __$SectionArrangementFieldCopyWithImpl(this._self, this._then);

  final _SectionArrangementField _self;
  final $Res Function(_SectionArrangementField) _then;

/// Create a copy of SectionArrangementField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? removed = null,}) {
  return _then(_SectionArrangementField(
order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<int>,removed: null == removed ? _self._removed : removed // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$LineUpShareLink {

 bool get enabled; String? get token; String? get sharePath;
/// Create a copy of LineUpShareLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpShareLinkCopyWith<LineUpShareLink> get copyWith => _$LineUpShareLinkCopyWithImpl<LineUpShareLink>(this as LineUpShareLink, _$identity);

  /// Serializes this LineUpShareLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LineUpShareLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpShareLink&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.sharePath, _this.sharePath) || other.sharePath == _this.sharePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LineUpShareLink;
  return Object.hash(runtimeType,_this.enabled,_this.token,_this.sharePath);
}

@override
String toString() {
  final _this = this as LineUpShareLink;
  return 'LineUpShareLink(enabled: ${_this.enabled}, token: ${_this.token}, sharePath: ${_this.sharePath})';
}


}

/// @nodoc
abstract mixin class $LineUpShareLinkCopyWith<$Res>  {
  factory $LineUpShareLinkCopyWith(LineUpShareLink value, $Res Function(LineUpShareLink) _then) = _$LineUpShareLinkCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? token, String? sharePath
});




}
/// @nodoc
class _$LineUpShareLinkCopyWithImpl<$Res>
    implements $LineUpShareLinkCopyWith<$Res> {
  _$LineUpShareLinkCopyWithImpl(this._self, this._then);

  final LineUpShareLink _self;
  final $Res Function(LineUpShareLink) _then;

/// Create a copy of LineUpShareLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? token = freezed,Object? sharePath = freezed,}) {
  return _then(LineUpShareLink(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,sharePath: freezed == sharePath ? _self.sharePath : sharePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUpShareLink].
extension LineUpShareLinkPatterns on LineUpShareLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpShareLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpShareLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpShareLink value)  $default,){
final _that = this;
switch (_that) {
case _LineUpShareLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpShareLink value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpShareLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? token,  String? sharePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpShareLink() when $default != null:
return $default(_that.enabled,_that.token,_that.sharePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? token,  String? sharePath)  $default,) {final _that = this;
switch (_that) {
case _LineUpShareLink():
return $default(_that.enabled,_that.token,_that.sharePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? token,  String? sharePath)?  $default,) {final _that = this;
switch (_that) {
case _LineUpShareLink() when $default != null:
return $default(_that.enabled,_that.token,_that.sharePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LineUpShareLink implements LineUpShareLink {
  const _LineUpShareLink({required this.enabled, this.token, this.sharePath});
  factory _LineUpShareLink.fromJson(Map<String, dynamic> json) => _$LineUpShareLinkFromJson(json);

@override final  bool enabled;
@override final  String? token;
@override final  String? sharePath;

/// Create a copy of LineUpShareLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpShareLinkCopyWith<_LineUpShareLink> get copyWith => __$LineUpShareLinkCopyWithImpl<_LineUpShareLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineUpShareLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpShareLink&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.token, token) || other.token == token)&&(identical(other.sharePath, sharePath) || other.sharePath == sharePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,token,sharePath);
}

@override
String toString() {
    return 'LineUpShareLink(enabled: $enabled, token: $token, sharePath: $sharePath)';
}


}

/// @nodoc
abstract mixin class _$LineUpShareLinkCopyWith<$Res> implements $LineUpShareLinkCopyWith<$Res> {
  factory _$LineUpShareLinkCopyWith(_LineUpShareLink value, $Res Function(_LineUpShareLink) _then) = __$LineUpShareLinkCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? token, String? sharePath
});




}
/// @nodoc
class __$LineUpShareLinkCopyWithImpl<$Res>
    implements _$LineUpShareLinkCopyWith<$Res> {
  __$LineUpShareLinkCopyWithImpl(this._self, this._then);

  final _LineUpShareLink _self;
  final $Res Function(_LineUpShareLink) _then;

/// Create a copy of LineUpShareLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? token = freezed,Object? sharePath = freezed,}) {
  return _then(_LineUpShareLink(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,sharePath: freezed == sharePath ? _self.sharePath : sharePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
