import 'package:flutter/widgets.dart';

import '../../../shared/widgets/daloy_alert.dart';

/// "Go live?" before starting a line-up's live session from outside Perform.
/// Resolves to true only when the user chooses to go live.
Future<bool> confirmGoLive(BuildContext context, {required String title}) => confirmAlert(
  context,
  title: 'Go live with “$title”?',
  message: 'Your team can join and follow along as you play.',
  confirmLabel: 'Go live',
  cancelLabel: 'Not yet',
);
