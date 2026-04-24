import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<dynamic>? _subscription;
  bool _isOnline = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  Future<void> initialize() async {
    try {
      await _checkConnectivity();
    } catch (_) {
      // Mantem estado atual e segue para nao impedir o carregamento da UI.
    }

    try {
      _subscription = _connectivity.onConnectivityChanged.listen((result) {
        _updateConnectivityStatus(result);
      });
    } catch (_) {
      // Sem stream de conectividade; evita crash e mantem app funcional.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(result);
  }

  void _updateConnectivityStatus(dynamic result) {
    bool wasOnline = _isOnline;

    if (result is ConnectivityResult) {
      _isOnline = result != ConnectivityResult.none;
    } else if (result is List<ConnectivityResult>) {
      _isOnline = result.any((r) => r != ConnectivityResult.none);
    }

    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }
}
