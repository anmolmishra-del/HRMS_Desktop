import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:hrms_desktop/features/auth/login/repository/login_repository.dart';
import 'package:hrms_desktop/features/auth/login/state/login_state.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final apiService = ApiService();
 final LoginRepository loginRepo = LoginRepository(ApiService());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(loginRepo), // ✅ FIXED (comma added)
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();

          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                /// BACKGROUND IMAGE
                Positioned.fill(
                  child: Image.asset(AppImages.image, fit: BoxFit.cover),
                ),

                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        /// TITLE
                        const Text(
                          "Opzento HR",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// CARD
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double maxWidth = constraints.maxWidth;

                            return Container(
                              width: maxWidth > 500 ? 360 : maxWidth * 0.88,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),

                              /// FORM
                              child: Form(
                                key: cubit.formKey,
                                child: Column(
                                  children: [
                                    /// MOBILE FIELD
                                    TextFormField(
                                      controller: cubit.mobileController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      onChanged: cubit.onMobileChanged,
                                      decoration: InputDecoration(
                                        hintText: "Enter Mobile Number",
                                        prefixIcon: const Icon(Icons.phone),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      validator: cubit.validateMobile,
                                    ),

                                    const SizedBox(height: 20),

                                    /// BUTTON
                                    state.status == LoginStatus.loading
                                        ? const CircularProgressIndicator()
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: state.isValidMobile
                                                  ? () => cubit.sendOtp(context)
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    state.isValidMobile
                                                        ? Colors.blue
                                                        : Colors.grey,
                                              ),
                                              child: const Text("Send OTP"),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        /// FOOTER
                        const Text.rich(
                          TextSpan(
                            text: "Powered by ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "FastTrackProjects",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}