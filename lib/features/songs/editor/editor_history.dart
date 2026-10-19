/// A document and cursor at one moment.
class EditorSnapshot {
  const EditorSnapshot(this.content, this.cursor);

  final String content;
  final int cursor;

  @override
  bool operator ==(Object other) => other is EditorSnapshot && other.content == content && other.cursor == cursor;

  @override
  int get hashCode => Object.hash(content, cursor);
}

/// Undo/redo over snapshots (web `useChordEditorHistory`): a commit pushes
/// the previous state and clears redo; at most [maxHistory] steps back.
class EditorHistory {
  EditorHistory(this._present);

  static const maxHistory = 100;

  final _undo = <EditorSnapshot>[];
  final _redo = <EditorSnapshot>[];
  EditorSnapshot _present;

  EditorSnapshot get present => _present;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void commit(EditorSnapshot next) {
    if (next == _present) return;
    _undo.add(_present);
    if (_undo.length > maxHistory) _undo.removeAt(0);
    _redo.clear();
    _present = next;
  }

  EditorSnapshot? undo() {
    if (_undo.isEmpty) return null;
    _redo.add(_present);
    return _present = _undo.removeLast();
  }

  EditorSnapshot? redo() {
    if (_redo.isEmpty) return null;
    _undo.add(_present);
    return _present = _redo.removeLast();
  }
}
