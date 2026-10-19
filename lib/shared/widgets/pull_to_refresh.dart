import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A tab screen's scroll view with pull-to-refresh the way each platform
/// does it: iOS's elastic spinner that scrolls with the content, Android's
/// Material indicator on top. Both give a haptic tick when the pull commits.
class PullToRefreshScrollView extends StatelessWidget {
  const PullToRefreshScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.controller,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  /// Null while offline — there's nothing to pull from.
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  Future<void> _refresh() async {
    await HapticFeedback.mediumImpact();
    await onRefresh!();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      keyboardDismissBehavior: keyboardDismissBehavior,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        if (onRefresh != null) CupertinoSliverRefreshControl(onRefresh: _refresh),
        ...slivers,
      ],
    );
  }
}
