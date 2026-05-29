import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

import '../cubit/productivity_cubit.dart';
import '../cubit/productivity_state.dart';

import '../widgets/app_usage_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/productivity_header.dart';

class ProductivityPage extends StatelessWidget {
  const ProductivityPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductivityCubit, ProductivityState>(

        builder:
            (context, state) {

          return SingleChildScrollView(

            padding:
                const EdgeInsets.all(
              24,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                /// =====================================
                /// HEADER
                /// =====================================

                ProductivityHeader(

                  selectedDate:
                      DateTime.now(),

                  onDateTap: () {},
                ),

                const SizedBox(
                  height: 30,
                ),

                /// =====================================
                /// PRODUCTIVITY METRICS
                /// =====================================

                Row(
                  children: [

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).todayScore,

                        value:
                            "${state.productivityPercent.toStringAsFixed(1)}%",

                        subtitle:
                            AppLocalizations.of(context).performance,

                        color:
                            Colors.green,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).focusTime,

                        value:
                            state.focusTime,

                        subtitle:
                            AppLocalizations.of(context).activeWork,

                        color:
                            Colors.blue,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).idleTime,

                        value:
                            state.idleTime,

                        subtitle:
                            AppLocalizations.of(context).inactive,

                        color:
                            Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                /// =====================================
                /// ACTIVITY METRICS
                /// =====================================

                Row(
                  children: [

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).keyboard,

                        value:
                            state.totalKeys
                                .toString(),

                        subtitle:
                            AppLocalizations.of(context).keystrokes,

                        color:
                            Colors.indigo,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).mouseClicks,

                        value:
                            state.totalClicks
                                .toString(),

                        subtitle:
                            AppLocalizations.of(context).clicks,

                        color:
                            Colors.orange,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: MetricCard(

                        title:
                            AppLocalizations.of(context).mouseMoves,

                        value:
                            state.totalMoves
                                .toString(),

                        subtitle:
                            AppLocalizations.of(context).movement,

                        color:
                            Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),

                /// =====================================
                /// APP USAGE TITLE
                /// =====================================

                Text(
                  AppLocalizations.of(context).applicationUsage,

                  style: TextStyle(
                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,

                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurface,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                /// =====================================
                /// APP USAGE GRID
                /// =====================================

                GridView.builder(

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:

                        MediaQuery.of(context)
                                    .size
                                    .width >
                                1800
                            ? 6

                            : MediaQuery.of(context)
                                        .size
                                        .width >
                                    1400
                                ? 5

                                : MediaQuery.of(context)
                                            .size
                                            .width >
                                        1000
                                    ? 4
                                    : 3,

                    crossAxisSpacing:
                        12,

                    mainAxisSpacing:
                        12,

                    childAspectRatio:
                        1.8,
                  ),

                  itemCount:
                      state.appUsage
                          .length,

                  itemBuilder:
                      (
                        context,
                        index,
                      ) {

                    final appData =
                        state.appUsage[
                            index];

                    return AppUsageCard(
                      appData:
                          appData,
                    );
                  },
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      );
  }
}