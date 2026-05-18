import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';
import 'package:hrms_desktop/core/services/productivity_engine_service.dart';

import 'productivity_state.dart';

class ProductivityCubit
    extends Cubit<ProductivityState> {

  ProductivityCubit()
      : super(
          const ProductivityState(),
        );

  Timer? _timer;

  /// =====================================
  /// START LIVE TRACKING
  /// =====================================

  Future<void> startTracking() async {
    final engine = ProductivityEngineService();
    await engine.startTracking();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updateState();
      },
    );
  }


void _updateState() {

  final engine =
      ProductivityEngineService();

  final appUsage =
      AppUsageService()
          .getTopApps();

  emit(
    state.copyWith(

      productivityPercent:
          engine.productivity,

     focusTime:
    engine.focusTime,

idleTime:
    engine.idleTime,

      totalKeys:
          engine.totalKeys,

      totalClicks:
          engine.totalClicks,

      totalMoves:
          engine.totalMoves,

      appUsage: appUsage,
    ),
  );
}
  /// =====================================
  /// STOP
  /// =====================================

  void stopTracking() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();

    return super.close();
  }
}