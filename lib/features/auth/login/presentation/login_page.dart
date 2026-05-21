import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/widget/custome_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:hrms_desktop/features/auth/login/state/login_state.dart';
import 'package:hrms_desktop/features/main/presentation/main_page.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.read<AttendanceCubit>().loadInitialStatus();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Login failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Stack(
            children: [
              // 🎨 Top Decorative Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.05),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(AppImages.logo, width: 40, height: 40),
                                  ),
                                  // Language selector removed as requested
                                ],
                              ),
                              const SizedBox(height: 40),
                              Text(
                                "Welcome back",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sign in to continue",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🚀 Main Login Card
              Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.38,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Username Field
                        BlocBuilder<LoginCubit, LoginState>(
                          buildWhen: (p, c) => p.usernameError != c.usernameError,
                          builder: (context, state) {
                            return CustomTextFormField(
                              label: "Username",
                              hintText: "Enter your username",
                              prefixIcon: Icons.alternate_email_rounded,
                              onChanged: (v) => context.read<LoginCubit>().onUsernameChanged(v),
                              errorText: state.usernameError,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        BlocBuilder<LoginCubit, LoginState>(
                          buildWhen: (p, c) => p.obscurePassword != c.obscurePassword || p.passwordError != c.passwordError,
                          builder: (context, state) {
                            return CustomTextFormField(
                              label: "Password",
                              hintText: "Enter your password",
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: state.obscurePassword,
                              onChanged: (v) => context.read<LoginCubit>().onPasswordChanged(v),
                              errorText: state.passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(state.obscurePassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                onPressed: () => context.read<LoginCubit>().togglePasswordVisibility(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password & Remember Me
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BlocBuilder<LoginCubit, LoginState>(
                              buildWhen: (p, c) => p.rememberMe != c.rememberMe,
                              builder: (context, state) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: state.rememberMe,
                                        activeColor: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        onChanged: (v) => context.read<LoginCubit>().toggleRememberMe(v!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Remember me", style: TextStyle(fontSize: 14)),
                                  ],
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Login Button
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            if (state.status == LoginStatus.loading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _handleLogin(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  elevation: 4,
                                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Footer
                        // const Center(
                        //   child: Column(
                        //     children: [
                        //       Text(
                        //         "POWERED BY",
                        //         style: TextStyle(
                        //           color: AppColors.textSecondary,
                        //           fontSize: 12,
                        //           fontWeight: FontWeight.bold,
                        //           letterSpacing: 1.5,
                        //         ),
                        //       ),
                        //       SizedBox(height: 4),
                        //       Text(
                        //         "FastTrackProjects",
                        //         style: TextStyle(
                        //           color: AppColors.textDark,
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    context.read<LoginCubit>().login(
          usernameErrorMsg: "Please enter your username",
          passwordErrorMsg: "Please enter your password",
        );
  }
}