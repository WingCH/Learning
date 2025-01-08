class StackBaseDropdownController {
  bool _isOpen = false;
  final List<Function()> _listeners = [];

  bool get isOpen => _isOpen;

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void toggle() {
    _isOpen = !_isOpen;
    _notifyListeners();
  }

  void dispose() {
    _listeners.clear();
  }
}
