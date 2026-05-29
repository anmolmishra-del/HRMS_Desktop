import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import '../cubit/projects_cubit.dart';
import '../cubit/projects_state.dart';
import '../models/project_model.dart';
import 'project_tasks_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (context.read<ProjectsCubit>().state.status == ProjectsStatus.initial) {
      context.read<ProjectsCubit>().fetchProjects();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  String _formatDate(BuildContext context, String? dateString) {
    if (dateString == null) return AppLocalizations.of(context).noDeadline;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildProjectCard(ProjectModel project) {
    final partner = project.partnerName ?? AppLocalizations.of(context).noClient;
    final userName = project.userName ?? AppLocalizations.of(context).unknownManager;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
          border: Border(
                              left: BorderSide(
                                 color: Colors.primaries[project.name
                                  .hashCode % Colors.primaries.length],
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => ProjectTasksPage(
                 projectId: project.id, 
                 projectName: project.name,
               ),
             ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.business_center_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                partner,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
                                  fontSize: 13
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brightBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.task_alt_rounded, size: 14, color: AppColors.brightBlue),
                        const SizedBox(width: 4),
                        Text(
                          '${project.taskCount} ${AppLocalizations.of(context).tasks}',
                          style: const TextStyle(color: AppColors.brightBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (project.userId != null)
                        _buildUserAvatar(project.userImage128, userName)
                      else
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          child: Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        project.userId != null ? userName : AppLocalizations.of(context).noManager,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(context, project.date),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String? userImage, String name) {
    if (userImage != null && userImage.isNotEmpty) {
      try {
        final bytes = base64Decode(userImage.trim());
        return CircleAvatar(
          radius: 14,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.indigo.withOpacity(0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<ThemeCubit,ThemeState>(
      builder: (context, themeState) =>
     Scaffold(
       backgroundColor: themeState.hasBackground
                    ? Colors.transparent
                    : Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) {
            final filteredProjects = _searchQuery.isEmpty 
                ? state.projects 
                : state.projects.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
      
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
                      titlePadding: const EdgeInsets.only(bottom: 16),
                      title: Text(
                        AppLocalizations.of(context).projects,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    state.status == ProjectsStatus.loading
                        ? const Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                            onPressed: () => context.read<ProjectsCubit>().fetchProjects(),
                          ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).searchProjects,
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
                if (state.status == ProjectsStatus.loading && state.projects.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.indigo)),
                  )
                else if (state.status == ProjectsStatus.error && state.projects.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text(state.errorMessage ?? 'An error occurred', style: const TextStyle(color: AppColors.dangerRed))),
                  )
                else if (filteredProjects.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? AppLocalizations.of(context).noMatchesFound : AppLocalizations.of(context).noProjectsAvailable,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
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
                          return _buildProjectCard(filteredProjects[index]);
                        },
                        childCount: filteredProjects.length,
                      ),
                    ),
                  ),
                  
                const SliverToBoxAdapter(child: SizedBox(height: 40)), // bottom padding
              ],
            );
          },
        ),
      ),
    );
  }
}
