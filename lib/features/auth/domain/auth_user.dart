import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// `UserData` from the API.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    required String email,
    int? lastWorkspaceId,
    @Default(false) bool isSuperadmin,
    String? preferredView,
    String? chordNotation,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}

/// `AuthResultData` — `{ user, token }` from login/register.
@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({required AuthUser user, required String token}) = _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);
}
