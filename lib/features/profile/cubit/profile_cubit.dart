import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/token_service.dart';
import '../state/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());

  ////////////////////////////////////////////////
  /// LOAD USER
  ////////////////////////////////////////////////
  Future<void> loadUser() async {
    emit(state.copyWith(loading: true));

    final user = await TokenService.getUser();

    if (user != null) {
      emit(
        state.copyWith(
          name: user["full_name"] ?? "User",
          role: user["role"] ?? "",
          loading: false,
        ),
      );
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  ////////////////////////////////////////////////
  /// LOGOUT
  ////////////////////////////////////////////////
  Future<void> logout() async {
    await TokenService.clear();
  }
}