import 'package:flutter/material.dart';

import 'storage_service.dart';

/// Holds the light / dark / system theme choice and remembers it.
class ThemeService extends ChangeNotifier {
  ThemeService(this._storage) : _mode = _storage.loadThemeMode();

  final StorageService _storage;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode);
  }

  /// Quick toggle used by the icon button in app bars.
  Future<void> toggle(Brightness current) =>
      setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
