import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:intl/intl.dart';
import '../models/project_task_model.dart';
import 'project_tasks_state.dart';
import 'package:flutter/foundation.dart';

class ProjectTasksCubit extends Cubit<ProjectTasksState> {
  ProjectTasksCubit() : super(const ProjectTasksState());

  void clearData() {
    emit(const ProjectTasksState());
  }

  Future<void> fetchTasksAndUsers(int projectId) async {
    emit(state.copyWith(status: ProjectTasksStatus.loading));

    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      var baseUrl = await prefs.getString('baseUrl');

      if (sobj == null || baseUrl == null) {
        emit(state.copyWith(status: ProjectTasksStatus.error, errorMessage: 'Session expired'));
        return;
      }

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      // Fetch users
      var users = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'name', 'email'],
          'context': {'active_test': false},
        },
      });

      // Fetch tasks
      var tasksData = await client.callKw({
        'model': 'project.task',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['project_id', '=', projectId]],
          'fields': [
            'name',
            'description',
            'date_deadline',
            'stage_id',
            'priority',
            'remaining_hours',
            'effective_hours',
            'allocated_hours',
            'timesheet_ids',
            'allow_timesheets',
            'user_ids',
          ],
          'order': 'id desc',
        },
      });

      List<ProjectTaskModel> tasks = (tasksData as List).map((t) => ProjectTaskModel.fromJson(t)).toList();
      List<Map<String, dynamic>> userList = List<Map<String, dynamic>>.from(users);

      emit(state.copyWith(status: ProjectTasksStatus.loaded, tasks: tasks, users: userList));
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      emit(state.copyWith(status: ProjectTasksStatus.error, errorMessage: e.toString()));
    }
  }

  Future<bool> createTimesheet({
    required int taskId,
    required int projectId,
    required double duration,
    required String description,
    required DateTime date,
  }) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      var baseUrl = await prefs.getString('baseUrl');
      var empData = await prefs.getObject('employee_data');
      final empId = empData != null ? empData['id'] : null;

      if (sobj == null || baseUrl == null || empId == null) {
        throw 'Missing session or employee data';
      }

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);
      var data = {
        'task_id': taskId,
        'unit_amount': duration,
        'project_id': projectId,
        'user_id': session.userId,
        'employee_id': empId,
        'name': description,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'so_line': false,
        'is_so_line_edited': false,
      };
      
      await client.callKw({
        'model': 'account.analytic.line',
        'method': 'create',
        'args': [data],
        'kwargs': {},
      });

      // Refresh tasks
      await fetchTasksAndUsers(projectId);
      return true;
    } catch (e) {
      debugPrint('Error creating timesheet: $e');
      return false;
    }
  }
}
