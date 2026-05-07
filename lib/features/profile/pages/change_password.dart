import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/widget/custome_button.dart';
import 'package:hrms_desktop/core/widget/custome_textfield.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  final _formKey = GlobalKey<FormState>();

  void resetPassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Updated Successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Current Password
                      CustomTextFormField(
                        controller: currentPassword,
                        hintText: 'Current Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: hideCurrent,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideCurrent
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              hideCurrent = !hideCurrent;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// New Password
                      CustomTextFormField(
                        controller: newPassword,
                        hintText: 'New Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: hideNew,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideNew ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              hideNew = !hideNew;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Confirm Password
                      CustomTextFormField(
                        controller: confirmPassword,
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: hideConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              hideConfirm = !hideConfirm;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomGradientButton(
                              text: 'Continue',
                              onPressed: () {},
                            ),
                          ),
                          Expanded(
                            child: CustomGradientButton(
                              text: 'Cancel',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          //   child: const Text("Cancel"),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// Top Icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.vpn_key, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
