// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_edit_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SongEditState {

 SongFields get saved; SongFields get fields;/// The song as the draft started from it (kept up to date with changes
/// from elsewhere that the draft took) — [saved] is its fields.
 Song get base;/// The key as it was when the screen opened, for the key-change notice.
 String? get keyChangedFrom; bool get saving;/// Fields changed here and on another device meanwhile: theirs.
 Map<SongField, Object?> get conflicts;/// Bumped when fields follow a change from elsewhere, so the screen
/// refreshes its text fields.
 int get remoteRevision;/// Who changed the song elsewhere, for the banner.
 String? get changedBy;
/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongEditStateCopyWith<SongEditState> get copyWith => _$SongEditStateCopyWithImpl<SongEditState>(this as SongEditState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SongEditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongEditState&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.fields, _this.fields) || other.fields == _this.fields)&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.keyChangedFrom, _this.keyChangedFrom) || other.keyChangedFrom == _this.keyChangedFrom)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&const DeepCollectionEquality().equals(other.conflicts, _this.conflicts)&&(identical(other.remoteRevision, _this.remoteRevision) || other.remoteRevision == _this.remoteRevision)&&(identical(other.changedBy, _this.changedBy) || other.changedBy == _this.changedBy));
}


@override
int get hashCode {
  final _this = this as SongEditState;
  return Object.hash(runtimeType,_this.saved,_this.fields,_this.base,_this.keyChangedFrom,_this.saving,const DeepCollectionEquality().hash(_this.conflicts),_this.remoteRevision,_this.changedBy);
}

@override
String toString() {
  final _this = this as SongEditState;
  return 'SongEditState(saved: ${_this.saved}, fields: ${_this.fields}, base: ${_this.base}, keyChangedFrom: ${_this.keyChangedFrom}, saving: ${_this.saving}, conflicts: ${_this.conflicts}, remoteRevision: ${_this.remoteRevision}, changedBy: ${_this.changedBy})';
}


}

/// @nodoc
abstract mixin class $SongEditStateCopyWith<$Res>  {
  factory $SongEditStateCopyWith(SongEditState value, $Res Function(SongEditState) _then) = _$SongEditStateCopyWithImpl;
@useResult
$Res call({
 SongFields saved, SongFields fields, Song base, String? keyChangedFrom, bool saving, Map<SongField, Object?> conflicts, int remoteRevision, String? changedBy
});


$SongCopyWith<$Res> get base;

}
/// @nodoc
class _$SongEditStateCopyWithImpl<$Res>
    implements $SongEditStateCopyWith<$Res> {
  _$SongEditStateCopyWithImpl(this._self, this._then);

  final SongEditState _self;
  final $Res Function(SongEditState) _then;

/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? saved = null,Object? fields = null,Object? base = null,Object? keyChangedFrom = freezed,Object? saving = null,Object? conflicts = null,Object? remoteRevision = null,Object? changedBy = freezed,}) {
  return _then(SongEditState(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as SongFields,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as SongFields,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Song,keyChangedFrom: freezed == keyChangedFrom ? _self.keyChangedFrom : keyChangedFrom // ignore: cast_nullable_to_non_nullable
as String?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as Map<SongField, Object?>,remoteRevision: null == remoteRevision ? _self.remoteRevision : remoteRevision // ignore: cast_nullable_to_non_nullable
as int,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get base {
  
  return $SongCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}
}


/// Adds pattern-matching-related methods to [SongEditState].
extension SongEditStatePatterns on SongEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongEditState value)  $default,){
final _that = this;
switch (_that) {
case _SongEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongEditState value)?  $default,){
final _that = this;
switch (_that) {
case _SongEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SongFields saved,  SongFields fields,  Song base,  String? keyChangedFrom,  bool saving,  Map<SongField, Object?> conflicts,  int remoteRevision,  String? changedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongEditState() when $default != null:
return $default(_that.saved,_that.fields,_that.base,_that.keyChangedFrom,_that.saving,_that.conflicts,_that.remoteRevision,_that.changedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SongFields saved,  SongFields fields,  Song base,  String? keyChangedFrom,  bool saving,  Map<SongField, Object?> conflicts,  int remoteRevision,  String? changedBy)  $default,) {final _that = this;
switch (_that) {
case _SongEditState():
return $default(_that.saved,_that.fields,_that.base,_that.keyChangedFrom,_that.saving,_that.conflicts,_that.remoteRevision,_that.changedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SongFields saved,  SongFields fields,  Song base,  String? keyChangedFrom,  bool saving,  Map<SongField, Object?> conflicts,  int remoteRevision,  String? changedBy)?  $default,) {final _that = this;
switch (_that) {
case _SongEditState() when $default != null:
return $default(_that.saved,_that.fields,_that.base,_that.keyChangedFrom,_that.saving,_that.conflicts,_that.remoteRevision,_that.changedBy);case _:
  return null;

}
}

}

/// @nodoc


class _SongEditState extends SongEditState {
  const _SongEditState({required this.saved, required this.fields, required this.base, this.keyChangedFrom, this.saving = false,  Map<SongField, Object?> conflicts = const <SongField, Object?>{}, this.remoteRevision = 0, this.changedBy}): _conflicts = conflicts,super._();
  

@override final  SongFields saved;
@override final  SongFields fields;
/// The song as the draft started from it (kept up to date with changes
/// from elsewhere that the draft took) — [saved] is its fields.
@override final  Song base;
/// The key as it was when the screen opened, for the key-change notice.
@override final  String? keyChangedFrom;
@override@JsonKey() final  bool saving;
/// Fields changed here and on another device meanwhile: theirs.
 final  Map<SongField, Object?> _conflicts;
/// Fields changed here and on another device meanwhile: theirs.
@override@JsonKey() Map<SongField, Object?> get conflicts {
  if (_conflicts is EqualUnmodifiableMapView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_conflicts);
}

/// Bumped when fields follow a change from elsewhere, so the screen
/// refreshes its text fields.
@override@JsonKey() final  int remoteRevision;
/// Who changed the song elsewhere, for the banner.
@override final  String? changedBy;

/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongEditStateCopyWith<_SongEditState> get copyWith => __$SongEditStateCopyWithImpl<_SongEditState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongEditState&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.base, base) || other.base == base)&&(identical(other.keyChangedFrom, keyChangedFrom) || other.keyChangedFrom == keyChangedFrom)&&(identical(other.saving, saving) || other.saving == saving)&&const DeepCollectionEquality().equals(other.conflicts, _conflicts)&&(identical(other.remoteRevision, remoteRevision) || other.remoteRevision == remoteRevision)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,saved,fields,base,keyChangedFrom,saving,const DeepCollectionEquality().hash(_conflicts),remoteRevision,changedBy);
}

@override
String toString() {
    return 'SongEditState(saved: $saved, fields: $fields, base: $base, keyChangedFrom: $keyChangedFrom, saving: $saving, conflicts: $conflicts, remoteRevision: $remoteRevision, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class _$SongEditStateCopyWith<$Res> implements $SongEditStateCopyWith<$Res> {
  factory _$SongEditStateCopyWith(_SongEditState value, $Res Function(_SongEditState) _then) = __$SongEditStateCopyWithImpl;
@override @useResult
$Res call({
 SongFields saved, SongFields fields, Song base, String? keyChangedFrom, bool saving, Map<SongField, Object?> conflicts, int remoteRevision, String? changedBy
});


@override $SongCopyWith<$Res> get base;

}
/// @nodoc
class __$SongEditStateCopyWithImpl<$Res>
    implements _$SongEditStateCopyWith<$Res> {
  __$SongEditStateCopyWithImpl(this._self, this._then);

  final _SongEditState _self;
  final $Res Function(_SongEditState) _then;

/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? saved = null,Object? fields = null,Object? base = null,Object? keyChangedFrom = freezed,Object? saving = null,Object? conflicts = null,Object? remoteRevision = null,Object? changedBy = freezed,}) {
  return _then(_SongEditState(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as SongFields,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as SongFields,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Song,keyChangedFrom: freezed == keyChangedFrom ? _self.keyChangedFrom : keyChangedFrom // ignore: cast_nullable_to_non_nullable
as String?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as Map<SongField, Object?>,remoteRevision: null == remoteRevision ? _self.remoteRevision : remoteRevision // ignore: cast_nullable_to_non_nullable
as int,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SongEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get base {
  
  return $SongCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}
}

// dart format on
