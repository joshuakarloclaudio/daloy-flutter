import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_deletion_preview.freezed.dart';
part 'account_deletion_preview.g.dart';

/// `AccountDeletionPreviewData` — what deleting the account involves.
@freezed
abstract class AccountDeletionPreview with _$AccountDeletionPreview {
  const factory AccountDeletionPreview({
    required bool requiresPassword,
    required bool canDelete,

    /// Workspaces where you're the only admin and others still depend on you.
    @Default([]) List<DeletionWorkspace> blocking,

    /// Workspaces only you belong to; they go with the account.
    @Default([]) List<DeletionWorkspace> willDelete,
  }) = _AccountDeletionPreview;

  factory AccountDeletionPreview.fromJson(Map<String, dynamic> json) => _$AccountDeletionPreviewFromJson(json);
}

@freezed
abstract class DeletionWorkspace with _$DeletionWorkspace {
  const factory DeletionWorkspace({required int id, required String name}) = _DeletionWorkspace;

  factory DeletionWorkspace.fromJson(Map<String, dynamic> json) => _$DeletionWorkspaceFromJson(json);
}
