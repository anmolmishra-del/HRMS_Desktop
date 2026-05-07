import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/routes.dart';
import '../../../core/services/token_service.dart';
import '../../auth/login/repository/login_repository.dart';

class OtpCubit extends Cubit<bool> {
  final LoginRepository repo;

  OtpCubit(this.repo) : super(false);
Future<void> verifyOtp(
  BuildContext context,
  String mobile,
  String otp,
) async {
  emit(true);

  final auth = await repo.verifyOtp(mobile, otp);

  if (auth != null) {
    await TokenService.saveAuth(auth);

     Navigator.pushNamed(
      context,
      Routes.main,
     
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid OTP")),
    );
  }

  emit(false);
}
}