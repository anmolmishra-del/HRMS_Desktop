import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../models/project_model.dart';
import 'projects_state.dart';
import 'package:flutter/foundation.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit() : super(const ProjectsState());

  void clearData() {
    emit(const ProjectsState());
  }

  Future<void> fetchProjects() async {
    emit(state.copyWith(status: ProjectsStatus.loading));

    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      var baseUrl = await prefs.getString('baseUrl');

      if (sobj == null || baseUrl == null) {
        emit(state.copyWith(status: ProjectsStatus.error, errorMessage: 'Session expired'));
        return;
      }

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      var response = await client.callKw({
        'model': 'project.project',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': [
            'name',
            'description',
            'date_start',
            'date',
            'user_id',
            'task_count',
            'allow_timesheets',
            'partner_id',
          ],
          'order': 'name asc',
        },
      });

      List<ProjectModel> projects = (response as List).map((p) => ProjectModel.fromJson(p)).toList();

      final userIds = projects
          .where((proj) => proj.userId != null)
          .map((proj) => proj.userId!)
          .toSet()
          .toList();

      if (userIds.isNotEmpty) {
        final userImages = await client.callKw({
          'model': 'res.users',
          'method': 'read',
          'args': [userIds],
          'kwargs': {
            'fields': ['id', 'image_128'],
          },
        });
        
        final userImageMap = {
          for (var user in (userImages as List))
            user['id']: user['image_128'],
        };
        
        for (var i = 0; i < projects.length; i++) {
          if (projects[i].userId != null) {
            final imageStr = userImageMap[projects[i].userId!];
            if (imageStr != null && imageStr != 'false') {
              projects[i] = ProjectModel(
                id: projects[i].id,
                name: projects[i].name,
                description: projects[i].description,
                dateStart: projects[i].dateStart,
                date: projects[i].date,
                userId: projects[i].userId,
                userName: projects[i].userName,
                userImage128: imageStr.toString(),
                taskCount: projects[i].taskCount,
                allowTimesheets: projects[i].allowTimesheets,
                partnerId: projects[i].partnerId,
                partnerName: projects[i].partnerName,
              );
            }
          }
        }
      }

      emit(state.copyWith(status: ProjectsStatus.loaded, projects: projects));
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      emit(state.copyWith(status: ProjectsStatus.error, errorMessage: e.toString()));
    }
  }
}
