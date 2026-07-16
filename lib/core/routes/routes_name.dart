import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../auth/presentation/cubit/ auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../../splash/presentations/pages/splash_page.dart';
import 'app_routes.dart';

class AppRoutes {


 static final sl = GetIt.instance;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const LoginPage(),
          ),
        );

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const RegisterPage(),
          ),
        );

      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const SplashPage(),
          ),
        );

      // case RouteNames.home:
      //   return MaterialPageRoute(
      //     builder: (_) => const HomePage(),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(),
        );
    }
  }
}