import 'dart:async';
import 'package:cloture/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isInitialized = false;

  ConnectivityService() {
    _connectionController = StreamController<bool>.broadcast();
    _init();
  }

  void _init() {
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final isConnected = _hasConnection(results);
          _connectionController?.add(isConnected);
        },
        onError: (error) {
          AppLogger.error('Connectivity stream error', error);
          // Assume connected if we can't determine status
          _connectionController?.add(true);
        },
      );
      _isInitialized = true;
    } catch (e) {
      AppLogger.error('Error initializing connectivity service', e);
      // If initialization fails, assume connected (fail open)
      _connectionController?.add(true);
      _isInitialized = false;
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Check current connectivity status
  Future<bool> isConnected() async {
    if (!_isInitialized) {
      // If service isn't initialized, assume connected (fail open)
      return true;
    }
    
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasConnection(results);
    } catch (e) {
      AppLogger.error('Error checking connectivity', e);
      // Fail open - assume connected if we can't determine
      return true;
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    if (_connectionController == null || !_isInitialized) {
      // Return a stream that always emits true if service isn't initialized
      return Stream<bool>.value(true).asBroadcastStream();
    }
    return _connectionController!.stream;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController?.close();
    _isInitialized = false;
  }
}
