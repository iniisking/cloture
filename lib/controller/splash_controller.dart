import 'package:cloture/services/auth_service.dart';
import 'package:flutter/foundation.dart';

enum SplashStatus { idle, loading, authenticated, unauthenticated }

class SplashController extends ChangeNotifier {
  SplashController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  SplashStatus _status = SplashStatus.idle;
  SplashStatus get status => _status;

  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _status = SplashStatus.loading;
    notifyListeners();

    // Keep the splash visible for a bit
    await Future.delayed(const Duration(seconds: 5));

    try {
      final user = _authService.currentUser;
      _status = user != null
          ? SplashStatus.authenticated
          : SplashStatus.unauthenticated;
    } catch (_) {
      _status = SplashStatus.unauthenticated;
    }

    notifyListeners();
  }
}
