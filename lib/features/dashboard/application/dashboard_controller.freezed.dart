// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 int? get workspaceId; String? get workspaceName; String? get userName; bool get isOnline; bool get showSkeletons; bool get isSyncing; LiveSession? get liveSession; LineUp? get liveSessionLineUp; bool get isLiveSessionLoading; LineUp? get featuredLineUp; List<LineUp> get recentLineUps; List<Song> get recentSongs; List<Song> get jumpBackInSongs;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.workspaceId, _this.workspaceId) || other.workspaceId == _this.workspaceId)&&(identical(other.workspaceName, _this.workspaceName) || other.workspaceName == _this.workspaceName)&&(identical(other.userName, _this.userName) || other.userName == _this.userName)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline)&&(identical(other.showSkeletons, _this.showSkeletons) || other.showSkeletons == _this.showSkeletons)&&(identical(other.isSyncing, _this.isSyncing) || other.isSyncing == _this.isSyncing)&&(identical(other.liveSession, _this.liveSession) || other.liveSession == _this.liveSession)&&(identical(other.liveSessionLineUp, _this.liveSessionLineUp) || other.liveSessionLineUp == _this.liveSessionLineUp)&&(identical(other.isLiveSessionLoading, _this.isLiveSessionLoading) || other.isLiveSessionLoading == _this.isLiveSessionLoading)&&(identical(other.featuredLineUp, _this.featuredLineUp) || other.featuredLineUp == _this.featuredLineUp)&&const DeepCollectionEquality().equals(other.recentLineUps, _this.recentLineUps)&&const DeepCollectionEquality().equals(other.recentSongs, _this.recentSongs)&&const DeepCollectionEquality().equals(other.jumpBackInSongs, _this.jumpBackInSongs));
}


@override
int get hashCode {
  final _this = this as DashboardState;
  return Object.hash(runtimeType,_this.workspaceId,_this.workspaceName,_this.userName,_this.isOnline,_this.showSkeletons,_this.isSyncing,_this.liveSession,_this.liveSessionLineUp,_this.isLiveSessionLoading,_this.featuredLineUp,const DeepCollectionEquality().hash(_this.recentLineUps),const DeepCollectionEquality().hash(_this.recentSongs),const DeepCollectionEquality().hash(_this.jumpBackInSongs));
}

@override
String toString() {
  final _this = this as DashboardState;
  return 'DashboardState(workspaceId: ${_this.workspaceId}, workspaceName: ${_this.workspaceName}, userName: ${_this.userName}, isOnline: ${_this.isOnline}, showSkeletons: ${_this.showSkeletons}, isSyncing: ${_this.isSyncing}, liveSession: ${_this.liveSession}, liveSessionLineUp: ${_this.liveSessionLineUp}, isLiveSessionLoading: ${_this.isLiveSessionLoading}, featuredLineUp: ${_this.featuredLineUp}, recentLineUps: ${_this.recentLineUps}, recentSongs: ${_this.recentSongs}, jumpBackInSongs: ${_this.jumpBackInSongs})';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 int? workspaceId, String? workspaceName, String? userName, bool isOnline, bool showSkeletons, bool isSyncing, LiveSession? liveSession, LineUp? liveSessionLineUp, bool isLiveSessionLoading, LineUp? featuredLineUp, List<LineUp> recentLineUps, List<Song> recentSongs, List<Song> jumpBackInSongs
});


$LiveSessionCopyWith<$Res>? get liveSession;$LineUpCopyWith<$Res>? get liveSessionLineUp;$LineUpCopyWith<$Res>? get featuredLineUp;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaceId = freezed,Object? workspaceName = freezed,Object? userName = freezed,Object? isOnline = null,Object? showSkeletons = null,Object? isSyncing = null,Object? liveSession = freezed,Object? liveSessionLineUp = freezed,Object? isLiveSessionLoading = null,Object? featuredLineUp = freezed,Object? recentLineUps = null,Object? recentSongs = null,Object? jumpBackInSongs = null,}) {
  return _then(DashboardState(
workspaceId: freezed == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as int?,workspaceName: freezed == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,showSkeletons: null == showSkeletons ? _self.showSkeletons : showSkeletons // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,liveSession: freezed == liveSession ? _self.liveSession : liveSession // ignore: cast_nullable_to_non_nullable
as LiveSession?,liveSessionLineUp: freezed == liveSessionLineUp ? _self.liveSessionLineUp : liveSessionLineUp // ignore: cast_nullable_to_non_nullable
as LineUp?,isLiveSessionLoading: null == isLiveSessionLoading ? _self.isLiveSessionLoading : isLiveSessionLoading // ignore: cast_nullable_to_non_nullable
as bool,featuredLineUp: freezed == featuredLineUp ? _self.featuredLineUp : featuredLineUp // ignore: cast_nullable_to_non_nullable
as LineUp?,recentLineUps: null == recentLineUps ? _self.recentLineUps : recentLineUps // ignore: cast_nullable_to_non_nullable
as List<LineUp>,recentSongs: null == recentSongs ? _self.recentSongs : recentSongs // ignore: cast_nullable_to_non_nullable
as List<Song>,jumpBackInSongs: null == jumpBackInSongs ? _self.jumpBackInSongs : jumpBackInSongs // ignore: cast_nullable_to_non_nullable
as List<Song>,
  ));
}
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveSessionCopyWith<$Res>? get liveSession {
    if (_self.liveSession == null) {
    return null;
  }

  return $LiveSessionCopyWith<$Res>(_self.liveSession!, (value) {
    return _then(_self.copyWith(liveSession: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineUpCopyWith<$Res>? get liveSessionLineUp {
    if (_self.liveSessionLineUp == null) {
    return null;
  }

  return $LineUpCopyWith<$Res>(_self.liveSessionLineUp!, (value) {
    return _then(_self.copyWith(liveSessionLineUp: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineUpCopyWith<$Res>? get featuredLineUp {
    if (_self.featuredLineUp == null) {
    return null;
  }

  return $LineUpCopyWith<$Res>(_self.featuredLineUp!, (value) {
    return _then(_self.copyWith(featuredLineUp: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? workspaceId,  String? workspaceName,  String? userName,  bool isOnline,  bool showSkeletons,  bool isSyncing,  LiveSession? liveSession,  LineUp? liveSessionLineUp,  bool isLiveSessionLoading,  LineUp? featuredLineUp,  List<LineUp> recentLineUps,  List<Song> recentSongs,  List<Song> jumpBackInSongs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.workspaceId,_that.workspaceName,_that.userName,_that.isOnline,_that.showSkeletons,_that.isSyncing,_that.liveSession,_that.liveSessionLineUp,_that.isLiveSessionLoading,_that.featuredLineUp,_that.recentLineUps,_that.recentSongs,_that.jumpBackInSongs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? workspaceId,  String? workspaceName,  String? userName,  bool isOnline,  bool showSkeletons,  bool isSyncing,  LiveSession? liveSession,  LineUp? liveSessionLineUp,  bool isLiveSessionLoading,  LineUp? featuredLineUp,  List<LineUp> recentLineUps,  List<Song> recentSongs,  List<Song> jumpBackInSongs)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.workspaceId,_that.workspaceName,_that.userName,_that.isOnline,_that.showSkeletons,_that.isSyncing,_that.liveSession,_that.liveSessionLineUp,_that.isLiveSessionLoading,_that.featuredLineUp,_that.recentLineUps,_that.recentSongs,_that.jumpBackInSongs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? workspaceId,  String? workspaceName,  String? userName,  bool isOnline,  bool showSkeletons,  bool isSyncing,  LiveSession? liveSession,  LineUp? liveSessionLineUp,  bool isLiveSessionLoading,  LineUp? featuredLineUp,  List<LineUp> recentLineUps,  List<Song> recentSongs,  List<Song> jumpBackInSongs)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.workspaceId,_that.workspaceName,_that.userName,_that.isOnline,_that.showSkeletons,_that.isSyncing,_that.liveSession,_that.liveSessionLineUp,_that.isLiveSessionLoading,_that.featuredLineUp,_that.recentLineUps,_that.recentSongs,_that.jumpBackInSongs);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState extends DashboardState {
  const _DashboardState({this.workspaceId, this.workspaceName, this.userName, this.isOnline = true, this.showSkeletons = false, this.isSyncing = false, this.liveSession, this.liveSessionLineUp, this.isLiveSessionLoading = false, this.featuredLineUp,  List<LineUp> recentLineUps = const [],  List<Song> recentSongs = const [],  List<Song> jumpBackInSongs = const []}): _recentLineUps = recentLineUps,_recentSongs = recentSongs,_jumpBackInSongs = jumpBackInSongs,super._();
  

@override final  int? workspaceId;
@override final  String? workspaceName;
@override final  String? userName;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  bool showSkeletons;
@override@JsonKey() final  bool isSyncing;
@override final  LiveSession? liveSession;
@override final  LineUp? liveSessionLineUp;
@override@JsonKey() final  bool isLiveSessionLoading;
@override final  LineUp? featuredLineUp;
 final  List<LineUp> _recentLineUps;
@override@JsonKey() List<LineUp> get recentLineUps {
  if (_recentLineUps is EqualUnmodifiableListView) return _recentLineUps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentLineUps);
}

 final  List<Song> _recentSongs;
@override@JsonKey() List<Song> get recentSongs {
  if (_recentSongs is EqualUnmodifiableListView) return _recentSongs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSongs);
}

 final  List<Song> _jumpBackInSongs;
@override@JsonKey() List<Song> get jumpBackInSongs {
  if (_jumpBackInSongs is EqualUnmodifiableListView) return _jumpBackInSongs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jumpBackInSongs);
}


/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.workspaceName, workspaceName) || other.workspaceName == workspaceName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.showSkeletons, showSkeletons) || other.showSkeletons == showSkeletons)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.liveSession, liveSession) || other.liveSession == liveSession)&&(identical(other.liveSessionLineUp, liveSessionLineUp) || other.liveSessionLineUp == liveSessionLineUp)&&(identical(other.isLiveSessionLoading, isLiveSessionLoading) || other.isLiveSessionLoading == isLiveSessionLoading)&&(identical(other.featuredLineUp, featuredLineUp) || other.featuredLineUp == featuredLineUp)&&const DeepCollectionEquality().equals(other.recentLineUps, _recentLineUps)&&const DeepCollectionEquality().equals(other.recentSongs, _recentSongs)&&const DeepCollectionEquality().equals(other.jumpBackInSongs, _jumpBackInSongs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,workspaceId,workspaceName,userName,isOnline,showSkeletons,isSyncing,liveSession,liveSessionLineUp,isLiveSessionLoading,featuredLineUp,const DeepCollectionEquality().hash(_recentLineUps),const DeepCollectionEquality().hash(_recentSongs),const DeepCollectionEquality().hash(_jumpBackInSongs));
}

@override
String toString() {
    return 'DashboardState(workspaceId: $workspaceId, workspaceName: $workspaceName, userName: $userName, isOnline: $isOnline, showSkeletons: $showSkeletons, isSyncing: $isSyncing, liveSession: $liveSession, liveSessionLineUp: $liveSessionLineUp, isLiveSessionLoading: $isLiveSessionLoading, featuredLineUp: $featuredLineUp, recentLineUps: $recentLineUps, recentSongs: $recentSongs, jumpBackInSongs: $jumpBackInSongs)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 int? workspaceId, String? workspaceName, String? userName, bool isOnline, bool showSkeletons, bool isSyncing, LiveSession? liveSession, LineUp? liveSessionLineUp, bool isLiveSessionLoading, LineUp? featuredLineUp, List<LineUp> recentLineUps, List<Song> recentSongs, List<Song> jumpBackInSongs
});


@override $LiveSessionCopyWith<$Res>? get liveSession;@override $LineUpCopyWith<$Res>? get liveSessionLineUp;@override $LineUpCopyWith<$Res>? get featuredLineUp;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceId = freezed,Object? workspaceName = freezed,Object? userName = freezed,Object? isOnline = null,Object? showSkeletons = null,Object? isSyncing = null,Object? liveSession = freezed,Object? liveSessionLineUp = freezed,Object? isLiveSessionLoading = null,Object? featuredLineUp = freezed,Object? recentLineUps = null,Object? recentSongs = null,Object? jumpBackInSongs = null,}) {
  return _then(_DashboardState(
workspaceId: freezed == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as int?,workspaceName: freezed == workspaceName ? _self.workspaceName : workspaceName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,showSkeletons: null == showSkeletons ? _self.showSkeletons : showSkeletons // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,liveSession: freezed == liveSession ? _self.liveSession : liveSession // ignore: cast_nullable_to_non_nullable
as LiveSession?,liveSessionLineUp: freezed == liveSessionLineUp ? _self.liveSessionLineUp : liveSessionLineUp // ignore: cast_nullable_to_non_nullable
as LineUp?,isLiveSessionLoading: null == isLiveSessionLoading ? _self.isLiveSessionLoading : isLiveSessionLoading // ignore: cast_nullable_to_non_nullable
as bool,featuredLineUp: freezed == featuredLineUp ? _self.featuredLineUp : featuredLineUp // ignore: cast_nullable_to_non_nullable
as LineUp?,recentLineUps: null == recentLineUps ? _self._recentLineUps : recentLineUps // ignore: cast_nullable_to_non_nullable
as List<LineUp>,recentSongs: null == recentSongs ? _self._recentSongs : recentSongs // ignore: cast_nullable_to_non_nullable
as List<Song>,jumpBackInSongs: null == jumpBackInSongs ? _self._jumpBackInSongs : jumpBackInSongs // ignore: cast_nullable_to_non_nullable
as List<Song>,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveSessionCopyWith<$Res>? get liveSession {
    if (_self.liveSession == null) {
    return null;
  }

  return $LiveSessionCopyWith<$Res>(_self.liveSession!, (value) {
    return _then(_self.copyWith(liveSession: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineUpCopyWith<$Res>? get liveSessionLineUp {
    if (_self.liveSessionLineUp == null) {
    return null;
  }

  return $LineUpCopyWith<$Res>(_self.liveSessionLineUp!, (value) {
    return _then(_self.copyWith(liveSessionLineUp: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LineUpCopyWith<$Res>? get featuredLineUp {
    if (_self.featuredLineUp == null) {
    return null;
  }

  return $LineUpCopyWith<$Res>(_self.featuredLineUp!, (value) {
    return _then(_self.copyWith(featuredLineUp: value));
  });
}
}

// dart format on
