import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/services/api_service.dart';
import 'package:hrms_desktop/core/widget/custom_shimer_card.dart';
import 'package:hrms_desktop/core/widget/custome_search_bar.dart';
import 'package:hrms_desktop/features/home/cubit/home_cubit.dart';
import 'package:hrms_desktop/features/home/state/home_state.dart';
import 'package:hrms_desktop/features/home/widgets/check_in_out.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AttendanceCubit(ApiService())..loadTodayAttendance(), // API call

      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 200,
          leading: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Image.asset('assets/images/opsen.png'),
              ),
              const Text(
                'OpzentoHR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
             //   const CustomSearchBar(),

                const SizedBox(height: 10),

             
                BlocBuilder<AttendanceCubit, AttendanceState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(
                        child: ShimmerCard(),
                      );
                    }

                    

                    return CheckInOutCard(
                      firstCheckIn: state.firstCheckIn,
                      lastCheckOut: state.lastCheckOut,
                      totalHours: state.totalHours,
                      breakTime: state.breakTime,
                      tags:state.tags

                    );
                  },
                ),

                const SizedBox(height: 16),

             
              //   const AttendanceActions(),
              //   const SizedBox(height: 16),
              // //  const CircularCardSection(),
              //   const SizedBox(height: 16),
              //   const BirthdaySection(),
              //   const SizedBox(height: 16),
              //   const AnniversarySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}