import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import '../../core/utils/formatters.dart';

/// "Updated 2 hours ago by Ana" — a quiet line at the foot of a song or
/// line-up. Draws nothing until the server has said when.
class UpdatedFootnote extends StatelessWidget {
  const UpdatedFootnote({super.key, required this.at, this.byName, this.isMe = false});

  final DateTime? at;
  final String? byName;

  /// The signed-in user made the change: "by you".
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final at = this.at;
    if (at == null) return const SizedBox.shrink();
    return Text(
      formatUpdated(at, by: byName, isMe: isMe),
      textAlign: TextAlign.center,
      style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
    );
  }
}
