import 'dart:async';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

import 'productivity_engine_service.dart';

class AppUsageService {

  static final AppUsageService _instance =
      AppUsageService._internal();

  factory AppUsageService() => _instance;

  AppUsageService._internal();

  /// =====================================
  /// CATEGORY DATA
  /// =====================================

  final Map<String, Duration>
      _categoryUsageData = {

    'Browser': Duration.zero,

    'Entertainment': Duration.zero,

    'Development': Duration.zero,

    'Communication': Duration.zero,

    'Productivity': Duration.zero,
  };

  Timer? _trackingTimer;

  String _currentCategory = "";

  DateTime? _lastSwitchTime;

  /// =====================================
  /// APP CATEGORY MAP
  /// =====================================

  static const Map<String, String>
      _appCategories = {

    /// BROWSER
    'chrome': 'Browser',
    'firefox': 'Browser',
    'edge': 'Browser',
    'opera': 'Browser',
    'brave': 'Browser',

    /// ENTERTAINMENT
    'youtube': 'Entertainment',
    'netflix': 'Entertainment',
    'spotify': 'Entertainment',
    'hotstar': 'Entertainment',

    /// DEVELOPMENT
    'code': 'Development',
    'windsurf': 'Development',
    'visual studio': 'Development',
    'android studio': 'Development',
    'cursor': 'Development',

    /// COMMUNICATION
    'slack': 'Communication',
    'teams': 'Communication',
    'zoom': 'Communication',
    'discord': 'Communication',
    'telegram': 'Communication',

    /// PRODUCTIVITY
    'excel': 'Productivity',
    'word': 'Productivity',
    'powerpoint': 'Productivity',
    'outlook': 'Productivity',
    'notion': 'Productivity',
  };

  /// =====================================
  /// START TRACKING
  /// =====================================

  void startTracking() {

    if (_trackingTimer?.isActive ?? false) {

      print(
        "Tracking already running",
      );

      return;
    }

    print(
      "APP USAGE TRACKING STARTED",
    );

    _lastSwitchTime =
        DateTime.now();

    _trackingTimer = Timer.periodic(

      const Duration(seconds: 1),

      (_) {

        final activeWindow =
            getActiveWindowTitle();

        if (activeWindow.isEmpty) {
          return;
        }

        final category =
            getAppCategory(
          activeWindow,
        );

        /// IGNORE UNKNOWN
        if (category == 'Other') {
          return;
        }

        /// =====================================
        /// CHECK IDLE
        /// =====================================

        final engine =
            ProductivityEngineService();

        if (engine.isIdle) {

          print(
            "USER IDLE - PAUSE TRACKING",
          );

          return;
        }

        final now = DateTime.now();

        /// =====================================
        /// FIRST CATEGORY
        /// =====================================

        if (_currentCategory
            .isEmpty) {

          _currentCategory =
              category;

          _lastSwitchTime =
              now;

          print(
            "FIRST CATEGORY => "
            "$category",
          );

          return;
        }

        /// =====================================
        /// SAME CATEGORY
        /// =====================================

        if (_currentCategory ==
            category) {

          _categoryUsageData.update(

            category,

            (value) =>
                value +
                const Duration(
                  seconds: 1,
                ),
          );
        }

        /// =====================================
        /// CATEGORY SWITCH
        /// =====================================

        else {

          /// SAVE LAST SECOND
          _categoryUsageData.update(

            _currentCategory,

            (value) =>
                value +
                const Duration(
                  seconds: 1,
                ),
          );

          print(
            "CATEGORY SWITCH => "
            "$_currentCategory -> "
            "$category",
          );

          _currentCategory =
              category;

          _lastSwitchTime =
              now;
        }

        print(
          "CATEGORY USAGE => "
          "$_categoryUsageData",
        );
      },
    );
  }

  /// =====================================
  /// STOP TRACKING
  /// =====================================

  void stopTracking() {

    print(
      "STOP APP TRACKING",
    );

    _trackingTimer?.cancel();

    _trackingTimer = null;
  }

  /// =====================================
  /// ACTIVE WINDOW
  /// =====================================

  String getActiveWindowTitle() {

    if (!Platform.isWindows) {
      return "";
    }

    final hwnd =
        GetForegroundWindow();

    final length =
        GetWindowTextLength(hwnd);

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

  /// =====================================
  /// GET CATEGORY
  /// =====================================

  String getAppCategory(
      String appName) {

    for (final entry
        in _appCategories.entries) {

      if (appName.contains(
        entry.key,
      )) {

        return entry.value;
      }
    }

    return 'Other';
  }

  /// =====================================
  /// GET USAGE DATA
  /// =====================================

  Map<String, Duration>
      getUsageData() {

    return Map.from(
      _categoryUsageData,
    );
  }

  /// =====================================
  /// GET TOP APPS
  /// =====================================

  List<AppUsageInfo>
      getTopApps({
    int limit = 10,
  }) {

    final sortedApps =
        _categoryUsageData.entries
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

      final category =
          entry.key;

      final timeSpent =
          entry.value;

      return AppUsageInfo(

        appName: category,

        timeSpent: timeSpent,

        category: category,

        icon: getCategoryIcon(
          category,
        ),

        color: getAppColor(
          category,
        ),
      );

    }).toList();
  }

  /// =====================================
  /// FORMAT DURATION
  /// =====================================
String formatDuration(
    Duration duration) {

  final hours =
      duration.inHours;

  final minutes =
      duration.inMinutes % 60;

  final seconds =
      duration.inSeconds % 60;

  /// HOURS
  if (hours > 0) {

    return
        "${hours}h ${minutes}m";
  }

  /// MINUTES
  if (minutes > 0) {

    return
        "${minutes}m";
  }

  /// SECONDS
  return
      "${seconds}s";
}
  /// =====================================
  /// ICONS
  /// =====================================

  IconData getCategoryIcon(
      String category) {

    switch (category) {

      case 'Browser':
        return Icons.language;

      case 'Entertainment':
        return Icons.ondemand_video;

      case 'Development':
        return Icons.code;

      case 'Communication':
        return Icons.chat;

      case 'Productivity':
        return Icons.work;

      default:
        return Icons.apps;
    }
  }

  /// =====================================
  /// COLORS
  /// =====================================

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

  /// =====================================
  /// CLEAR
  /// =====================================

  void clearData() {

    _categoryUsageData.updateAll(

      (key, value) =>
          Duration.zero,
    );

    _trackingTimer?.cancel();

    _trackingTimer = null;

    _currentCategory = "";

    _lastSwitchTime = null;

    print(
      "APP USAGE CLEARED",
    );
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