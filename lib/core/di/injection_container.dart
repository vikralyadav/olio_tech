import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import '../../auth/data/datasourse/auth_local_data_sourse.dart';
import '../../auth/data/datasourse/auth_local_data_sourse_impl.dart';
import '../../auth/data/repository/auth_repository_impl.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../auth/domain/usecases/is_logged_in_usecase.dart';
import '../../auth/domain/usecases/login_usecase.dart';
import '../../auth/domain/usecases/logout_usecase.dart';
import '../../auth/domain/usecases/register_usecase.dart';
import '../../auth/presentation/cubit/ auth_cubit.dart';

// Analytics
import '../../analytics/data/datasources/report_local_data_source.dart';
import '../../analytics/data/repositories/report_repository_impl.dart';
import '../../analytics/domain/repositories/report_repository.dart';
import '../../analytics/presentation/cubit/analytics_cubit.dart';

// Budgets
import '../../budgets/data/datasources/budget_local_data_source.dart';
import '../../budgets/data/repositories/budget_repository_impl.dart';
import '../../budgets/domain/repositories/budget_repository.dart';
import '../../budgets/domain/usecases/budget_usecases.dart';
import '../../budgets/presentation/cubit/budget_cubit.dart';

// Dashboard
import '../../dashboard/presentation/cubit/dashboard_cubit.dart';

// Notifications
import '../../notifications/data/datasources/notification_local_data_source.dart';
import '../../notifications/data/repositories/notification_repository_impl.dart';
import '../../notifications/domain/repositories/notification_repository.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';

// Receipts
import '../../receipts/data/datasources/receipt_local_data_source.dart';
import '../../receipts/data/repositories/receipt_repository_impl.dart';
import '../../receipts/domain/repositories/receipt_repository.dart';
import '../../receipts/presentation/cubit/receipt_cubit.dart';

// Subscriptions
import '../../subscriptions/data/datasources/subscription_local_data_source.dart';
import '../../subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../subscriptions/domain/usecases/subscription_usecases.dart';
import '../../subscriptions/presentation/cubit/subscription_cubit.dart';

// Transactions
import '../../transactions/data/datasources/transaction_local_data_source.dart';
import '../../transactions/data/repositories/transaction_repository_impl.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../../transactions/domain/usecases/add_transaction.dart';
import '../../transactions/domain/usecases/delete_transaction.dart';
import '../../transactions/domain/usecases/get_transactions.dart';
import '../../transactions/domain/usecases/update_transaction.dart';
import '../../transactions/presentation/cubit/transaction_cubit.dart';

import '../data/app_database.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------------------------------------------------------------
  // External / Core
  // ---------------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.seeded());
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));

  // ---------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        isLoggedInUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  // ---------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------
  sl.registerLazySingleton<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerFactory<TransactionCubit>(() => TransactionCubit(
        getTransactions: sl(),
        addTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
      ));

  // ---------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------
  sl.registerLazySingleton<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => AddBudget(sl()));
  sl.registerLazySingleton(() => UpdateBudget(sl()));
  sl.registerLazySingleton(() => DeleteBudget(sl()));
  sl.registerFactory<BudgetCubit>(() => BudgetCubit(
        getBudgets: sl(),
        addBudget: sl(),
        updateBudget: sl(),
        deleteBudget: sl(),
      ));

  // ---------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------
  sl.registerLazySingleton<ReportLocalDataSource>(
      () => ReportLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(sl()));
  sl.registerFactory<AnalyticsCubit>(() => AnalyticsCubit(
        transactionRepository: sl(),
        reportRepository: sl(),
      ));

  // ---------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(
        transactionRepository: sl(),
        budgetRepository: sl(),
      ));

  // ---------------------------------------------------------------
  // Subscriptions
  // ---------------------------------------------------------------
  sl.registerLazySingleton<SubscriptionLocalDataSource>(
      () => SubscriptionLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetSubscriptions(sl()));
  sl.registerLazySingleton(() => AddSubscription(sl()));
  sl.registerLazySingleton(() => UpdateSubscription(sl()));
  sl.registerLazySingleton(() => DeleteSubscription(sl()));
  sl.registerFactory<SubscriptionCubit>(() => SubscriptionCubit(
        getSubscriptions: sl(),
        addSubscription: sl(),
        updateSubscription: sl(),
        deleteSubscription: sl(),
      ));

  // ---------------------------------------------------------------
  // Receipts
  // ---------------------------------------------------------------
  sl.registerLazySingleton<ReceiptLocalDataSource>(
      () => ReceiptLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ReceiptRepository>(
      () => ReceiptRepositoryImpl(sl()));
  sl.registerFactory<ReceiptCubit>(() => ReceiptCubit(
        receiptRepository: sl(),
        transactionRepository: sl(),
      ));

  // ---------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------
  sl.registerLazySingleton<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl()));
  sl.registerFactory<NotificationCubit>(() => NotificationCubit(sl()));
}
