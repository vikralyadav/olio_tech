import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/cubit/ auth_cubit.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../../export/presentation/pages/export_page.dart';
import '../../home/presentation/pages/home_shell.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';
import '../../notifications/presentation/pages/notifications_page.dart';
import '../../receipts/presentation/cubit/receipt_cubit.dart';
import '../../receipts/presentation/pages/receipts_page.dart';
import '../../splash/presentations/pages/splash_page.dart';
import '../../subscriptions/presentation/cubit/subscription_cubit.dart';
import '../../subscriptions/presentation/pages/subscriptions_page.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../di/injection_container.dart';
import 'routes_name.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _material(
          BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const SplashPage(),
          ),
        );

      case RouteNames.login:
        return _material(
          BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const LoginPage(),
          ),
        );

      case RouteNames.register:
        return _material(
          BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const RegisterPage(),
          ),
        );

      case RouteNames.home:
        return _material(const HomeShell());

      case RouteNames.receipts:
        return _material(
          BlocProvider(
            create: (_) => sl<ReceiptCubit>(),
            child: const ReceiptsPage(),
          ),
        );

      case RouteNames.subscriptions:
        return _material(
          BlocProvider(
            create: (_) => sl<SubscriptionCubit>(),
            child: const SubscriptionsPage(),
          ),
        );

      case RouteNames.notifications:
        return _material(
          BlocProvider(
            create: (_) => sl<NotificationCubit>()..load(),
            child: const NotificationsPage(),
          ),
        );

      case RouteNames.export:
        return _material(
          ExportPage(repository: sl<TransactionRepository>()),
        );

      default:
        return _material(
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static MaterialPageRoute _material(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
