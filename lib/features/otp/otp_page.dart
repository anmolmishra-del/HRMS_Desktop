import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/auth/login/repository/login_repository.dart';
import 'package:hrms_desktop/features/otp/cubit/otp_cubit.dart';
import '../../../core/services/api_service.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String mobile;

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? timer;
  int secondsRemaining = 30;
  bool enableResend = false;

  bool get isOtpValid =>
      controllers.every((c) => c.text.isNotEmpty);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mobile = ModalRoute.of(context)!.settings.arguments as String;
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  ////////////////////////////////////////////////
  /// TIMER
  ////////////////////////////////////////////////
  void startTimer() {
    secondsRemaining = 30;
    enableResend = false;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        setState(() => enableResend = true);
        t.cancel();
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  ////////////////////////////////////////////////
  /// RESEND OTP
  ////////////////////////////////////////////////
  void resendOTP() {
    startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Resent")),
    );
  }

  ////////////////////////////////////////////////
  /// VERIFY OTP
  ////////////////////////////////////////////////
  void verifyOTP(BuildContext context) {
    final otp = controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 6-digit OTP")),
      );
      return;
    }

    context.read<OtpCubit>().verifyOtp(
          context,
          mobile,
          otp,
        );
  }

  ////////////////////////////////////////////////
  /// OTP BOX
  ////////////////////////////////////////////////
  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => OtpCubit(
      LoginRepository(ApiService()),
    ),
    child: Builder( // ✅ IMPORTANT FIX
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text("OTP Verification")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  "Enter OTP sent to $mobile",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 40),

                /// OTP BOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, buildOtpBox),
                ),

                const SizedBox(height: 20),

                /// TIMER / RESEND
                enableResend
                    ? TextButton(
                        onPressed: resendOTP,
                        child: const Text("Resend OTP"),
                      )
                    : Text(
                        "Resend in $secondsRemaining s",
                        style: const TextStyle(color: Colors.grey),
                      ),

                const Spacer(),

                /// VERIFY BUTTON
                BlocBuilder<OtpCubit, bool>(
                  builder: (context, loading) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isOtpValid && !loading
                            ? () => verifyOTP(context) // ✅ correct context
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOtpValid
                              ? Colors.blue
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Verify OTP"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}