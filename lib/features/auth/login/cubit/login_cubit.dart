import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/routes.dart';
import '../repository/login_repository.dart';
import '../state/login_state.dart';


class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repo;

  LoginCubit(this.repo) : super(LoginState());

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (value.length != 10) return "Invalid number";
    return null;
  }

  void onMobileChanged(String value) {
    emit(state.copyWith(isValidMobile: value.length == 10));
  }
Future<void> sendOtp(BuildContext context) async {
  print("SEND OTP CLICKED");

  if (!formKey.currentState!.validate()) return;

  emit(state.copyWith(status: LoginStatus.loading));

  final result = await repo.sendOtp(mobileController.text);

  if (result.success) {
    emit(state.copyWith(status: LoginStatus.success));

    Navigator.pushNamed(
      context,
      Routes.otp,
      arguments: mobileController.text,
    );
  } else {
    emit(state.copyWith(status: LoginStatus.error));

    /// 🔥 SHOW ERROR MESSAGE
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}