import 'package:flutter/widgets.dart';

import 'daloy_alert.dart';

/// "Discard changes?" before leaving an editor with unsaved edits.
/// Resolves to true only when the user chooses to discard.
Future<bool> confirmDiscardChanges(BuildContext context) => confirmAlert(
  context,
  title: 'Discard changes?',
  message: "Your edits haven't been saved.",
  confirmLabel: 'Discard',
  cancelLabel: 'Keep editing',
  destructive: true,
);
