// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamMember {

 int get id; String get name; String get email; String get role;
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<TeamMember> get copyWith => _$TeamMemberCopyWithImpl<TeamMember>(this as TeamMember, _$identity);

  /// Serializes this TeamMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TeamMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMember&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TeamMember;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.role);
}

@override
String toString() {
  final _this = this as TeamMember;
  return 'TeamMember(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $TeamMemberCopyWith<$Res>  {
  factory $TeamMemberCopyWith(TeamMember value, $Res Function(TeamMember) _then) = _$TeamMemberCopyWithImpl;
@useResult
$Res call({
 int id, String name, String email, String role
});




}
/// @nodoc
class _$TeamMemberCopyWithImpl<$Res>
    implements $TeamMemberCopyWith<$Res> {
  _$TeamMemberCopyWithImpl(this._self, this._then);

  final TeamMember _self;
  final $Res Function(TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,}) {
  return _then(TeamMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMember].
extension TeamMemberPatterns on TeamMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMember value)  $default,){
final _that = this;
switch (_that) {
case _TeamMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String email,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String email,  String role)  $default,) {final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that.id,_that.name,_that.email,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String email,  String role)?  $default,) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMember implements TeamMember {
  const _TeamMember({required this.id, required this.name, required this.email, required this.role});
  factory _TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);

@override final  int id;
@override final  String name;
@override final  String email;
@override final  String role;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberCopyWith<_TeamMember> get copyWith => __$TeamMemberCopyWithImpl<_TeamMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,role);
}

@override
String toString() {
    return 'TeamMember(id: $id, name: $name, email: $email, role: $role)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberCopyWith<$Res> implements $TeamMemberCopyWith<$Res> {
  factory _$TeamMemberCopyWith(_TeamMember value, $Res Function(_TeamMember) _then) = __$TeamMemberCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String email, String role
});




}
/// @nodoc
class __$TeamMemberCopyWithImpl<$Res>
    implements _$TeamMemberCopyWith<$Res> {
  __$TeamMemberCopyWithImpl(this._self, this._then);

  final _TeamMember _self;
  final $Res Function(_TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,}) {
  return _then(_TeamMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TeamInvitation {

 int get id; String get email; String get role; String get invitedByName; DateTime get expiresAt; DateTime get createdAt;
/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<TeamInvitation> get copyWith => _$TeamInvitationCopyWithImpl<TeamInvitation>(this as TeamInvitation, _$identity);

  /// Serializes this TeamInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TeamInvitation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamInvitation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.invitedByName, _this.invitedByName) || other.invitedByName == _this.invitedByName)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TeamInvitation;
  return Object.hash(runtimeType,_this.id,_this.email,_this.role,_this.invitedByName,_this.expiresAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as TeamInvitation;
  return 'TeamInvitation(id: ${_this.id}, email: ${_this.email}, role: ${_this.role}, invitedByName: ${_this.invitedByName}, expiresAt: ${_this.expiresAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TeamInvitationCopyWith<$Res>  {
  factory $TeamInvitationCopyWith(TeamInvitation value, $Res Function(TeamInvitation) _then) = _$TeamInvitationCopyWithImpl;
@useResult
$Res call({
 int id, String email, String role, String invitedByName, DateTime expiresAt, DateTime createdAt
});




}
/// @nodoc
class _$TeamInvitationCopyWithImpl<$Res>
    implements $TeamInvitationCopyWith<$Res> {
  _$TeamInvitationCopyWithImpl(this._self, this._then);

  final TeamInvitation _self;
  final $Res Function(TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? role = null,Object? invitedByName = null,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(TeamInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,invitedByName: null == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamInvitation].
extension TeamInvitationPatterns on TeamInvitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamInvitation value)  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String email,  String role,  String invitedByName,  DateTime expiresAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.invitedByName,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String email,  String role,  String invitedByName,  DateTime expiresAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation():
return $default(_that.id,_that.email,_that.role,_that.invitedByName,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String email,  String role,  String invitedByName,  DateTime expiresAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.invitedByName,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamInvitation implements TeamInvitation {
  const _TeamInvitation({required this.id, required this.email, required this.role, required this.invitedByName, required this.expiresAt, required this.createdAt});
  factory _TeamInvitation.fromJson(Map<String, dynamic> json) => _$TeamInvitationFromJson(json);

@override final  int id;
@override final  String email;
@override final  String role;
@override final  String invitedByName;
@override final  DateTime expiresAt;
@override final  DateTime createdAt;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamInvitationCopyWith<_TeamInvitation> get copyWith => __$TeamInvitationCopyWithImpl<_TeamInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.invitedByName, invitedByName) || other.invitedByName == invitedByName)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,role,invitedByName,expiresAt,createdAt);
}

@override
String toString() {
    return 'TeamInvitation(id: $id, email: $email, role: $role, invitedByName: $invitedByName, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TeamInvitationCopyWith<$Res> implements $TeamInvitationCopyWith<$Res> {
  factory _$TeamInvitationCopyWith(_TeamInvitation value, $Res Function(_TeamInvitation) _then) = __$TeamInvitationCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String role, String invitedByName, DateTime expiresAt, DateTime createdAt
});




}
/// @nodoc
class __$TeamInvitationCopyWithImpl<$Res>
    implements _$TeamInvitationCopyWith<$Res> {
  __$TeamInvitationCopyWithImpl(this._self, this._then);

  final _TeamInvitation _self;
  final $Res Function(_TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? role = null,Object? invitedByName = null,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(_TeamInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,invitedByName: null == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$TeamRoster {

 List<TeamMember> get members; List<TeamInvitation> get invitations;
/// Create a copy of TeamRoster
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamRosterCopyWith<TeamRoster> get copyWith => _$TeamRosterCopyWithImpl<TeamRoster>(this as TeamRoster, _$identity);

  /// Serializes this TeamRoster to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TeamRoster;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamRoster&&const DeepCollectionEquality().equals(other.members, _this.members)&&const DeepCollectionEquality().equals(other.invitations, _this.invitations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TeamRoster;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.members),const DeepCollectionEquality().hash(_this.invitations));
}

@override
String toString() {
  final _this = this as TeamRoster;
  return 'TeamRoster(members: ${_this.members}, invitations: ${_this.invitations})';
}


}

/// @nodoc
abstract mixin class $TeamRosterCopyWith<$Res>  {
  factory $TeamRosterCopyWith(TeamRoster value, $Res Function(TeamRoster) _then) = _$TeamRosterCopyWithImpl;
@useResult
$Res call({
 List<TeamMember> members, List<TeamInvitation> invitations
});




}
/// @nodoc
class _$TeamRosterCopyWithImpl<$Res>
    implements $TeamRosterCopyWith<$Res> {
  _$TeamRosterCopyWithImpl(this._self, this._then);

  final TeamRoster _self;
  final $Res Function(TeamRoster) _then;

/// Create a copy of TeamRoster
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? invitations = null,}) {
  return _then(TeamRoster(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self.invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamRoster].
extension TeamRosterPatterns on TeamRoster {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamRoster value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamRoster() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamRoster value)  $default,){
final _that = this;
switch (_that) {
case _TeamRoster():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamRoster value)?  $default,){
final _that = this;
switch (_that) {
case _TeamRoster() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TeamMember> members,  List<TeamInvitation> invitations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamRoster() when $default != null:
return $default(_that.members,_that.invitations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TeamMember> members,  List<TeamInvitation> invitations)  $default,) {final _that = this;
switch (_that) {
case _TeamRoster():
return $default(_that.members,_that.invitations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TeamMember> members,  List<TeamInvitation> invitations)?  $default,) {final _that = this;
switch (_that) {
case _TeamRoster() when $default != null:
return $default(_that.members,_that.invitations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamRoster implements TeamRoster {
  const _TeamRoster({ List<TeamMember> members = const [],  List<TeamInvitation> invitations = const []}): _members = members,_invitations = invitations;
  factory _TeamRoster.fromJson(Map<String, dynamic> json) => _$TeamRosterFromJson(json);

 final  List<TeamMember> _members;
@override@JsonKey() List<TeamMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<TeamInvitation> _invitations;
@override@JsonKey() List<TeamInvitation> get invitations {
  if (_invitations is EqualUnmodifiableListView) return _invitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitations);
}


/// Create a copy of TeamRoster
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamRosterCopyWith<_TeamRoster> get copyWith => __$TeamRosterCopyWithImpl<_TeamRoster>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamRosterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamRoster&&const DeepCollectionEquality().equals(other.members, _members)&&const DeepCollectionEquality().equals(other.invitations, _invitations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_invitations));
}

@override
String toString() {
    return 'TeamRoster(members: $members, invitations: $invitations)';
}


}

/// @nodoc
abstract mixin class _$TeamRosterCopyWith<$Res> implements $TeamRosterCopyWith<$Res> {
  factory _$TeamRosterCopyWith(_TeamRoster value, $Res Function(_TeamRoster) _then) = __$TeamRosterCopyWithImpl;
@override @useResult
$Res call({
 List<TeamMember> members, List<TeamInvitation> invitations
});




}
/// @nodoc
class __$TeamRosterCopyWithImpl<$Res>
    implements _$TeamRosterCopyWith<$Res> {
  __$TeamRosterCopyWithImpl(this._self, this._then);

  final _TeamRoster _self;
  final $Res Function(_TeamRoster) _then;

/// Create a copy of TeamRoster
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? invitations = null,}) {
  return _then(_TeamRoster(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self._invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,
  ));
}


}


/// @nodoc
mixin _$InviteResult {

 String get status; TeamMember? get member; TeamInvitation? get invitation;
/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteResultCopyWith<InviteResult> get copyWith => _$InviteResultCopyWithImpl<InviteResult>(this as InviteResult, _$identity);

  /// Serializes this InviteResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InviteResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteResult&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.member, _this.member) || other.member == _this.member)&&(identical(other.invitation, _this.invitation) || other.invitation == _this.invitation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InviteResult;
  return Object.hash(runtimeType,_this.status,_this.member,_this.invitation);
}

@override
String toString() {
  final _this = this as InviteResult;
  return 'InviteResult(status: ${_this.status}, member: ${_this.member}, invitation: ${_this.invitation})';
}


}

/// @nodoc
abstract mixin class $InviteResultCopyWith<$Res>  {
  factory $InviteResultCopyWith(InviteResult value, $Res Function(InviteResult) _then) = _$InviteResultCopyWithImpl;
@useResult
$Res call({
 String status, TeamMember? member, TeamInvitation? invitation
});


$TeamMemberCopyWith<$Res>? get member;$TeamInvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class _$InviteResultCopyWithImpl<$Res>
    implements $InviteResultCopyWith<$Res> {
  _$InviteResultCopyWithImpl(this._self, this._then);

  final InviteResult _self;
  final $Res Function(InviteResult) _then;

/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? member = freezed,Object? invitation = freezed,}) {
  return _then(InviteResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as TeamMember?,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,
  ));
}
/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $TeamMemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}


/// Adds pattern-matching-related methods to [InviteResult].
extension InviteResultPatterns on InviteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteResult value)  $default,){
final _that = this;
switch (_that) {
case _InviteResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteResult value)?  $default,){
final _that = this;
switch (_that) {
case _InviteResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  TeamMember? member,  TeamInvitation? invitation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteResult() when $default != null:
return $default(_that.status,_that.member,_that.invitation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  TeamMember? member,  TeamInvitation? invitation)  $default,) {final _that = this;
switch (_that) {
case _InviteResult():
return $default(_that.status,_that.member,_that.invitation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  TeamMember? member,  TeamInvitation? invitation)?  $default,) {final _that = this;
switch (_that) {
case _InviteResult() when $default != null:
return $default(_that.status,_that.member,_that.invitation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteResult extends InviteResult {
  const _InviteResult({required this.status, this.member, this.invitation}): super._();
  factory _InviteResult.fromJson(Map<String, dynamic> json) => _$InviteResultFromJson(json);

@override final  String status;
@override final  TeamMember? member;
@override final  TeamInvitation? invitation;

/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteResultCopyWith<_InviteResult> get copyWith => __$InviteResultCopyWithImpl<_InviteResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteResult&&(identical(other.status, status) || other.status == status)&&(identical(other.member, member) || other.member == member)&&(identical(other.invitation, invitation) || other.invitation == invitation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,member,invitation);
}

@override
String toString() {
    return 'InviteResult(status: $status, member: $member, invitation: $invitation)';
}


}

/// @nodoc
abstract mixin class _$InviteResultCopyWith<$Res> implements $InviteResultCopyWith<$Res> {
  factory _$InviteResultCopyWith(_InviteResult value, $Res Function(_InviteResult) _then) = __$InviteResultCopyWithImpl;
@override @useResult
$Res call({
 String status, TeamMember? member, TeamInvitation? invitation
});


@override $TeamMemberCopyWith<$Res>? get member;@override $TeamInvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class __$InviteResultCopyWithImpl<$Res>
    implements _$InviteResultCopyWith<$Res> {
  __$InviteResultCopyWithImpl(this._self, this._then);

  final _InviteResult _self;
  final $Res Function(_InviteResult) _then;

/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? member = freezed,Object? invitation = freezed,}) {
  return _then(_InviteResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as TeamMember?,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,
  ));
}

/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $TeamMemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of InviteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}


/// @nodoc
mixin _$JoinLink {

 bool get enabled; String? get token; DateTime? get expiresAt; String? get sharePath;
/// Create a copy of JoinLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinLinkCopyWith<JoinLink> get copyWith => _$JoinLinkCopyWithImpl<JoinLink>(this as JoinLink, _$identity);

  /// Serializes this JoinLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JoinLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinLink&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.sharePath, _this.sharePath) || other.sharePath == _this.sharePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JoinLink;
  return Object.hash(runtimeType,_this.enabled,_this.token,_this.expiresAt,_this.sharePath);
}

@override
String toString() {
  final _this = this as JoinLink;
  return 'JoinLink(enabled: ${_this.enabled}, token: ${_this.token}, expiresAt: ${_this.expiresAt}, sharePath: ${_this.sharePath})';
}


}

/// @nodoc
abstract mixin class $JoinLinkCopyWith<$Res>  {
  factory $JoinLinkCopyWith(JoinLink value, $Res Function(JoinLink) _then) = _$JoinLinkCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? token, DateTime? expiresAt, String? sharePath
});




}
/// @nodoc
class _$JoinLinkCopyWithImpl<$Res>
    implements $JoinLinkCopyWith<$Res> {
  _$JoinLinkCopyWithImpl(this._self, this._then);

  final JoinLink _self;
  final $Res Function(JoinLink) _then;

/// Create a copy of JoinLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? token = freezed,Object? expiresAt = freezed,Object? sharePath = freezed,}) {
  return _then(JoinLink(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharePath: freezed == sharePath ? _self.sharePath : sharePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinLink].
extension JoinLinkPatterns on JoinLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinLink value)  $default,){
final _that = this;
switch (_that) {
case _JoinLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinLink value)?  $default,){
final _that = this;
switch (_that) {
case _JoinLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? token,  DateTime? expiresAt,  String? sharePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinLink() when $default != null:
return $default(_that.enabled,_that.token,_that.expiresAt,_that.sharePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? token,  DateTime? expiresAt,  String? sharePath)  $default,) {final _that = this;
switch (_that) {
case _JoinLink():
return $default(_that.enabled,_that.token,_that.expiresAt,_that.sharePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? token,  DateTime? expiresAt,  String? sharePath)?  $default,) {final _that = this;
switch (_that) {
case _JoinLink() when $default != null:
return $default(_that.enabled,_that.token,_that.expiresAt,_that.sharePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinLink extends JoinLink {
  const _JoinLink({required this.enabled, this.token, this.expiresAt, this.sharePath}): super._();
  factory _JoinLink.fromJson(Map<String, dynamic> json) => _$JoinLinkFromJson(json);

@override final  bool enabled;
@override final  String? token;
@override final  DateTime? expiresAt;
@override final  String? sharePath;

/// Create a copy of JoinLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinLinkCopyWith<_JoinLink> get copyWith => __$JoinLinkCopyWithImpl<_JoinLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinLink&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.sharePath, sharePath) || other.sharePath == sharePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,token,expiresAt,sharePath);
}

@override
String toString() {
    return 'JoinLink(enabled: $enabled, token: $token, expiresAt: $expiresAt, sharePath: $sharePath)';
}


}

/// @nodoc
abstract mixin class _$JoinLinkCopyWith<$Res> implements $JoinLinkCopyWith<$Res> {
  factory _$JoinLinkCopyWith(_JoinLink value, $Res Function(_JoinLink) _then) = __$JoinLinkCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? token, DateTime? expiresAt, String? sharePath
});




}
/// @nodoc
class __$JoinLinkCopyWithImpl<$Res>
    implements _$JoinLinkCopyWith<$Res> {
  __$JoinLinkCopyWithImpl(this._self, this._then);

  final _JoinLink _self;
  final $Res Function(_JoinLink) _then;

/// Create a copy of JoinLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? token = freezed,Object? expiresAt = freezed,Object? sharePath = freezed,}) {
  return _then(_JoinLink(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharePath: freezed == sharePath ? _self.sharePath : sharePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$JoinPreview {

 String get workspaceName; String get role; String? get email;
/// Create a copy of JoinPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinPreviewCopyWith<JoinPreview> get copyWith => _$JoinPreviewCopyWithImpl<JoinPreview>(this as JoinPreview, _$identity);

  /// Serializes this JoinPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JoinPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinPreview&&(identical(other.workspaceName, _this.workspaceName) || other.workspaceName == _this.workspaceName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JoinPreview;
  return Object.hash(runtimeType,_this.workspaceName,_this.role,_this.email);
}

@override
String toString() {
  final _this = this as JoinPreview;
  return 'JoinPreview(workspaceName: ${_this.workspaceName}, role: ${_this.role}, email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $JoinPreviewCopyWith<$Res>  {
  factory $JoinPreviewCopyWith(JoinPreview value, $Res Function(JoinPreview) _then) = _$JoinPreviewCopyWithImpl;
@useResult
$Res call({
 String workspaceName, String role, String? email
});




}
/// @nodoc
class _$JoinPreviewCopyWithImpl<$Res>
    implements $JoinPreviewCopyWith<$Res> {
  _$JoinPreviewCopyWithImpl(this._self, this._then);

  final JoinPreview _self;
  final $Res Function(JoinPreview) _then;

/// Create a copy of JoinPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaceName = null,Object? role = null,Object? email = freezed,}) {
  return _then(JoinPreview(
workspaceName: null == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinPreview].
extension JoinPreviewPatterns on JoinPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinPreview value)  $default,){
final _that = this;
switch (_that) {
case _JoinPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinPreview value)?  $default,){
final _that = this;
switch (_that) {
case _JoinPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String workspaceName,  String role,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinPreview() when $default != null:
return $default(_that.workspaceName,_that.role,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String workspaceName,  String role,  String? email)  $default,) {final _that = this;
switch (_that) {
case _JoinPreview():
return $default(_that.workspaceName,_that.role,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String workspaceName,  String role,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _JoinPreview() when $default != null:
return $default(_that.workspaceName,_that.role,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinPreview implements JoinPreview {
  const _JoinPreview({required this.workspaceName, required this.role, this.email});
  factory _JoinPreview.fromJson(Map<String, dynamic> json) => _$JoinPreviewFromJson(json);

@override final  String workspaceName;
@override final  String role;
@override final  String? email;

/// Create a copy of JoinPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinPreviewCopyWith<_JoinPreview> get copyWith => __$JoinPreviewCopyWithImpl<_JoinPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinPreview&&(identical(other.workspaceName, workspaceName) || other.workspaceName == workspaceName)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,workspaceName,role,email);
}

@override
String toString() {
    return 'JoinPreview(workspaceName: $workspaceName, role: $role, email: $email)';
}


}

/// @nodoc
abstract mixin class _$JoinPreviewCopyWith<$Res> implements $JoinPreviewCopyWith<$Res> {
  factory _$JoinPreviewCopyWith(_JoinPreview value, $Res Function(_JoinPreview) _then) = __$JoinPreviewCopyWithImpl;
@override @useResult
$Res call({
 String workspaceName, String role, String? email
});




}
/// @nodoc
class __$JoinPreviewCopyWithImpl<$Res>
    implements _$JoinPreviewCopyWith<$Res> {
  __$JoinPreviewCopyWithImpl(this._self, this._then);

  final _JoinPreview _self;
  final $Res Function(_JoinPreview) _then;

/// Create a copy of JoinPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceName = null,Object? role = null,Object? email = freezed,}) {
  return _then(_JoinPreview(
workspaceName: null == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
