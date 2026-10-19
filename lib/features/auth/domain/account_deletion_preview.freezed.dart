// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_deletion_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountDeletionPreview {

 bool get requiresPassword; bool get canDelete;/// Workspaces where you're the only admin and others still depend on you.
 List<DeletionWorkspace> get blocking;/// Workspaces only you belong to; they go with the account.
 List<DeletionWorkspace> get willDelete;
/// Create a copy of AccountDeletionPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionPreviewCopyWith<AccountDeletionPreview> get copyWith => _$AccountDeletionPreviewCopyWithImpl<AccountDeletionPreview>(this as AccountDeletionPreview, _$identity);

  /// Serializes this AccountDeletionPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountDeletionPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionPreview&&(identical(other.requiresPassword, _this.requiresPassword) || other.requiresPassword == _this.requiresPassword)&&(identical(other.canDelete, _this.canDelete) || other.canDelete == _this.canDelete)&&const DeepCollectionEquality().equals(other.blocking, _this.blocking)&&const DeepCollectionEquality().equals(other.willDelete, _this.willDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountDeletionPreview;
  return Object.hash(runtimeType,_this.requiresPassword,_this.canDelete,const DeepCollectionEquality().hash(_this.blocking),const DeepCollectionEquality().hash(_this.willDelete));
}

@override
String toString() {
  final _this = this as AccountDeletionPreview;
  return 'AccountDeletionPreview(requiresPassword: ${_this.requiresPassword}, canDelete: ${_this.canDelete}, blocking: ${_this.blocking}, willDelete: ${_this.willDelete})';
}


}

/// @nodoc
abstract mixin class $AccountDeletionPreviewCopyWith<$Res>  {
  factory $AccountDeletionPreviewCopyWith(AccountDeletionPreview value, $Res Function(AccountDeletionPreview) _then) = _$AccountDeletionPreviewCopyWithImpl;
@useResult
$Res call({
 bool requiresPassword, bool canDelete, List<DeletionWorkspace> blocking, List<DeletionWorkspace> willDelete
});




}
/// @nodoc
class _$AccountDeletionPreviewCopyWithImpl<$Res>
    implements $AccountDeletionPreviewCopyWith<$Res> {
  _$AccountDeletionPreviewCopyWithImpl(this._self, this._then);

  final AccountDeletionPreview _self;
  final $Res Function(AccountDeletionPreview) _then;

/// Create a copy of AccountDeletionPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requiresPassword = null,Object? canDelete = null,Object? blocking = null,Object? willDelete = null,}) {
  return _then(AccountDeletionPreview(
requiresPassword: null == requiresPassword ? _self.requiresPassword : requiresPassword // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,blocking: null == blocking ? _self.blocking : blocking // ignore: cast_nullable_to_non_nullable
as List<DeletionWorkspace>,willDelete: null == willDelete ? _self.willDelete : willDelete // ignore: cast_nullable_to_non_nullable
as List<DeletionWorkspace>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionPreview].
extension AccountDeletionPreviewPatterns on AccountDeletionPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionPreview value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionPreview value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool requiresPassword,  bool canDelete,  List<DeletionWorkspace> blocking,  List<DeletionWorkspace> willDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionPreview() when $default != null:
return $default(_that.requiresPassword,_that.canDelete,_that.blocking,_that.willDelete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool requiresPassword,  bool canDelete,  List<DeletionWorkspace> blocking,  List<DeletionWorkspace> willDelete)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionPreview():
return $default(_that.requiresPassword,_that.canDelete,_that.blocking,_that.willDelete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool requiresPassword,  bool canDelete,  List<DeletionWorkspace> blocking,  List<DeletionWorkspace> willDelete)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionPreview() when $default != null:
return $default(_that.requiresPassword,_that.canDelete,_that.blocking,_that.willDelete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDeletionPreview implements AccountDeletionPreview {
  const _AccountDeletionPreview({required this.requiresPassword, required this.canDelete,  List<DeletionWorkspace> blocking = const [],  List<DeletionWorkspace> willDelete = const []}): _blocking = blocking,_willDelete = willDelete;
  factory _AccountDeletionPreview.fromJson(Map<String, dynamic> json) => _$AccountDeletionPreviewFromJson(json);

@override final  bool requiresPassword;
@override final  bool canDelete;
/// Workspaces where you're the only admin and others still depend on you.
 final  List<DeletionWorkspace> _blocking;
/// Workspaces where you're the only admin and others still depend on you.
@override@JsonKey() List<DeletionWorkspace> get blocking {
  if (_blocking is EqualUnmodifiableListView) return _blocking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocking);
}

/// Workspaces only you belong to; they go with the account.
 final  List<DeletionWorkspace> _willDelete;
/// Workspaces only you belong to; they go with the account.
@override@JsonKey() List<DeletionWorkspace> get willDelete {
  if (_willDelete is EqualUnmodifiableListView) return _willDelete;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_willDelete);
}


/// Create a copy of AccountDeletionPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionPreviewCopyWith<_AccountDeletionPreview> get copyWith => __$AccountDeletionPreviewCopyWithImpl<_AccountDeletionPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDeletionPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionPreview&&(identical(other.requiresPassword, requiresPassword) || other.requiresPassword == requiresPassword)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&const DeepCollectionEquality().equals(other.blocking, _blocking)&&const DeepCollectionEquality().equals(other.willDelete, _willDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,requiresPassword,canDelete,const DeepCollectionEquality().hash(_blocking),const DeepCollectionEquality().hash(_willDelete));
}

@override
String toString() {
    return 'AccountDeletionPreview(requiresPassword: $requiresPassword, canDelete: $canDelete, blocking: $blocking, willDelete: $willDelete)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionPreviewCopyWith<$Res> implements $AccountDeletionPreviewCopyWith<$Res> {
  factory _$AccountDeletionPreviewCopyWith(_AccountDeletionPreview value, $Res Function(_AccountDeletionPreview) _then) = __$AccountDeletionPreviewCopyWithImpl;
@override @useResult
$Res call({
 bool requiresPassword, bool canDelete, List<DeletionWorkspace> blocking, List<DeletionWorkspace> willDelete
});




}
/// @nodoc
class __$AccountDeletionPreviewCopyWithImpl<$Res>
    implements _$AccountDeletionPreviewCopyWith<$Res> {
  __$AccountDeletionPreviewCopyWithImpl(this._self, this._then);

  final _AccountDeletionPreview _self;
  final $Res Function(_AccountDeletionPreview) _then;

/// Create a copy of AccountDeletionPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requiresPassword = null,Object? canDelete = null,Object? blocking = null,Object? willDelete = null,}) {
  return _then(_AccountDeletionPreview(
requiresPassword: null == requiresPassword ? _self.requiresPassword : requiresPassword // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,blocking: null == blocking ? _self._blocking : blocking // ignore: cast_nullable_to_non_nullable
as List<DeletionWorkspace>,willDelete: null == willDelete ? _self._willDelete : willDelete // ignore: cast_nullable_to_non_nullable
as List<DeletionWorkspace>,
  ));
}


}


/// @nodoc
mixin _$DeletionWorkspace {

 int get id; String get name;
/// Create a copy of DeletionWorkspace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeletionWorkspaceCopyWith<DeletionWorkspace> get copyWith => _$DeletionWorkspaceCopyWithImpl<DeletionWorkspace>(this as DeletionWorkspace, _$identity);

  /// Serializes this DeletionWorkspace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeletionWorkspace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeletionWorkspace&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeletionWorkspace;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as DeletionWorkspace;
  return 'DeletionWorkspace(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $DeletionWorkspaceCopyWith<$Res>  {
  factory $DeletionWorkspaceCopyWith(DeletionWorkspace value, $Res Function(DeletionWorkspace) _then) = _$DeletionWorkspaceCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$DeletionWorkspaceCopyWithImpl<$Res>
    implements $DeletionWorkspaceCopyWith<$Res> {
  _$DeletionWorkspaceCopyWithImpl(this._self, this._then);

  final DeletionWorkspace _self;
  final $Res Function(DeletionWorkspace) _then;

/// Create a copy of DeletionWorkspace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(DeletionWorkspace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeletionWorkspace].
extension DeletionWorkspacePatterns on DeletionWorkspace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeletionWorkspace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeletionWorkspace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeletionWorkspace value)  $default,){
final _that = this;
switch (_that) {
case _DeletionWorkspace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeletionWorkspace value)?  $default,){
final _that = this;
switch (_that) {
case _DeletionWorkspace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeletionWorkspace() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _DeletionWorkspace():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _DeletionWorkspace() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeletionWorkspace implements DeletionWorkspace {
  const _DeletionWorkspace({required this.id, required this.name});
  factory _DeletionWorkspace.fromJson(Map<String, dynamic> json) => _$DeletionWorkspaceFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of DeletionWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeletionWorkspaceCopyWith<_DeletionWorkspace> get copyWith => __$DeletionWorkspaceCopyWithImpl<_DeletionWorkspace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeletionWorkspaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeletionWorkspace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'DeletionWorkspace(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$DeletionWorkspaceCopyWith<$Res> implements $DeletionWorkspaceCopyWith<$Res> {
  factory _$DeletionWorkspaceCopyWith(_DeletionWorkspace value, $Res Function(_DeletionWorkspace) _then) = __$DeletionWorkspaceCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$DeletionWorkspaceCopyWithImpl<$Res>
    implements _$DeletionWorkspaceCopyWith<$Res> {
  __$DeletionWorkspaceCopyWithImpl(this._self, this._then);

  final _DeletionWorkspace _self;
  final $Res Function(_DeletionWorkspace) _then;

/// Create a copy of DeletionWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_DeletionWorkspace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
