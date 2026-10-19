import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/domain/account_deletion_preview.dart';

part 'account_deletion.g.dart';

/// What deleting the account would involve, asked of the server each time the
/// sheet opens so it never goes stale.
@riverpod
Future<AccountDeletionPreview> accountDeletionPreview(Ref ref) =>
    ref.watch(authServiceProvider).accountDeletionPreview();
