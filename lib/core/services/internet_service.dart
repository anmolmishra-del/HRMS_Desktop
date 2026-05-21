import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetService {
  static final ValueNotifier<bool> isConnected =
      ValueNotifier(true);

  static StreamSubscription? _subscription;

  static Future<void> initialize() async {
    await _checkInternet();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((_) async {
      await _checkInternet();
    });
  }

  static Future<void> _checkInternet() async {
    try {
      final connectivityResult =
          await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        isConnected.value = false;
        return;
      }

      final result = await InternetAddress.lookup(
        'google.com',
      );

      isConnected.value =
          result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty;
    } catch (e) {
      isConnected.value = false;
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
