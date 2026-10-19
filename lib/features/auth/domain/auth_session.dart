import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'auth_session.freezed.dart';

/// The signed-in state the app runs on. `null` session = signed out.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({required String token, required AuthUser user, int? workspaceId}) = _AuthSession;
}
