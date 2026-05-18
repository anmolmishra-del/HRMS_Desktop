import 'package:equatable/equatable.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';

class ProductivityState extends Equatable {

  final bool isLoading;

  final double productivityPercent;

  /// FORMATTED TIMES
  final String focusTime;

  final String idleTime;

  final int totalKeys;

  final int totalClicks;

  final int totalMoves;

  final List<AppUsageInfo>
      appUsage;

  final Map<String, double>
      weeklyProductivity;

  final String? errorMessage;

  const ProductivityState({
    this.isLoading = false,

    this.productivityPercent = 0,

    this.focusTime =
        "0h 0m 0s",

    this.idleTime =
        "0h 0m 0s",

    this.totalKeys = 0,

    this.totalClicks = 0,

    this.totalMoves = 0,

    this.appUsage = const [],

    this.weeklyProductivity =
        const {},

    this.errorMessage,
  });

  ProductivityState copyWith({

    bool? isLoading,

    double? productivityPercent,

    String? focusTime,

    String? idleTime,

    int? totalKeys,

    int? totalClicks,

    int? totalMoves,

    List<AppUsageInfo>?
        appUsage,

    Map<String, double>?
        weeklyProductivity,

    String? errorMessage,
  }) {

    return ProductivityState(

      isLoading:
          isLoading ??
              this.isLoading,

      productivityPercent:
          productivityPercent ??
              this
                  .productivityPercent,

      focusTime:
          focusTime ??
              this.focusTime,

      idleTime:
          idleTime ??
              this.idleTime,

      totalKeys:
          totalKeys ??
              this.totalKeys,

      totalClicks:
          totalClicks ??
              this.totalClicks,

      totalMoves:
          totalMoves ??
              this.totalMoves,

      appUsage:
          appUsage ??
              this.appUsage,

      weeklyProductivity:
          weeklyProductivity ??
              this
                  .weeklyProductivity,

      errorMessage:
          errorMessage ??
              this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [

        isLoading,

        productivityPercent,

        focusTime,

        idleTime,

        totalKeys,

        totalClicks,

        totalMoves,

        appUsage,

        weeklyProductivity,

        errorMessage,
      ];
}