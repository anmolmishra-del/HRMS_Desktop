import 'dart:async';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class AppUsageService {

  static final AppUsageService _instance =
      AppUsageService._internal();

  factory AppUsageService() => _instance;

  AppUsageService._internal();

  final Map<String, Duration>
      _appUsageData = {};

  Timer? _trackingTimer;

  String _currentApp = "";

  DateTime? _lastSwitchTime;

  // =====================================
  // APP CATEGORY MAP
  // =====================================

  static const Map<String, String>
      _appCategories = {

    'chrome': 'Browser',
    'firefox': 'Browser',
    'edge': 'Browser',

    'youtube': 'Entertainment',
    'netflix': 'Entertainment',
    'spotify': 'Entertainment',

    'code': 'Development',
    'windsurf': 'Development',
    'visual studio':
        'Development',

    'slack': 'Communication',
    'teams': 'Communication',
    'zoom': 'Communication',

    'excel': 'Productivity',
    'word': 'Productivity',
  };

  // =====================================
  // START TRACKING
  // =====================================

  void startTracking() {

    if (_trackingTimer
            ?.isActive ??
        false) {
      return;
    }

    _lastSwitchTime =
        DateTime.now();

    _trackingTimer =
        Timer.periodic(

      const Duration(
          seconds: 1),

      (_) {

        final activeWindow =
            getActiveWindowTitle();

        if (activeWindow
            .isEmpty) {
          return;
        }

        final now =
            DateTime.now();

        if (_currentApp
                .isNotEmpty &&
            _lastSwitchTime !=
                null) {

          final duration =
              now.difference(
            _lastSwitchTime!,
          );

          _appUsageData.update(

            _currentApp,

            (value) =>
                value +
                duration,

            ifAbsent: () =>
                duration,
          );
        }

        _currentApp =
            activeWindow;

        _lastSwitchTime =
            now;

        print(
          "APP USAGE => $_appUsageData",
        );
      },
    );
  }

  // =====================================
  // STOP TRACKING
  // =====================================

  void stopTracking() {

    _trackingTimer?.cancel();
  }

  // =====================================
  // ACTIVE WINDOW
  // =====================================

  String getActiveWindowTitle() {

    if (!Platform.isWindows) {
      return "";
    }

    final hwnd =
        GetForegroundWindow();

    final length =
        GetWindowTextLength(
      hwnd,
    );

    final buffer =
        wsalloc(length + 1);

    GetWindowText(
      hwnd,
      buffer,
      length + 1,
    );

    final title =
        buffer.toDartString();

    calloc.free(buffer);

    return title
        .toLowerCase()
        .trim();
  }

  // =====================================
  // GET USAGE DATA
  // =====================================

  Map<String, Duration>
      getUsageData() {

    return Map.from(
      _appUsageData,
    );
  }

  // =====================================
  // GET TOP APPS
  // =====================================

  List<AppUsageInfo>
      getTopApps({
    int limit = 10,
  }) {

    final sortedApps =
        _appUsageData.entries
            .toList()

          ..sort(
            (a, b) => b.value
                .compareTo(
              a.value,
            ),
          );

    return sortedApps
        .take(limit)
        .map((entry) {

      final appName =
          entry.key;

      final timeSpent =
          entry.value;

      final category =
          getAppCategory(
        appName,
      );

      return AppUsageInfo(
        appName: appName,
        timeSpent: timeSpent,
        category: category,
        icon: getAppIcon(
          appName,
        ),
        color: getAppColor(
          category,
        ),
      );

    }).toList();
  }

  // =====================================
  // CATEGORY
  // =====================================

  String getAppCategory(
      String appName) {

    return _appCategories
            .entries

            .where(
              (entry) =>
                  appName.contains(
                entry.key,
              ),
            )

            .map(
              (entry) =>
                  entry.value,
            )

            .firstOrNull ??

        'Other';
  }

  // =====================================
  // ICON
  // =====================================

  IconData getAppIcon(
      String appName) {

    if (appName.contains(
          'chrome',
        ) ||
        appName.contains(
          'firefox',
        ) ||
        appName.contains(
          'edge',
        )) {

      return Icons.language;
    }

    else if (appName.contains(
          'youtube',
        ) ||
        appName.contains(
          'netflix',
        )) {

      return Icons.play_circle;
    }

    else if (appName.contains(
          'code',
        ) ||
        appName.contains(
          'windsurf',
        ) ||
        appName.contains(
          'visual studio',
        )) {

      return Icons.code;
    }

    else if (appName.contains(
          'slack',
        ) ||
        appName.contains(
          'teams',
        ) ||
        appName.contains(
          'zoom',
        )) {

      return Icons.chat;
    }

    else if (appName.contains(
          'excel',
        ) ||
        appName.contains(
          'word',
        )) {

      return Icons.table_chart;
    }

    return Icons.apps;
  }

  // =====================================
  // COLOR
  // =====================================

  Color getAppColor(
      String category) {

    switch (category) {

      case 'Browser':
        return Colors.blue;

      case 'Entertainment':
        return Colors.red;

      case 'Development':
        return Colors.indigo;

      case 'Communication':
        return Colors.purple;

      case 'Productivity':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  // =====================================
  // CLEAR
  // =====================================

  void clearData() {

    _appUsageData.clear();

    _trackingTimer
        ?.cancel();
  }
}

class AppUsageInfo {

  final String appName;

  final Duration timeSpent;

  final String category;

  final IconData icon;

  final Color color;

  const AppUsageInfo({

    required this.appName,

    required this.timeSpent,

    required this.category,

    required this.icon,

    required this.color,
  });
}