import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/presentation/cubit/analytics_cubit.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../auth/presentation/cubit/ auth_cubit.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..checkLoginStatus()),
        BlocProvider(create: (_) => sl<TransactionCubit>()..load()),
        BlocProvider(create: (_) => sl<BudgetCubit>()..load()),
        BlocProvider(create: (_) => sl<DashboardCubit>()..load()),
        BlocProvider(create: (_) => sl<AnalyticsCubit>()..load()),
        BlocProvider(create: (_) => sl<NotificationCubit>()..load()),
      ],
      child: const _HomeShellView(),
    );
  }
}

class _HomeShellView extends StatefulWidget {
  const _HomeShellView();

  @override
  State<_HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<_HomeShellView> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(onNavigateTab: _goTo),
      const TransactionsPage(showAppBar: true),
      const BudgetsPage(showAppBar: true),
      const AnalyticsPage(showAppBar: true),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaction',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
