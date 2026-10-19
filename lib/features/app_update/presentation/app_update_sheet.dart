import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/sheet_frame.dart';
import '../application/app_update_controller.dart';

/// What's new in the store and the one button that gets it. From "Check for
/// updates" on You, and from the launch check.
Future<void> showAppUpdateSheet(BuildContext context) =>
    showDaloySheet<void>(context: context, builder: (_) => const _AppUpdateSheet());

/// "Check for updates": checks, then shows the update or says why not.
Future<void> checkForUpdates(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final controller = ref.read(appUpdateProvider.notifier);
  final current = ref.read(appUpdateProvider).status;
  if (current != AppUpdateStatus.available && current != AppUpdateStatus.readyToInstall) await controller.check();
  if (!context.mounted) return;
  switch (ref.read(appUpdateProvider).status) {
    case AppUpdateStatus.available || AppUpdateStatus.readyToInstall || AppUpdateStatus.downloading:
      await showAppUpdateSheet(context);
    case AppUpdateStatus.upToDate:
      showDaloyToast(messenger, 'You’re on the latest version.');
    case AppUpdateStatus.failed:
      showDaloyToast(messenger, 'Couldn’t check for updates. Try again when you’re online.');
    case AppUpdateStatus.idle || AppUpdateStatus.checking:
      break;
  }
}

class _AppUpdateSheet extends ConsumerWidget {
  const _AppUpdateSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateProvider);
    final controller = ref.read(appUpdateProvider.notifier);
    final version = state.latestVersion == null ? 'A new version of Daloy' : 'Daloy ${state.latestVersion}';

    final (title, description, action) = switch (state.status) {
      AppUpdateStatus.readyToInstall => ('Update ready', 'Daloy restarts to finish updating.', 'Restart to update'),
      AppUpdateStatus.downloading => (
        'Downloading update',
        'Keep using Daloy — it’ll be ready to install in a moment.',
        'Downloading…',
      ),
      _ when state.required => (
        'Update required',
        'This version of Daloy can no longer sync. Update to keep your songs and line-ups up to date.',
        'Update now',
      ),
      _ => ('Update available', '$version is ready, with fixes and improvements.', 'Update'),
    };

    Future<void> run() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final navigator = Navigator.of(context);
      final opened = await controller.install();
      if (!opened) {
        showDaloyToast(messenger, 'Couldn’t open the store. Try again later.');
        return;
      }
      // A store listing opened elsewhere; Play's own flows keep the sheet.
      if (!state.viaPlay && navigator.mounted) navigator.pop();
    }

    return SheetFrame(
      title: title,
      description: description,
      children: [
        DaloyButton(
          label: action,
          size: ControlSize.lg,
          expand: true,
          loading: state.status == AppUpdateStatus.downloading,
          onPressed: () => unawaited(run()),
        ),
        if (!state.required) ...[
          const SizedBox(height: DaloySpace.s2),
          DaloyButton(
            label: 'Not now',
            variant: ButtonVariant.ghost,
            size: ControlSize.lg,
            expand: true,
            onPressed: () {
              unawaited(controller.dismiss());
              Navigator.of(context).pop();
            },
          ),
        ],
      ],
    );
  }
}

/// Under the app shell: the quiet launch check, at most daily, bringing up
/// [showAppUpdateSheet] once per new build (every launch when required).
class AppUpdateScope extends ConsumerStatefulWidget {
  const AppUpdateScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateScope> createState() => _AppUpdateScopeState();
}

class _AppUpdateScopeState extends ConsumerState<AppUpdateScope> {
  static const _delay = Duration(seconds: 4);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // After the first sync has had the network to itself.
    _timer = Timer(_delay, () => unawaited(_check()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final controller = ref.read(appUpdateProvider.notifier);
    await controller.check(automatic: true);
    if (!mounted || !controller.shouldPrompt()) return;
    await showAppUpdateSheet(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
