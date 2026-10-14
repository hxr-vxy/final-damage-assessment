import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Mock admin authentication.
///
/// PROTOTYPE ONLY: credentials are hard-coded. In a real app, replace [login]
/// with a call to your backend and never ship passwords inside the app.
class AuthService extends ChangeNotifier {
  AuthService(this._storage) : _loggedIn = _storage.isAdminLoggedIn;

  final StorageService _storage;
  bool _loggedIn;

  static const _mockUsername = 'harvey';
  static const _mockPassword = 'harvey14';

  bool get isLoggedIn => _loggedIn;
  String get username => _mockUsername;

  Future<bool> login(String username, String password) async {
    // Simulate a short network delay.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final ok = username.trim().toLowerCase() == _mockUsername &&
        password == _mockPassword;
    if (ok) {
      _loggedIn = true;
      await _storage.setAdminLoggedIn(true);
      notifyListeners();
    }
    return ok;
  }

  Future<void> logout() async {
    _loggedIn = false;
    await _storage.setAdminLoggedIn(false);
    notifyListeners();
  }
}
