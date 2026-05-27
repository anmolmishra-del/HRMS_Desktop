import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../cubit/project_tasks_cubit.dart';
import '../cubit/project_tasks_state.dart';

class ProjectTasksPage extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectTasksPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  _ProjectTasksPageState createState() => _ProjectTasksPageState();
}

class _ProjectTasksPageState extends State<ProjectTasksPage> {
  // Timesheet controllers mapped by task ID
  final Map<int, TextEditingController> _timesheetControllers = {};
  final Map<int, TextEditingController> _timesheetDescControllers = {};
  final Map<int, FocusNode> _timesheetFocusNodes = {};
  final Map<int, DateTime?> _timesheetDates = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProjectTasksCubit>().fetchTasksAndUsers(widget.projectId);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _timesheetControllers.forEach((key, controller) => controller.dispose());
    _timesheetDescControllers.forEach((key, controller) => controller.dispose());
    _timesheetFocusNodes.forEach((key, node) => node.dispose());
    _searchController.dispose();
    super.dispose();
  }

  void _initControllersForTask(int taskId) {
    if (!_timesheetControllers.containsKey(taskId)) {
      _timesheetControllers[taskId] = TextEditingController();
      _timesheetDescControllers[taskId] = TextEditingController();
      _timesheetFocusNodes[taskId] = FocusNode();
      _timesheetDates[taskId] = DateTime.now();
    }
  }

  // Future<void> _addTimesheet(int taskId) async {
  //   final durationText = _timesheetControllers[taskId]?.text ?? '';
  //   final duration = double.tryParse(durationText) ?? 0;
  //   final description = _timesheetDescControllers[taskId]?.text ?? '';
  //   final date = _timesheetDates[taskId] ?? DateTime.now();

  //   if (duration <= 0 || description.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter valid duration and description'), backgroundColor: Colors.orange),
  //     );
  //     return;
  //   }

  //   final success = await context.read<ProjectTasksCubit>().createTimesheet(
  //     taskId: taskId,
  //     projectId: widget.projectId,
  //     duration: duration,
  //     description: description,
  //     date: date,
  //   );

  //   if (success) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Timesheet added successfully'), backgroundColor: Colors.green),
  //       );
  //     }
  //     _timesheetControllers[taskId]?.clear();
  //     _timesheetDescControllers[taskId]?.clear();
  //     setState(() {
  //       _timesheetDates[taskId] = DateTime.now();
  //     });
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to add timesheet'), backgroundColor: AppColors.dangerRed),
  //       );
  //     }
  //   }
  // }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No deadline';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildAssignedUsers(List<int> userIds, List<Map<String, dynamic>> allUsers) {
    if (userIds.isEmpty) {
      return const Text('No users assigned', style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    final assignedUsers = allUsers.where((user) => userIds.contains(user['id'])).toList();

    if (assignedUsers.isEmpty) {
      return const Text('No users assigned', style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    return Wrap(
      spacing: -8.0,
      children: assignedUsers.map((user) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primaryPurple,
            child: Text(
              user['name'].toString().isNotEmpty ? user['name'][0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '1':
        return Colors.orange;
      case '2':
        return AppColors.dangerRed;
      default:
        return AppColors.brightBlue;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case '0':
        return 'Low Priority';
      case '1':
        return 'High Priority';
      default:
        return 'Normal';
    }
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
      body: BlocBuilder<ProjectTasksCubit, ProjectTasksState>(
        builder: (context, state) {
          final filteredTasks = _searchQuery.isEmpty 
              ? state.tasks 
              : state.tasks.where((t) => t.name.toLowerCase().contains(_searchQuery)).toList();

          return RefreshIndicator(
            color: AppColors.indigo,
            onRefresh: () => context.read<ProjectTasksCubit>().fetchTasksAndUsers(widget.projectId),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures it can be pulled even if the list is short
              slivers: [
              SliverAppBar(
                expandedHeight: 100.0,
                floating: true,
                pinned: true,
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.violet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                  ),
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    title: Text(
                      widget.projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (state.status == ProjectTasksStatus.loading && state.tasks.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.indigo)),
                )
              else if (state.status == ProjectTasksStatus.error && state.tasks.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text(state.errorMessage ?? 'Error', style: const TextStyle(color: AppColors.dangerRed))),
                )
              else if (filteredTasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_outlined, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matches found' : 'No tasks in this project',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 18, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        final taskId = task.id;
                        
                        if (task.allowTimesheets) {
                          _initControllersForTask(taskId);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: BorderSide(
                                 color: Colors.primaries[task.name.hashCode % Colors.primaries.length],
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                task.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(task.priority).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getPriorityText(task.priority),
                                        style: TextStyle(color: _getPriorityColor(task.priority), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    _buildAssignedUsers(task.userIds, state.users),
                                  ],
                                ),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade50,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoChip(Icons.linear_scale_rounded, 'Status', task.stageName ?? 'New'),
                                          _buildInfoChip(Icons.timer_outlined, 'Hours', '${task.effectiveHours} / ${task.allocatedHours}'),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (task.dateDeadline != null)
                                        _buildInfoChip(Icons.event_outlined, 'Deadline', _formatDate(DateTime.tryParse(task.dateDeadline!))),
                                      
                                      if (task.description.isNotEmpty && task.description != 'false') ...[
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Description',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.indigo),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          task.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim(),
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 14, height: 1.5),
                                        ),
                                      ],
                                      
                                      /* Temporarily removed timesheet feature
                                      ...
                                      */
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
            ],
          ));
        },
      ),
    );
  }
}
