import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:courency_converter/core/errors/app_exception.dart';
import '../services/connectivity_service.dart';

class ConnectivityHelper {
  final ConnectivityService _connectivityService;

  bool _lastKnownStatus = true;
  DateTime? _lastStatusCheck;
  final Duration _statusCacheDuration = const Duration(seconds: 10);

  ConnectivityHelper(this._connectivityService);

  Future<bool> checkConnection({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastStatusCheck != null &&
        DateTime.now().difference(_lastStatusCheck!) < _statusCacheDuration) {
      return _lastKnownStatus;
    }

    try {
      final List<ConnectivityResult> results =
          await _connectivityService.checkConnectivity();
      _lastKnownStatus = _isConnected(results);
      _lastStatusCheck = DateTime.now();
      return _lastKnownStatus;
    } catch (e) {
      return false;
    }
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final DateTime startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final bool isConnected = await checkConnection(forceRefresh: true);
        if (isConnected) return true;
        await Future.delayed(checkInterval);
      } catch (e) {
        await Future.delayed(checkInterval);
      }
    }

    throw NetworkException(
      'No internet connection after ${timeout.inSeconds} seconds',
    );
  }

  Future<bool> shouldUseCachedData({
    required Duration maxCacheAge,
    required DateTime? lastUpdate,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) return false;

    final bool isConnected = await checkConnection();
    if (!isConnected) return true;
    if (lastUpdate == null) return false;

    final bool isCacheFresh =
        DateTime.now().difference(lastUpdate) < maxCacheAge;
    return isCacheFresh;
  }

  Duration getOptimalCacheDuration(String fromCurrency, String toCurrency) {
    const volatilePairs = [
      ['USD', 'PKR'],
      ['USD', 'ARS'],
      ['EUR', 'TRY'],
    ];

    const stablePairs = [
      ['USD', 'EUR'],
      ['USD', 'GBP'],
      ['USD', 'CAD'],
    ];

    for (final pair in volatilePairs) {
      if ((pair[0] == fromCurrency && pair[1] == toCurrency) ||
          (pair[0] == toCurrency && pair[1] == fromCurrency)) {
        return const Duration(minutes: 5);
      }
    }

    for (final pair in stablePairs) {
      if ((pair[0] == fromCurrency && pair[1] == toCurrency) ||
          (pair[0] == toCurrency && pair[1] == fromCurrency)) {
        return const Duration(minutes: 15);
      }
    }

    return const Duration(minutes: 10);
  }

  Future<T> executeWithConnectivityAwareness<T>({
    required Future<T> Function() onlineAction,
    required Future<T> Function() offlineFallback,
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        final bool isConnected = await checkConnection(forceRefresh: true);

        if (isConnected) {
          return await onlineAction();
        } else {
          return await offlineFallback();
        }
      } on NetworkException catch (e) {
        attempt++;

        if (attempt > maxRetries) {
          try {
            return await offlineFallback();
          } catch (fallbackError) {
            throw NetworkException(
              'Online action failed and no offline data available: ${e.message}',
            );
          }
        }

        await Future.delayed(retryDelay * attempt);
      } catch (e) {
        rethrow;
      }
    }

    throw NetworkException('All retry attempts failed');
  }

  Stream<ConnectionStatus> get connectionStatusStream {
    return _connectivityService.onConnectivityChanged.asyncMap(
      (List<ConnectivityResult> results) async {
            return ConnectionStatus(
              isConnected: _isConnected(results),
              timestamp: DateTime.now(),
              connectionType: await _getConnectionType(),
            );
          }
          as FutureOr<ConnectionStatus> Function(bool event),
    );
  }

  Future<String> _getConnectionType() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivityService.checkConnectivity();

      if (results.contains(ConnectivityResult.wifi)) return 'wifi';
      if (results.contains(ConnectivityResult.mobile)) return 'mobile';
      if (results.contains(ConnectivityResult.ethernet)) return 'ethernet';
      if (results.contains(ConnectivityResult.vpn)) return 'vpn';
      if (results.contains(ConnectivityResult.bluetooth)) return 'bluetooth';

      return 'other';
    } catch (e) {
      return 'unknown';
    }
  }

  Future<bool> isConnectionSuitableForLargeData() async {
    final bool isConnected = await checkConnection();
    if (!isConnected) return false;

    final String connectionType = await _getConnectionType();
    if (connectionType == 'mobile') return false;

    return true;
  }
}

class ConnectionStatus {
  final bool isConnected;
  final DateTime timestamp;
  final String connectionType;

  ConnectionStatus({
    required this.isConnected,
    required this.timestamp,
    required this.connectionType,
  });

  bool get isWifi => connectionType == 'wifi';
  bool get isMobile => connectionType == 'mobile';

  @override
  String toString() {
    return 'ConnectionStatus{isConnected: $isConnected, type: $connectionType, timestamp: $timestamp}';
  }
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}
