import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/analytics/analytics.dart';
import '../../core/prefs/device_prefs.dart';
import '../../core/theme/daloy_theme.dart';
import '../../shared/widgets/daloy_menu.dart';
import '../../shared/widgets/daloy_switch.dart';
import '../../shared/widgets/daloy_toast.dart';
import '../../shared/widgets/settings_group.dart';
import 'lock_authenticator.dart';

/// Profile → Privacy: lock the app behind the phone's own check, and how long
/// it may stay in the background before asking again.
class LockSettingsRows extends ConsumerWidget {
  const LockSettingsRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(devicePrefsControllerProvider);
    final controller = ref.read(devicePrefsControllerProvider.notifier);
    final authenticator = ref.read(lockAuthenticatorProvider);
    final c = context.colors;

    Future<void> toggle(bool on) async {
      if (!on) {
        controller.setLockEnabled(false);
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      final analytics = ref.read(analyticsProvider);
      if (!await authenticator.isSupported()) {
        showDaloyToast(messenger, 'Set up Face ID, a fingerprint or a passcode in Settings first.');
        return;
      }
      // Proves it works before it can lock you out.
      if (await authenticator.authenticate('Turn on the Daloy lock')) {
        controller.setLockEnabled(true);
        unawaited(analytics.track(AnalyticsEvent.biometricLockEnabled));
      }
    }

    return Column(
      children: [
        FutureBuilder<String>(
          future: authenticator.label(),
          builder: (context, snapshot) {
            final label = snapshot.data ?? 'Face ID';
            return SettingsRow(
              leading: const SettingsGlyph(TablerIcons.lock),
              title: 'Lock with $label',
              subtitle: 'Ask when the app opens',
              chevron: false,
              trailing: DaloySwitch(value: prefs.lockEnabled, onChanged: toggle, semanticLabel: 'Lock with $label'),
              onTap: () => toggle(!prefs.lockEnabled),
            );
          },
        ),
        if (prefs.lockEnabled)
          Builder(
            builder: (rowContext) => SettingsRow(
              leading: const SettingsGlyph(TablerIcons.clock),
              title: 'Ask again',
              subtitle: 'Never in the middle of a performance',
              trailing: Text(
                prefs.lockDelay.label.replaceFirst('After ', ''),
                style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
              ),
              onTap: () async {
                final picked = await showDaloyChoiceMenu<LockDelay>(
                  rowContext,
                  title: 'Ask again',
                  options: [for (final d in LockDelay.values) (d, d.label)],
                  current: prefs.lockDelay,
                );
                if (picked != null) controller.setLockDelay(picked);
              },
            ),
          ),
      ],
    );
  }
}
