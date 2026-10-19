import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import 'search_screen.dart';

/// The magnifier at the top right of every tab. Search is not a tab: it opens
/// from here as a page over the tabs. A tablet's tab screens leave it out:
/// Search is in the shell's tab bar and sidebar there.
class TopBarSearchButton extends StatelessWidget {
  const TopBarSearchButton({super.key});

  @override
  Widget build(BuildContext context) => TabletChrome.of(context) != null
      ? const SizedBox.shrink()
      : TopBarIconButton(icon: TablerIcons.search, tooltip: 'Search', onPressed: () => openSearch(context));
}
