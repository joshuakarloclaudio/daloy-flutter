import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace.freezed.dart';
part 'workspace.g.dart';

/// `WorkspaceMembershipData` from the API.
@freezed
abstract class Workspace with _$Workspace {
  const factory Workspace({required int id, required String name, required String role, @Default(true) bool isMember}) =
      _Workspace;

  factory Workspace.fromJson(Map<String, dynamic> json) => _$WorkspaceFromJson(json);
}
