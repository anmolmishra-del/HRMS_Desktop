import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/attendance/attendance_page.dart';
import 'package:hrms_desktop/features/home/presentation/home_page.dart';
import 'package:hrms_desktop/features/main/cubit/main_cubit.dart';
import 'package:hrms_desktop/features/main/state/main_state.dart';

import 'package:hrms_desktop/features/payroll/payroll_screen.dart';
import 'package:hrms_desktop/features/screens/ai_chat_bot_page.dart';
import 'package:hrms_desktop/features/profile/profile_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.selectedIndex,
              children: [
                HomePage(),
                AttendanceScreen(shouldAnimate: state.selectedIndex == 1),
                const PayrollScreen(),
                const AiChatBotPage(),
                // const ProfileScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}

//   static final List<Widget> _pages = [
//     HomePage(),
//     AttendanceScreen(),
//     // PayrollScreen(),
//     // ChatScreen(),
//     // ProfileScreen(),
//   ];
// }
