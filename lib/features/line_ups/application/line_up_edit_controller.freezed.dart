// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_up_edit_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineUpEditState implements DiagnosticableTreeMixin {

 EditableLineUp get saved; String get title;/// `YYYY-MM-DD`.
 String get date; String get worshipLeader; List<LineUpDraftSong> get songs; bool get saving;
/// Create a copy of LineUpEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineUpEditStateCopyWith<LineUpEditState> get copyWith => _$LineUpEditStateCopyWithImpl<LineUpEditState>(this as LineUpEditState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as LineUpEditState;
  properties
    ..add(DiagnosticsProperty('type', 'LineUpEditState'))
    ..add(DiagnosticsProperty('saved', _this.saved))..add(DiagnosticsProperty('title', _this.title))..add(DiagnosticsProperty('date', _this.date))..add(DiagnosticsProperty('worshipLeader', _this.worshipLeader))..add(DiagnosticsProperty('songs', _this.songs))..add(DiagnosticsProperty('saving', _this.saving));
}

@override
bool operator ==(Object other) {
  final _this = this as LineUpEditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineUpEditState&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.worshipLeader, _this.worshipLeader) || other.worshipLeader == _this.worshipLeader)&&const DeepCollectionEquality().equals(other.songs, _this.songs)&&(identical(other.saving, _this.saving) || other.saving == _this.saving));
}


@override
int get hashCode {
  final _this = this as LineUpEditState;
  return Object.hash(runtimeType,_this.saved,_this.title,_this.date,_this.worshipLeader,const DeepCollectionEquality().hash(_this.songs),_this.saving);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as LineUpEditState;
  return 'LineUpEditState(saved: ${_this.saved}, title: ${_this.title}, date: ${_this.date}, worshipLeader: ${_this.worshipLeader}, songs: ${_this.songs}, saving: ${_this.saving})';
}


}

/// @nodoc
abstract mixin class $LineUpEditStateCopyWith<$Res>  {
  factory $LineUpEditStateCopyWith(LineUpEditState value, $Res Function(LineUpEditState) _then) = _$LineUpEditStateCopyWithImpl;
@useResult
$Res call({
 EditableLineUp saved, String title, String date, String worshipLeader, List<LineUpDraftSong> songs, bool saving
});




}
/// @nodoc
class _$LineUpEditStateCopyWithImpl<$Res>
    implements $LineUpEditStateCopyWith<$Res> {
  _$LineUpEditStateCopyWithImpl(this._self, this._then);

  final LineUpEditState _self;
  final $Res Function(LineUpEditState) _then;

/// Create a copy of LineUpEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? saved = null,Object? title = null,Object? date = null,Object? worshipLeader = null,Object? songs = null,Object? saving = null,}) {
  return _then(LineUpEditState(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as EditableLineUp,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: null == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String,songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineUpDraftSong>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LineUpEditState].
extension LineUpEditStatePatterns on LineUpEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineUpEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineUpEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineUpEditState value)  $default,){
final _that = this;
switch (_that) {
case _LineUpEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineUpEditState value)?  $default,){
final _that = this;
switch (_that) {
case _LineUpEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EditableLineUp saved,  String title,  String date,  String worshipLeader,  List<LineUpDraftSong> songs,  bool saving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineUpEditState() when $default != null:
return $default(_that.saved,_that.title,_that.date,_that.worshipLeader,_that.songs,_that.saving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EditableLineUp saved,  String title,  String date,  String worshipLeader,  List<LineUpDraftSong> songs,  bool saving)  $default,) {final _that = this;
switch (_that) {
case _LineUpEditState():
return $default(_that.saved,_that.title,_that.date,_that.worshipLeader,_that.songs,_that.saving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EditableLineUp saved,  String title,  String date,  String worshipLeader,  List<LineUpDraftSong> songs,  bool saving)?  $default,) {final _that = this;
switch (_that) {
case _LineUpEditState() when $default != null:
return $default(_that.saved,_that.title,_that.date,_that.worshipLeader,_that.songs,_that.saving);case _:
  return null;

}
}

}

/// @nodoc


class _LineUpEditState extends LineUpEditState with DiagnosticableTreeMixin {
  const _LineUpEditState({required this.saved, required this.title, required this.date, required this.worshipLeader, required  List<LineUpDraftSong> songs, this.saving = false}): _songs = songs,super._();
  

@override final  EditableLineUp saved;
@override final  String title;
/// `YYYY-MM-DD`.
@override final  String date;
@override final  String worshipLeader;
 final  List<LineUpDraftSong> _songs;
@override List<LineUpDraftSong> get songs {
  if (_songs is EqualUnmodifiableListView) return _songs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songs);
}

@override@JsonKey() final  bool saving;

/// Create a copy of LineUpEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineUpEditStateCopyWith<_LineUpEditState> get copyWith => __$LineUpEditStateCopyWithImpl<_LineUpEditState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'LineUpEditState'))
    ..add(DiagnosticsProperty('saved', saved))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('date', date))..add(DiagnosticsProperty('worshipLeader', worshipLeader))..add(DiagnosticsProperty('songs', songs))..add(DiagnosticsProperty('saving', saving));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineUpEditState&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.worshipLeader, worshipLeader) || other.worshipLeader == worshipLeader)&&const DeepCollectionEquality().equals(other.songs, _songs)&&(identical(other.saving, saving) || other.saving == saving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,saved,title,date,worshipLeader,const DeepCollectionEquality().hash(_songs),saving);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'LineUpEditState(saved: $saved, title: $title, date: $date, worshipLeader: $worshipLeader, songs: $songs, saving: $saving)';
}


}

/// @nodoc
abstract mixin class _$LineUpEditStateCopyWith<$Res> implements $LineUpEditStateCopyWith<$Res> {
  factory _$LineUpEditStateCopyWith(_LineUpEditState value, $Res Function(_LineUpEditState) _then) = __$LineUpEditStateCopyWithImpl;
@override @useResult
$Res call({
 EditableLineUp saved, String title, String date, String worshipLeader, List<LineUpDraftSong> songs, bool saving
});




}
/// @nodoc
class __$LineUpEditStateCopyWithImpl<$Res>
    implements _$LineUpEditStateCopyWith<$Res> {
  __$LineUpEditStateCopyWithImpl(this._self, this._then);

  final _LineUpEditState _self;
  final $Res Function(_LineUpEditState) _then;

/// Create a copy of LineUpEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? saved = null,Object? title = null,Object? date = null,Object? worshipLeader = null,Object? songs = null,Object? saving = null,}) {
  return _then(_LineUpEditState(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as EditableLineUp,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,worshipLeader: null == worshipLeader ? _self.worshipLeader : worshipLeader // ignore: cast_nullable_to_non_nullable
as String,songs: null == songs ? _self._songs : songs // ignore: cast_nullable_to_non_nullable
as List<LineUpDraftSong>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
