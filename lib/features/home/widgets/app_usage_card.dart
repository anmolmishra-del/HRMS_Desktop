import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

class AppUsageCard extends StatelessWidget {
  final AppUsageInfo appData;

  const AppUsageCard({
    super.key,
    required this.appData,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final hours =
        appData.timeSpent.inHours;

    final minutes =
        appData.timeSpent
            .inMinutes
            .remainder(60);

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: appData.color
              .withOpacity(0.2),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: appData.color
                      .withOpacity(0.12),

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Icon(
                  appData.icon,

                  color: appData.color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _getLocalizedAppName(context, appData.appName),

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            AppLocalizations.of(context).durationHoursMinutes(hours.toString(), minutes.toString()),

            style: TextStyle(
              fontSize: 28,

              fontWeight:
                  FontWeight.bold,

              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedAppName(BuildContext context, String appName) {
    switch (appName) {
      case 'Development':
        return AppLocalizations.of(context).development;
      case 'Browser':
        return AppLocalizations.of(context).browser;
      case 'Entertainment':
        return AppLocalizations.of(context).entertainment;
      case 'Communication':
        return AppLocalizations.of(context).communication;
      case 'Productivity':
        return AppLocalizations.of(context).productivity;
      default:
        return appName;
    }
  }
}