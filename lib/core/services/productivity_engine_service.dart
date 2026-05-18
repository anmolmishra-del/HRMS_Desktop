import 'dart:async';

import 'package:hrms_desktop/core/utils/shared_pref.dart';

class ProductivityEngineService {

  static final ProductivityEngineService _instance =
      ProductivityEngineService._internal();

  factory ProductivityEngineService() =>
      _instance;

  ProductivityEngineService._internal();

  Timer? _timer;

  /// =====================================
  /// GLOBAL COUNTERS
  /// =====================================

  int totalKeys = 0;

  int totalClicks = 0;

  int totalMoves = 0;

  int activeSeconds = 0;

  int idleSeconds = 0;

  bool isIdle = false;

  double productivity = 65;

  DateTime _lastActivity =
      DateTime.now();

  /// =====================================
  /// ACTIVITY WINDOW
  /// =====================================

  int _windowKeys = 0;

  int _windowClicks = 0;

  int _windowMoves = 0;

  int _windowSeconds = 0;

  /// =====================================
  /// STORAGE KEYS
  /// =====================================

  static const String _keyLastDate = 'productivity_last_date';
  static const String _keyActiveSeconds = 'productivity_active_seconds';
  static const String _keyIdleSeconds = 'productivity_idle_seconds';
  static const String _keyTotalKeys = 'productivity_total_keys';
  static const String _keyTotalClicks = 'productivity_total_clicks';
  static const String _keyTotalMoves = 'productivity_total_moves';
  static const String _keyProductivity = 'productivity_score';

  /// =====================================
  /// LOAD DATA
  /// =====================================

  Future<void> _loadData() async {
    final pref = SharedPref();

    final lastDateStr = await pref.getString(_keyLastDate);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastDateStr == null || lastDateStr != todayStr) {
      await _resetData();
      await pref.saveString(_keyLastDate, todayStr);
    } else {
      activeSeconds = await pref.getInt(_keyActiveSeconds) ?? 0;
      idleSeconds = await pref.getInt(_keyIdleSeconds) ?? 0;
      totalKeys = await pref.getInt(_keyTotalKeys) ?? 0;
      totalClicks = await pref.getInt(_keyTotalClicks) ?? 0;
      totalMoves = await pref.getInt(_keyTotalMoves) ?? 0;
      productivity = await pref.getDouble(_keyProductivity) ?? 65.0;
    }
  }

  /// =====================================
  /// SAVE DATA
  /// =====================================

  Future<void> _saveData() async {
    final pref = SharedPref();
    await pref.saveInt(_keyActiveSeconds, activeSeconds);
    await pref.saveInt(_keyIdleSeconds, idleSeconds);
    await pref.saveInt(_keyTotalKeys, totalKeys);
    await pref.saveInt(_keyTotalClicks, totalClicks);
    await pref.saveInt(_keyTotalMoves, totalMoves);
    await pref.saveDouble(_keyProductivity, productivity);
  }

  /// =====================================
  /// RESET DATA
  /// =====================================

  Future<void> _resetData() async {
    final pref = SharedPref();
    await pref.remove(_keyActiveSeconds);
    await pref.remove(_keyIdleSeconds);
    await pref.remove(_keyTotalKeys);
    await pref.remove(_keyTotalClicks);
    await pref.remove(_keyTotalMoves);
    await pref.remove(_keyProductivity);
    reset();
  }

  /// =====================================
  /// START TRACKING
  /// =====================================

  Future<void> startTracking() async {
    await _loadData();

    stopTracking();

    _lastActivity = DateTime.now();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {

        final now = DateTime.now();

        final idleDuration =
            now.difference(
          _lastActivity,
        );

        /// =====================================
        /// IDLE DETECTION
        /// =====================================

        final currentlyIdle =
            idleDuration.inSeconds >= 15;

        isIdle = currentlyIdle;

        /// =====================================
        /// ACTIVE SESSION
        /// =====================================
if (!currentlyIdle) {

  /// REAL ACTIVITY DETECTION
  final hasRealActivity =

      _windowKeys > 0 ||

      _windowClicks > 0 ||

      _windowMoves > 3;

  /// ONLY COUNT ACTIVE WORK
  if (hasRealActivity) {

    activeSeconds++;
  }

  /// SMALL PASSIVE FOCUS
  else {

    /// READING / WATCHING / THINKING
    if (activeSeconds > 0) {

      activeSeconds += 0;
    }
  }
}
        /// =====================================
        /// IDLE SESSION
        /// =====================================

        else {

          idleSeconds++;
        }

        /// =====================================
        /// PRODUCTIVITY UPDATE
        /// =====================================

        _windowSeconds++;

        if (_windowSeconds >= 10) {

          _calculateProductivity();

          /// SAVE DATA PERIODICALLY
          _saveData();

          /// RESET WINDOW
          _windowSeconds = 0;

          _windowKeys = 0;

          _windowClicks = 0;

          _windowMoves = 0;
        }

        print(
          "ACTIVE => "
          "$activeSeconds",
        );

        print(
          "IDLE => "
          "$idleSeconds",
        );

        print(
          "PRODUCTIVITY => "
          "$productivity",
        );

        print(
          "FOCUS => "
          "$focusTime",
        );

        print(
          "IDLE TIME => "
          "$idleTime",
        );
      },
    );
  }

  /// =====================================
  /// STOP
  /// =====================================

  void stopTracking() {

    _timer?.cancel();

    _timer = null;
  }

  /// =====================================
  /// KEYBOARD
  /// =====================================

  void onKeyboardActivity() {

    totalKeys++;

    _windowKeys++;

    _lastActivity = DateTime.now();
  }

  /// =====================================
  /// MOUSE CLICK
  /// =====================================

  void onMouseClick() {

    totalClicks++;

    _windowClicks++;

    _lastActivity = DateTime.now();
  }

  /// =====================================
  /// MOUSE MOVE
  /// =====================================

  void onMouseMove() {

    totalMoves++;

    _windowMoves++;

    _lastActivity = DateTime.now();
  }

  /// =====================================
  /// ENTERPRISE PRODUCTIVITY
  /// =====================================

  void _calculateProductivity() {

    /// KEYBOARD ACTIVITY
    final keyboardActivity =

        (_windowKeys / 40)
            .clamp(0.0, 1.0);

    /// CLICK ACTIVITY
    final clickActivity =

        (_windowClicks / 20)
            .clamp(0.0, 1.0);

    /// MOVE ACTIVITY
    final moveActivity =

        (_windowMoves / 120)
            .clamp(0.0, 1.0);

    /// SESSION SCORE
    double sessionScore =

        (keyboardActivity * 50) +

        (clickActivity * 30) +

        (moveActivity * 20);

    /// IDLE PENALTY
    if (isIdle) {

      sessionScore *= 0.4;
    }

    /// ENTERPRISE SMOOTHING
    productivity =

        (productivity * 0.94) +

        (sessionScore * 0.06);

    /// LONG ACTIVE BONUS
    if (!isIdle &&
        activeSeconds > 300) {

      productivity += 0.1;
    }

    /// LONG IDLE PENALTY
    if (idleSeconds > 180) {

      productivity -= 0.2;
    }

    /// SAFE LIMITS
    productivity =
        productivity.clamp(
      25,
      98,
    );

    /// ROUND VALUE
    productivity =
        double.parse(
      productivity.toStringAsFixed(1),
    );
  }

  /// =====================================
  /// FOCUS TIME
  /// =====================================
  
String get focusTime {

  final stableSeconds =

      (activeSeconds * 0.88)
          .round();

  final h =
      stableSeconds ~/ 3600;

  final m =
      (stableSeconds % 3600) ~/ 60;

  if (h > 0) {

    return "${h}h ${m}m";
  }

  return "${m}m";
}

  /// =====================================
  /// IDLE TIME
  /// =====================================
String get idleTime {

  final stableIdle =

      (idleSeconds * 0.92)
          .round();

  final h =
      stableIdle ~/ 3600;

  final m =
      (stableIdle % 3600) ~/ 60;

  if (h > 0) {

    return "${h}h ${m}m";
  }

  return "${m}m";
}
  /// =====================================
  /// RESET
  /// =====================================

  void reset() {

    totalKeys = 0;

    totalClicks = 0;

    totalMoves = 0;

    activeSeconds = 0;

    idleSeconds = 0;

    productivity = 65;

    isIdle = false;

    _windowKeys = 0;

    _windowClicks = 0;

    _windowMoves = 0;

    _windowSeconds = 0;
  }
}