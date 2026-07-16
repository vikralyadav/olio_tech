import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olio_tech/splash/presentations/cubit/splash_cubit.dart';
import 'package:olio_tech/splash/presentations/pages/splash_page.dart';

import 'auth/presentation/cubit/ auth_cubit.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/routes_name.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,


      );
  }
}