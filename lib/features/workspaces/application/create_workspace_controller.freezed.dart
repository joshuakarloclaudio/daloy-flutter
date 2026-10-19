// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_workspace_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateWorkspaceState {

 bool get pending; String? get error;
/// Create a copy of CreateWorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWorkspaceStateCopyWith<CreateWorkspaceState> get copyWith => _$CreateWorkspaceStateCopyWithImpl<CreateWorkspaceState>(this as CreateWorkspaceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreateWorkspaceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWorkspaceState&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CreateWorkspaceState;
  return Object.hash(runtimeType,_this.pending,_this.error);
}

@override
String toString() {
  final _this = this as CreateWorkspaceState;
  return 'CreateWorkspaceState(pending: ${_this.pending}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CreateWorkspaceStateCopyWith<$Res>  {
  factory $CreateWorkspaceStateCopyWith(CreateWorkspaceState value, $Res Function(CreateWorkspaceState) _then) = _$CreateWorkspaceStateCopyWithImpl;
@useResult
$Res call({
 bool pending, String? error
});




}
/// @nodoc
class _$CreateWorkspaceStateCopyWithImpl<$Res>
    implements $CreateWorkspaceStateCopyWith<$Res> {
  _$CreateWorkspaceStateCopyWithImpl(this._self, this._then);

  final CreateWorkspaceState _self;
  final $Res Function(CreateWorkspaceState) _then;

/// Create a copy of CreateWorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,Object? error = freezed,}) {
  return _then(CreateWorkspaceState(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWorkspaceState].
extension CreateWorkspaceStatePatterns on CreateWorkspaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWorkspaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _CreateWorkspaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWorkspaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pending,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWorkspaceState() when $default != null:
return $default(_that.pending,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pending,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CreateWorkspaceState():
return $default(_that.pending,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pending,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CreateWorkspaceState() when $default != null:
return $default(_that.pending,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CreateWorkspaceState implements CreateWorkspaceState {
  const _CreateWorkspaceState({this.pending = false, this.error});
  

@override@JsonKey() final  bool pending;
@override final  String? error;

/// Create a copy of CreateWorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWorkspaceStateCopyWith<_CreateWorkspaceState> get copyWith => __$CreateWorkspaceStateCopyWithImpl<_CreateWorkspaceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWorkspaceState&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pending,error);
}

@override
String toString() {
    return 'CreateWorkspaceState(pending: $pending, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CreateWorkspaceStateCopyWith<$Res> implements $CreateWorkspaceStateCopyWith<$Res> {
  factory _$CreateWorkspaceStateCopyWith(_CreateWorkspaceState value, $Res Function(_CreateWorkspaceState) _then) = __$CreateWorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 bool pending, String? error
});




}
/// @nodoc
class __$CreateWorkspaceStateCopyWithImpl<$Res>
    implements _$CreateWorkspaceStateCopyWith<$Res> {
  __$CreateWorkspaceStateCopyWithImpl(this._self, this._then);

  final _CreateWorkspaceState _self;
  final $Res Function(_CreateWorkspaceState) _then;

/// Create a copy of CreateWorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? error = freezed,}) {
  return _then(_CreateWorkspaceState(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
