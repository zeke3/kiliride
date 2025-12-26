import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService with ChangeNotifier {
  bool _isOnline = false;
  final Connectivity _connectivity = Connectivity();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  bool get isOnline => _isOnline;

  Future<void> _checkInitialConnection() async {
    final status = await _connectivity.checkConnectivity();
    _updateConnectionStatus(status);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;
    notifyListeners();
  }

  // Method to wait for connectivity before performing network operations
  Future<bool> waitForConnectivity({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isOnline) return true;

    final completer = Completer<bool>();
    late VoidCallback listener;

    listener = () {
      if (_isOnline) {
        removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    };

    addListener(listener);

    // Set a timeout
    Timer(timeout, () {
      removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }
}
