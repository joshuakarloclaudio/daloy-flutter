import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Flutter keeps a SnackBar with an action on screen until it's tapped
/// (`persist` defaults to `action != null`), so an Undo toast would never go
/// away on its own. Every toast in the app passes `persist: false`.
void main() {
  test('every SnackBar dismisses itself', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in RegExp(r'\bSnackBar\(').allMatches(source)) {
        if (!_arguments(source, match.end).contains(RegExp(r'^\s*persist:\s*false', multiLine: true))) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
          offenders.add('${file.path}:$line');
        }
      }
    }
    expect(offenders, isEmpty, reason: 'Pass persist: false to these SnackBars');
  });
}

/// The text between the `(` ending at [open] and its matching `)`.
String _arguments(String source, int open) {
  var depth = 1;
  for (var i = open; i < source.length; i++) {
    final c = source[i];
    if (c == '(') depth++;
    if (c == ')' && --depth == 0) return source.substring(open, i);
  }
  return source.substring(open);
}
