import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import 'package:hrms_desktop/features/leave/cubit/leave_cubit.dart';
import 'package:hrms_desktop/features/leave/cubit/leave_state.dart';
import 'package:hrms_desktop/features/leave/models/leave_model.dart';
import 'package:hrms_desktop/features/leave/models/leave_type_model.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/routes.dart';
import 'package:intl/intl.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveCubit>().fetchLeavesAndTypes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: themeState.hasBackground
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              if (themeState.hasBackground)
                Positioned.fill(
                  child: themeState.isAssetBackground
                      ? Image.asset(
                          themeState.backgroundImagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          dart_io.File(themeState.backgroundImagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                ),
              if (themeState.hasBackground)
                Positioned.fill(
                  child: Container(
                    color: themeState.themeMode == ThemeMode.dark
                        ? Colors.black.withAlpha(140)
                        : Colors.black.withAlpha(51),
                  ),
                ),
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: BlocBuilder<LeaveCubit, LeaveState>(
                      builder: (context, state) {
                        return RefreshIndicator(
                          onRefresh: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
                          color: AppColors.primaryPurple,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (state.status == LeaveStatus.loading && state.leaves.isEmpty)
                                const SliverFillRemaining(
                                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                                )
                              else if (state.status == LeaveStatus.failure && state.leaves.isEmpty)
                                SliverFillRemaining(
                                  child: Center(child: Text("${AppLocalizations.of(context).error}: ${state.errorMessage}", style: const TextStyle(color: Colors.red))),
                                )
                              else ...[
                                if (state.leaveTypes.isNotEmpty)
                                  SliverToBoxAdapter(
                                    child: _BalanceSummary(leaveTypes: state.leaveTypes),
                                  ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                                  sliver: Builder(
                                    builder: (context) {
                                      final activeLeaves = state.leaves.where((l) => l.state != 'cancel' && l.state != 'refuse').toList();
                                      if (activeLeaves.isEmpty) {
                                        return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(context));
                                      }
                                      return SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) => _LeaveCard(leave: activeLeaves[index]),
                                          childCount: activeLeaves.length,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: _buildFAB(context),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).myTimeOff,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            onPressed: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, Routes.applyLeave);
          if (result == true && mounted) {
            context.read<LeaveCubit>().fetchLeavesAndTypes();
          }
        },
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(AppLocalizations.of(context).requestLeave, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Theme.of(context).shadowColor.withAlpha(13), blurRadius: 20),
            ],
          ),
          child: Icon(Icons.event_note_rounded, size: 80, color: AppColors.primaryPurple.withAlpha(26)),
        ),
        const SizedBox(height: 24),
        Text(AppLocalizations.of(context).noLeaveRecords, 
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context).leaveHistoryDescription, 
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), height: 1.5)
        ),
      ],
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final List<LeaveType> leaveTypes;
  const _BalanceSummary({required this.leaveTypes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(AppLocalizations.of(context).leaveManagement, 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1400
                  ? 5
                  : MediaQuery.of(context).size.width > 1000
                      ? 4
                      : MediaQuery.of(context).size.width > 700
                          ? 3
                          : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: leaveTypes.length,
            itemBuilder: (context, index) {
              final type = leaveTypes[index];
              return _BalanceCard(type: type);
            },
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final LeaveType type;
  const _BalanceCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[(type.name.hashCode).abs() % Colors.primaries.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.name, 
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type.remainingLeaves.toStringAsFixed(1), 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text("/ ${type.maxLeaves.toInt()}", 
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(127), fontWeight: FontWeight.w500)
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).daysAvailable, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha(102))),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  Color _getStatusColor() {
    switch (leave.state) {
      case 'validate': return AppColors.successGreen;
      case 'confirm': return Colors.blue;
      case 'refuse': return AppColors.dangerRed;
      case 'cancel': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _getStatusText(BuildContext context) {
    switch (leave.state) {
      case 'validate': return AppLocalizations.of(context).approved;
      case 'confirm': return AppLocalizations.of(context).pending;
      case 'refuse': return AppLocalizations.of(context).refused;
      case 'cancel': return AppLocalizations.of(context).cancelled;
      case 'draft': return AppLocalizations.of(context).draft;
      default: return leave.state ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final typeColor = Colors.primaries[(leave.holidayStatusId?.name.hashCode ?? 0).abs() % Colors.primaries.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withAlpha(10), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(leave.holidayStatusId?.name ?? AppLocalizations.of(context).leaveManagement, 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(text: _getStatusText(context), color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha(127)),
                      const SizedBox(width: 8),
                      Text(
                        "${DateFormat('dd MMM').format(leave.requestDateFrom!)} - ${DateFormat('dd MMM yyyy').format(leave.requestDateTo!)}",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(leave.durationDisplay ?? "", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 16)
                      ),
                    ],
                  ),
                  if (leave.name != null && leave.name!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(leave.name!, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontSize: 12, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (leave.state == 'draft' || leave.state == 'confirm' || leave.state == 'validate')
              _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant ?? Theme.of(context).dividerColor.withAlpha(26),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (leave.state == 'draft')
            TextButton.icon(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
              label: Text(AppLocalizations.of(context).deleteDraft, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          else
            TextButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.orangeAccent),
              label: Text(AppLocalizations.of(context).cancelLeave, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(AppLocalizations.of(context).cancelRequestQuestion, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(AppLocalizations.of(context).cancelRequestConfirmation, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).no)),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().cancelLeave(leave.id); },
          child: Text(AppLocalizations.of(context).yesCancel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(AppLocalizations.of(context).deleteDraftQuestion, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(AppLocalizations.of(context).deleteDraftConfirmation, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).cancel)),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().deleteLeave(leave.id); },
          child: Text(AppLocalizations.of(context).delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
