import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/attendance/attendance_page.dart';
import 'package:hrms_desktop/features/home/presentation/home_page.dart';
import 'package:hrms_desktop/features/main/cubit/main_cubit.dart';
import 'package:hrms_desktop/features/main/state/main_state.dart';

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
               // AttendanceScreen(shouldAnimate: state.selectedIndex == 1),
                // PayrollScreen(), // My Pay
                // chatPage(),
                // ProfileScreen(), // Profile
              ],
            ),

            bottomNavigationBar: NavigationBar(
              backgroundColor: const Color.fromARGB(255, 242, 249, 250),
              selectedIndex: state.selectedIndex,
              indicatorColor: Color.fromARGB(255, 156, 204, 223),
              onDestinationSelected: (index) {
                context.read<MainCubit>().changeTab(index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Attendance',
                ),
                NavigationDestination(
                  icon: Icon(Icons.payment_outlined),
                  selectedIcon: Icon(Icons.payment),
                  label: 'My Pay',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
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
