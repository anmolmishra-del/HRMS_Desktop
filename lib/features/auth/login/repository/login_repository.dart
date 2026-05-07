import 'package:dio/dio.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/features/otp/repository/auth_response.dart';


class ApiResult {
  final bool success;
  final String message;

  ApiResult({required this.success, required this.message});
}
class LoginRepository {
  final ApiService api;

  LoginRepository(this.api);

  ////////////////////////////////////////////////
  /// SEND OTP
  ////////////////////////////////////////////////
  Future<ApiResult> sendOtp(String mobile) async {
  try {
    final res = await api.post(
      "/employee/auth/send-otp",
      data: {
        "phone_number": mobile,
        "purpose": "login",
      },
    );

    return ApiResult(
      success: res.statusCode==200,
      message: res.data["message"] ?? "OTP sent",
    );
  } on DioException catch (e) {
    return ApiResult(
      success: false,
      message: e.response?.data["message"] ??
          "Something went wrong",
    );
  } catch (e) {
    return ApiResult(
      success: false,
      message: "Unexpected error",
    );
  }
}
  Future<AuthResponse?> verifyOtp(String mobile, String otp) async {
  try {
    final res = await api.post(
      "/employee/auth/verify-otp",
      data: {
        "phone_number": mobile,
        "otp": otp,
      },
    );

    if (res.statusCode == 200) {
      print(res.data);

      return AuthResponse.fromJson(res.data);
    }

    return null;
  } catch (e) {
    print("VERIFY ERROR: $e");
    return null;
  }
}
}