// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_sync_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceSyncState {

 SyncStatus get status; DateTime? get lastSyncedAt; String? get errorMessage;
/// Create a copy of WorkspaceSyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceSyncStateCopyWith<WorkspaceSyncState> get copyWith => _$WorkspaceSyncStateCopyWithImpl<WorkspaceSyncState>(this as WorkspaceSyncState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkspaceSyncState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSyncState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastSyncedAt, _this.lastSyncedAt) || other.lastSyncedAt == _this.lastSyncedAt)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as WorkspaceSyncState;
  return Object.hash(runtimeType,_this.status,_this.lastSyncedAt,_this.errorMessage);
}

@override
String toString() {
  final _this = this as WorkspaceSyncState;
  return 'WorkspaceSyncState(status: ${_this.status}, lastSyncedAt: ${_this.lastSyncedAt}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $WorkspaceSyncStateCopyWith<$Res>  {
  factory $WorkspaceSyncStateCopyWith(WorkspaceSyncState value, $Res Function(WorkspaceSyncState) _then) = _$WorkspaceSyncStateCopyWithImpl;
@useResult
$Res call({
 SyncStatus status, DateTime? lastSyncedAt, String? errorMessage
});




}
/// @nodoc
class _$WorkspaceSyncStateCopyWithImpl<$Res>
    implements $WorkspaceSyncStateCopyWith<$Res> {
  _$WorkspaceSyncStateCopyWithImpl(this._self, this._then);

  final WorkspaceSyncState _self;
  final $Res Function(WorkspaceSyncState) _then;

/// Create a copy of WorkspaceSyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? lastSyncedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(WorkspaceSyncState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceSyncState].
extension WorkspaceSyncStatePatterns on WorkspaceSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceSyncState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceSyncState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceSyncState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceSyncState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceSyncState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceSyncState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncStatus status,  DateTime? lastSyncedAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceSyncState() when $default != null:
return $default(_that.status,_that.lastSyncedAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncStatus status,  DateTime? lastSyncedAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceSyncState():
return $default(_that.status,_that.lastSyncedAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncStatus status,  DateTime? lastSyncedAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceSyncState() when $default != null:
return $default(_that.status,_that.lastSyncedAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceSyncState extends WorkspaceSyncState {
  const _WorkspaceSyncState({this.status = SyncStatus.idle, this.lastSyncedAt, this.errorMessage}): super._();
  

@override@JsonKey() final  SyncStatus status;
@override final  DateTime? lastSyncedAt;
@override final  String? errorMessage;

/// Create a copy of WorkspaceSyncState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceSyncStateCopyWith<_WorkspaceSyncState> get copyWith => __$WorkspaceSyncStateCopyWithImpl<_WorkspaceSyncState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceSyncState&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,lastSyncedAt,errorMessage);
}

@override
String toString() {
    return 'WorkspaceSyncState(status: $status, lastSyncedAt: $lastSyncedAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceSyncStateCopyWith<$Res> implements $WorkspaceSyncStateCopyWith<$Res> {
  factory _$WorkspaceSyncStateCopyWith(_WorkspaceSyncState value, $Res Function(_WorkspaceSyncState) _then) = __$WorkspaceSyncStateCopyWithImpl;
@override @useResult
$Res call({
 SyncStatus status, DateTime? lastSyncedAt, String? errorMessage
});




}
/// @nodoc
class __$WorkspaceSyncStateCopyWithImpl<$Res>
    implements _$WorkspaceSyncStateCopyWith<$Res> {
  __$WorkspaceSyncStateCopyWithImpl(this._self, this._then);

  final _WorkspaceSyncState _self;
  final $Res Function(_WorkspaceSyncState) _then;

/// Create a copy of WorkspaceSyncState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? lastSyncedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_WorkspaceSyncState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
