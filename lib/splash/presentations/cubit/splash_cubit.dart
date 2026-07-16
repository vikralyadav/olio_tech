import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

class SplashCubit extends Cubit<SplashStatus> {
  SplashCubit() : super(SplashStatus.initial);

  Future<void> initialize() async {
    emit(SplashStatus.loading);

    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));

    /// final token = await storage.readToken();

    const bool isLoggedIn = false;

    if (isLoggedIn) {
      emit(SplashStatus.authenticated);
    } else {
      emit(SplashStatus.unauthenticated);
    }
  }
}