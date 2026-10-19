// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_form_controllers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFormState {

 bool get pending; bool get googlePending; String? get formError; Map<String, String> get fieldErrors;/// Forgot password: the address the reset link went to.
 String? get sentTo;
/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFormStateCopyWith<AuthFormState> get copyWith => _$AuthFormStateCopyWithImpl<AuthFormState>(this as AuthFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFormState&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.googlePending, _this.googlePending) || other.googlePending == _this.googlePending)&&(identical(other.formError, _this.formError) || other.formError == _this.formError)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors)&&(identical(other.sentTo, _this.sentTo) || other.sentTo == _this.sentTo));
}


@override
int get hashCode {
  final _this = this as AuthFormState;
  return Object.hash(runtimeType,_this.pending,_this.googlePending,_this.formError,const DeepCollectionEquality().hash(_this.fieldErrors),_this.sentTo);
}

@override
String toString() {
  final _this = this as AuthFormState;
  return 'AuthFormState(pending: ${_this.pending}, googlePending: ${_this.googlePending}, formError: ${_this.formError}, fieldErrors: ${_this.fieldErrors}, sentTo: ${_this.sentTo})';
}


}

/// @nodoc
abstract mixin class $AuthFormStateCopyWith<$Res>  {
  factory $AuthFormStateCopyWith(AuthFormState value, $Res Function(AuthFormState) _then) = _$AuthFormStateCopyWithImpl;
@useResult
$Res call({
 bool pending, bool googlePending, String? formError, Map<String, String> fieldErrors, String? sentTo
});




}
/// @nodoc
class _$AuthFormStateCopyWithImpl<$Res>
    implements $AuthFormStateCopyWith<$Res> {
  _$AuthFormStateCopyWithImpl(this._self, this._then);

  final AuthFormState _self;
  final $Res Function(AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,Object? googlePending = null,Object? formError = freezed,Object? fieldErrors = null,Object? sentTo = freezed,}) {
  return _then(AuthFormState(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,googlePending: null == googlePending ? _self.googlePending : googlePending // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,sentTo: freezed == sentTo ? _self.sentTo : sentTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthFormState].
extension AuthFormStatePatterns on AuthFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthFormState value)  $default,){
final _that = this;
switch (_that) {
case _AuthFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pending,  bool googlePending,  String? formError,  Map<String, String> fieldErrors,  String? sentTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.pending,_that.googlePending,_that.formError,_that.fieldErrors,_that.sentTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pending,  bool googlePending,  String? formError,  Map<String, String> fieldErrors,  String? sentTo)  $default,) {final _that = this;
switch (_that) {
case _AuthFormState():
return $default(_that.pending,_that.googlePending,_that.formError,_that.fieldErrors,_that.sentTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pending,  bool googlePending,  String? formError,  Map<String, String> fieldErrors,  String? sentTo)?  $default,) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.pending,_that.googlePending,_that.formError,_that.fieldErrors,_that.sentTo);case _:
  return null;

}
}

}

/// @nodoc


class _AuthFormState extends AuthFormState {
  const _AuthFormState({this.pending = false, this.googlePending = false, this.formError,  Map<String, String> fieldErrors = const <String, String>{}, this.sentTo}): _fieldErrors = fieldErrors,super._();
  

@override@JsonKey() final  bool pending;
@override@JsonKey() final  bool googlePending;
@override final  String? formError;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

/// Forgot password: the address the reset link went to.
@override final  String? sentTo;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthFormStateCopyWith<_AuthFormState> get copyWith => __$AuthFormStateCopyWithImpl<_AuthFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthFormState&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.googlePending, googlePending) || other.googlePending == googlePending)&&(identical(other.formError, formError) || other.formError == formError)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors)&&(identical(other.sentTo, sentTo) || other.sentTo == sentTo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pending,googlePending,formError,const DeepCollectionEquality().hash(_fieldErrors),sentTo);
}

@override
String toString() {
    return 'AuthFormState(pending: $pending, googlePending: $googlePending, formError: $formError, fieldErrors: $fieldErrors, sentTo: $sentTo)';
}


}

/// @nodoc
abstract mixin class _$AuthFormStateCopyWith<$Res> implements $AuthFormStateCopyWith<$Res> {
  factory _$AuthFormStateCopyWith(_AuthFormState value, $Res Function(_AuthFormState) _then) = __$AuthFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool pending, bool googlePending, String? formError, Map<String, String> fieldErrors, String? sentTo
});




}
/// @nodoc
class __$AuthFormStateCopyWithImpl<$Res>
    implements _$AuthFormStateCopyWith<$Res> {
  __$AuthFormStateCopyWithImpl(this._self, this._then);

  final _AuthFormState _self;
  final $Res Function(_AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? googlePending = null,Object? formError = freezed,Object? fieldErrors = null,Object? sentTo = freezed,}) {
  return _then(_AuthFormState(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,googlePending: null == googlePending ? _self.googlePending : googlePending // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,sentTo: freezed == sentTo ? _self.sentTo : sentTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
