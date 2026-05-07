import 'package:bloc/bloc.dart';
import 'package:hrms_desktop/features/main/state/main_state.dart';


class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState()) {
    _startLanding();
  }

  void _startLanding() {
    Future.delayed(const Duration(seconds: 3), () {
      emit(state.copyWith(showLanding: false));
    });
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
