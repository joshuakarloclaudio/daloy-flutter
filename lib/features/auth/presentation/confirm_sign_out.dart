import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../application/session_controller.dart';

/// "Sign out?" first, since signing out empties this device: its downloaded
/// library always, and — said plainly — any changes that haven't synced.
Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final pending = await ref.read(appDatabaseProvider).pendingChangeCount();
  if (!context.mounted) return;
  final confirmed = await confirmDestructive(
    context,
    title: 'Sign out?',
    message: pending == 0
        ? 'Songs and line-ups saved on this device are removed until you sign back in.'
        : '${changesLabel(pending)} made on this device ${pending == 1 ? 'hasn’t' : 'haven’t'} synced yet '
              'and will be lost.',
    confirmLabel: 'Sign out',
  );
  if (confirmed) await ref.read(sessionControllerProvider.notifier).signOut();
}
