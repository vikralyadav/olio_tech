import '../entities/app_notification.dart';
import '../entities/budget.dart';
import '../entities/category.dart';
import '../entities/monthly_report.dart';
import '../entities/receipt.dart';
import '../entities/subscription.dart';
import '../entities/transaction.dart';
import 'mock_data.dart';

/// Single in-memory source of truth for the whole app.
///
/// Seeded once from [MockData]; all feature datasources mutate these shared
/// lists so a change made in one feature (e.g. adding a transaction) is
/// immediately visible everywhere else (dashboard, analytics, budgets).
class AppDatabase {
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<Subscription> subscriptions;
  final List<Receipt> receipts;
  final List<MonthlyReport> monthlyReports;
  final List<AppNotification> notifications;

  List<Category> get categories => MockData.categories;

  AppDatabase._({
    required this.transactions,
    required this.budgets,
    required this.subscriptions,
    required this.receipts,
    required this.monthlyReports,
    required this.notifications,
  });

  factory AppDatabase.seeded() {
    return AppDatabase._(
      transactions: List<Transaction>.from(MockData.transactions),
      budgets: List<Budget>.from(MockData.budgets),
      subscriptions: List<Subscription>.from(MockData.subscriptions),
      receipts: List<Receipt>.from(MockData.receipts),
      monthlyReports: List<MonthlyReport>.from(MockData.monthlyReports),
      notifications: _seedNotifications(),
    );
  }

  Category? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<AppNotification> _seedNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'ntf_0',
        title: 'Budget Alert',
        body: 'You have used 85% of your Food & Dining budget this month.',
        date: now.subtract(const Duration(hours: 2)),
        type: NotificationType.budgetAlert,
      ),
      AppNotification(
        id: 'ntf_1',
        title: 'Upcoming Bill',
        body: 'Netflix (\$15.99) will be charged in 3 days.',
        date: now.subtract(const Duration(hours: 6)),
        type: NotificationType.billReminder,
      ),
      AppNotification(
        id: 'ntf_2',
        title: 'Weekly Insight',
        body: 'You spent 12% less on Transport compared to last week. Nice!',
        date: now.subtract(const Duration(days: 1)),
        type: NotificationType.insight,
      ),
      AppNotification(
        id: 'ntf_3',
        title: 'Large Transaction',
        body: 'A transaction of \$1,240.00 for Rent Payment was recorded.',
        date: now.subtract(const Duration(days: 1, hours: 5)),
        type: NotificationType.transaction,
        isRead: true,
      ),
      AppNotification(
        id: 'ntf_4',
        title: 'Subscription Renewed',
        body: 'Spotify Premium renewed successfully for \$9.99.',
        date: now.subtract(const Duration(days: 2)),
        type: NotificationType.billReminder,
        isRead: true,
      ),
      AppNotification(
        id: 'ntf_5',
        title: 'Savings Goal',
        body: 'You are on track to save \$620 this month. Keep it up!',
        date: now.subtract(const Duration(days: 3)),
        type: NotificationType.insight,
        isRead: true,
      ),
      AppNotification(
        id: 'ntf_6',
        title: 'Welcome to Olio',
        body: 'Track spending, scan receipts and manage budgets in one place.',
        date: now.subtract(const Duration(days: 4)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }
}
