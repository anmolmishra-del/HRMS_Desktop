import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/network/odoo_service.dart';
import '../state/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void onUsernameChanged(String value) {
    emit(state.copyWith(username: value, usernameError: null));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: value, passwordError: null));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> login({
    required String usernameErrorMsg,
    required String passwordErrorMsg,
  }) async {
    // 1. Validation
    bool hasError = false;
    String? usernameError;
    String? passwordError;

    if (state.username.trim().isEmpty) {
      usernameError = usernameErrorMsg;
      hasError = true;
    }

    if (state.password.trim().isEmpty) {
      passwordError = passwordErrorMsg;
      hasError = true;
    }

    if (hasError) {
      emit(state.copyWith(
        usernameError: usernameError,
        passwordError: passwordError,
      ));
      return;
    }

    final username = state.username;
    final password = state.password;
    debugPrint('--- Login Process Started ---');
    debugPrint('Input Username: $username');
    debugPrint('Input Password: $password');

    const baseUrl = 'https://test.ftprotech.in/';
    debugPrint('Using Base URL: $baseUrl');
    const db = 'pmt_test';
    debugPrint('Using Database: $db');
    final odooService = OdooService(baseUrl);

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // 1. Authenticate
      debugPrint('Method: authenticate(db: $db, user: $username) - Calling...');
      final session = await odooService.authenticate(db, username, password);
      debugPrint(
        'Method: authenticate - Result: Session ID ${session.id}, User ID ${session.userId}',
      );

      final prefs = SharedPref();
      await prefs.saveObject('session', session);
      await prefs.saveString('baseUrl', baseUrl);
      await prefs.saveString('db', db);
      await prefs.saveBool('is_logged_in', true);
      await prefs.saveBool('rememberMe', state.rememberMe);

      // 2. Get Employee Data
      debugPrint(
        'Method: callKw(hr.employee, search_read) - Fetching employee ID for userId: ${session.userId}',
      );
      final empResponse = await odooService.getEmployeeRecordsForUser(
        session.userId,
      );
      debugPrint(
        'Method: callKw(hr.employee, search_read) - Data Received: $empResponse',
      );

      final empId = empResponse[0]['id']?.toString() ?? '';
      debugPrint('Resolved Employee ID: $empId');

      // 3. Get Full Employee Details
      debugPrint(
        'Method: callKw(hr.employee, fetch_all_employees_info) - Fetching details for empId: $empId',
      );
      final employee = await odooService.fetchEmployeeDetails(
        int.parse(empId),
        session.userId,
      );
      debugPrint(
        'Method: callKw(hr.employee, fetch_all_employees_info) - Data Received: $employee',
      );

      await prefs.saveObject('employee_data', employee);
      await prefs.saveObject('user', employee); // For compatibility with TokenService
      await prefs.saveString('employee_id', employee['id']?.toString() ?? '');
      await prefs.saveString(
        'profile_pic',
        employee['profile_pic']?.toString() ?? '',
      );
       await prefs.saveString(
        'employee_code', employee['employee_code']?.toString() ?? '',
      );

      // 4. Get User Groups
      debugPrint(
        'Method: callKw(res.users, search_read) - Checking groups for userId: ${session.userId}',
      );
      final isInternal = await odooService.isInternalUser(session.userId);
      debugPrint('User belongs to Internal User group (96): $isInternal');
      await prefs.saveBool('isInternalUser', isInternal);

      await prefs.saveString('partner_id', session.partnerId.toString());
      debugPrint('Partner ID Saved: ${session.partnerId}');

      debugPrint('--- Login Process Success ---');
      emit(state.copyWith(status: LoginStatus.success));
    } on OdooSessionExpiredException {
      debugPrint('--- Login Process Failed: Session Expired ---');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: "Session expired. Please log in again.",
        ),
      );
    } on OdooException catch (e) {
      debugPrint('--- Login Process Failed: Odoo Exception ($e) ---');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: "Wrong login or password",
        ),
      );
    } catch (e) {
      debugPrint('--- Login Process Failed: Unexpected Error ($e) ---');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: "An error occurred: ${e.toString()}",
        ),
      );
    } finally {
      odooService.close();
      debugPrint('--- Odoo Client Closed ---');
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = SharedPref();
    final rememberMe = await prefs.getBool('rememberMe') ?? false;
    final sessionData = await prefs.getObject('session');

    if (!rememberMe) {
      debugPrint('Remember Me is disabled. Requiring fresh login.');
      await _clearSessionData(prefs);
      emit(state.copyWith(status: LoginStatus.initial));
      return;
    }

    if (sessionData != null && sessionData is Map && sessionData.isNotEmpty) {
      final baseUrl =
          await prefs.getString('baseUrl') ?? 'https://ftprotech.in/';

      // Reconstruction of OdooSession
      final session = OdooSession.fromJson(Map<String, dynamic>.from(sessionData));

      final client = OdooClient(baseUrl, sessionId: session);

      try {
        debugPrint('Checking Odoo session validity...');
        await client.checkSession();
        debugPrint('Session is valid.');

        emit(state.copyWith(status: LoginStatus.success));
      } catch (e) {
        debugPrint('Session check failed or expired: $e');
        // If session fails, clear credentials
        await _clearSessionData(prefs);
        emit(state.copyWith(status: LoginStatus.initial));
      } finally {
        client.close();
      }
    } else {
      debugPrint('No saved session found.');
      emit(state.copyWith(status: LoginStatus.initial));
    }
  }

  Future<void> logout() async {
    debugPrint('--- Logout Process Started ---');
    final prefs = SharedPref();
    await _clearSessionData(prefs);
    emit(state.copyWith(status: LoginStatus.initial));
    debugPrint('--- Logout Process Complete ---');
  }

  Future<void> _clearSessionData(SharedPref prefs) async {
    debugPrint('Clearing session data from SharedPref...');
    await prefs.remove('session');
    await prefs.remove('is_logged_in');
    await prefs.remove('employee_data');
    await prefs.remove('user');
    await prefs.remove('employee_id');
     await prefs.remove('employee_code');
    await prefs.remove('profile_pic');
    await prefs.remove('partner_id');
    await prefs.remove('isInternalUser');
    await prefs.remove('rememberMe');
   
    await prefs.remove('chat_server_url');
    await prefs.remove('chat_db_name');
    await prefs.remove('chat_username');
    await prefs.remove('chat_password');
  }
}