import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/budget.dart';
import '../entities/category.dart';
import '../entities/monthly_report.dart';
import '../entities/receipt.dart';
import '../entities/subscription.dart';
import '../entities/transaction.dart';

class MockData {
  static final _random = Random(42);

  static final List<Category> categories = _generateCategories();
  static late final List<Transaction> transactions = _generateTransactions();
  static late final List<Budget> budgets = _generateBudgets();
  static late final List<Subscription> subscriptions = _generateSubscriptions();
  static late final List<Receipt> receipts = _generateReceipts();
  static late final List<MonthlyReport> monthlyReports = _generateMonthlyReports();

  static List<Category> _generateCategories() {
    return [
      const Category(id: 'cat_1', name: 'Salary', icon: Icons.work, color: Color(0xFF4CAF50), type: CategoryType.income),
      const Category(id: 'cat_2', name: 'Freelance', icon: Icons.laptop, color: Color(0xFF66BB6A), type: CategoryType.income),
      const Category(id: 'cat_3', name: 'Investments', icon: Icons.trending_up, color: Color(0xFF81C784), type: CategoryType.income),
      const Category(id: 'cat_4', name: 'Gifts Received', icon: Icons.card_giftcard, color: Color(0xFFA5D6A7), type: CategoryType.income),
      const Category(id: 'cat_5', name: 'Food & Dining', icon: Icons.restaurant, color: Color(0xFFEF5350), type: CategoryType.expense),
      const Category(id: 'cat_6', name: 'Transport', icon: Icons.directions_car, color: Color(0xFFFF9800), type: CategoryType.expense),
      const Category(id: 'cat_7', name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFF9C27B0), type: CategoryType.expense),
      const Category(id: 'cat_8', name: 'Entertainment', icon: Icons.movie, color: Color(0xFF2196F3), type: CategoryType.expense),
      const Category(id: 'cat_9', name: 'Bills & Utilities', icon: Icons.receipt_long, color: Color(0xFF795548), type: CategoryType.expense),
      const Category(id: 'cat_10', name: 'Health', icon: Icons.local_hospital, color: Color(0xFFE91E63), type: CategoryType.expense),
      const Category(id: 'cat_11', name: 'Education', icon: Icons.school, color: Color(0xFF3F51B5), type: CategoryType.expense),
      const Category(id: 'cat_12', name: 'Travel', icon: Icons.flight, color: Color(0xFF00BCD4), type: CategoryType.expense),
      const Category(id: 'cat_13', name: 'Groceries', icon: Icons.local_grocery_store, color: Color(0xFFFF5722), type: CategoryType.expense),
      const Category(id: 'cat_14', name: 'Rent', icon: Icons.home, color: Color(0xFF607D8B), type: CategoryType.expense),
      const Category(id: 'cat_15', name: 'Insurance', icon: Icons.security, color: Color(0xFF009688), type: CategoryType.expense),
      const Category(id: 'cat_16', name: 'Personal Care', icon: Icons.spa, color: Color(0xFFFF4081), type: CategoryType.expense),
      const Category(id: 'cat_17', name: 'Subscriptions', icon: Icons.subscriptions, color: Color(0xFF673AB7), type: CategoryType.expense),
      const Category(id: 'cat_18', name: 'Fitness', icon: Icons.fitness_center, color: Color(0xFF8BC34A), type: CategoryType.expense),
      const Category(id: 'cat_19', name: 'Gifts Given', icon: Icons.redeem, color: Color(0xFFFFC107), type: CategoryType.expense),
      const Category(id: 'cat_20', name: 'Miscellaneous', icon: Icons.more_horiz, color: Color(0xFF9E9E9E), type: CategoryType.expense),
    ];
  }

  static final List<String> _expenseTitles = [
    'Morning Coffee', 'Lunch at Cafe', 'Uber Ride', 'Grocery Shopping',
    'Netflix Subscription', 'Gym Membership', 'Phone Bill', 'Electric Bill',
    'Water Bill', 'Internet Bill', 'Gas Station', 'Parking Fee',
    'Movie Tickets', 'Concert Tickets', 'Restaurant Dinner', 'Fast Food',
    'Amazon Purchase', 'Clothing Store', 'Shoe Store', 'Electronics',
    'Pharmacy', 'Doctor Visit', 'Dentist', 'Eye Exam',
    'Haircut', 'Spa Treatment', 'Book Purchase', 'Online Course',
    'Gift for Friend', 'Birthday Gift', 'Home Repair', 'Dry Cleaning',
    'Pet Food', 'Vet Visit', 'Taxi Ride', 'Bus Pass',
    'Train Ticket', 'Hotel Booking', 'Flight Ticket', 'Insurance Premium',
    'Rent Payment', 'Maintenance Fee', 'Charity Donation', 'Magazine Subscription',
    'Spotify Premium', 'Cloud Storage', 'VPN Service', 'Software License',
    'Starbucks', 'Pizza Delivery',
  ];

  static final List<String> _incomeTitles = [
    'Monthly Salary', 'Freelance Project', 'Investment Dividend',
    'Stock Sale', 'Consulting Fee', 'Bonus Payment',
    'Tax Refund', 'Gift Money', 'Side Project Income',
    'Rental Income', 'Interest Income', 'Commission',
  ];

  static List<Transaction> _generateTransactions() {
    final List<Transaction> result = [];
    final now = DateTime.now();
    final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
    final incomeCategories = categories.where((c) => c.type == CategoryType.income).toList();

    for (int i = 0; i < 250; i++) {
      final isIncome = _random.nextDouble() < 0.25;
      final daysAgo = _random.nextInt(365);
      final date = now.subtract(Duration(days: daysAgo));
      final cat = isIncome
          ? incomeCategories[_random.nextInt(incomeCategories.length)]
          : expenseCategories[_random.nextInt(expenseCategories.length)];

      double amount;
      String title;

      if (isIncome) {
        title = _incomeTitles[_random.nextInt(_incomeTitles.length)];
        if (cat.id == 'cat_1') {
          amount = 3500.0 + _random.nextInt(3000).toDouble();
        } else {
          amount = 200.0 + _random.nextInt(2000).toDouble();
        }
      } else {
        title = _expenseTitles[_random.nextInt(_expenseTitles.length)];
        if (cat.id == 'cat_14') {
          amount = 800.0 + _random.nextInt(700).toDouble();
        } else if (cat.id == 'cat_12') {
          amount = 200.0 + _random.nextInt(1500).toDouble();
        } else {
          amount = 5.0 + _random.nextInt(200).toDouble() + _random.nextDouble() * 10;
        }
      }

      result.add(Transaction(
        id: 'txn_$i',
        title: title,
        amount: double.parse(amount.toStringAsFixed(2)),
        date: date,
        categoryId: cat.id,
        categoryName: cat.name,
        type: isIncome ? TransactionType.income : TransactionType.expense,
        note: _random.nextBool() ? 'Auto-generated transaction note for $title' : null,
        isRecurring: _random.nextDouble() < 0.1,
      ));
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  static List<Budget> _generateBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();

    final List<Budget> result = [];
    final budgetLimits = [500.0, 300.0, 800.0, 200.0, 400.0, 150.0, 100.0, 600.0, 1200.0, 250.0, 350.0, 180.0, 120.0, 90.0, 450.0];

    for (int i = 0; i < 15 && i < expenseCategories.length; i++) {
      final cat = expenseCategories[i];
      final limit = budgetLimits[i % budgetLimits.length];
      final spent = limit * (0.3 + _random.nextDouble() * 0.9);

      result.add(Budget(
        id: 'bud_$i',
        categoryId: cat.id,
        categoryName: cat.name,
        limit: limit,
        spent: double.parse(spent.toStringAsFixed(2)),
        startDate: startOfMonth,
        endDate: endOfMonth,
        isActive: true,
      ));
    }

    return result;
  }

  static List<Subscription> _generateSubscriptions() {
    final now = DateTime.now();

    return [
      Subscription(
        id: 'sub_0', name: 'Netflix', amount: 15.99,
        cycle: BillingCycle.monthly, startDate: now.subtract(const Duration(days: 365)),
        nextBillingDate: DateTime(now.year, now.month + 1, 5),
        categoryId: 'cat_8', categoryName: 'Entertainment',
        status: SubscriptionStatus.active, note: 'Premium Plan',
      ),
      Subscription(
        id: 'sub_1', name: 'Spotify', amount: 9.99,
        cycle: BillingCycle.monthly, startDate: now.subtract(const Duration(days: 200)),
        nextBillingDate: DateTime(now.year, now.month + 1, 12),
        categoryId: 'cat_8', categoryName: 'Entertainment',
        status: SubscriptionStatus.active, note: 'Individual Plan',
      ),
      Subscription(
        id: 'sub_2', name: 'Gym Membership', amount: 49.99,
        cycle: BillingCycle.monthly, startDate: now.subtract(const Duration(days: 90)),
        nextBillingDate: DateTime(now.year, now.month + 1, 1),
        categoryId: 'cat_18', categoryName: 'Fitness',
        status: SubscriptionStatus.active,
      ),
      Subscription(
        id: 'sub_3', name: 'iCloud Storage', amount: 2.99,
        cycle: BillingCycle.monthly, startDate: now.subtract(const Duration(days: 500)),
        nextBillingDate: DateTime(now.year, now.month + 1, 20),
        categoryId: 'cat_17', categoryName: 'Subscriptions',
        status: SubscriptionStatus.active, note: '200GB Plan',
      ),
      Subscription(
        id: 'sub_4', name: 'Adobe Creative Cloud', amount: 54.99,
        cycle: BillingCycle.monthly, startDate: now.subtract(const Duration(days: 180)),
        nextBillingDate: DateTime(now.year, now.month + 1, 15),
        categoryId: 'cat_17', categoryName: 'Subscriptions',
        status: SubscriptionStatus.active, note: 'All Apps Plan',
      ),
      Subscription(
        id: 'sub_5', name: 'Amazon Prime', amount: 139.0,
        cycle: BillingCycle.yearly, startDate: now.subtract(const Duration(days: 300)),
        nextBillingDate: DateTime(now.year + 1, now.month, 5),
        categoryId: 'cat_7', categoryName: 'Shopping',
        status: SubscriptionStatus.active,
      ),
    ];
  }

  static List<Receipt> _generateReceipts() {
    final now = DateTime.now();
    final merchants = [
      'Walmart', 'Target', 'Costco', 'Whole Foods', 'Trader Joe\'s',
      'Starbucks', 'Amazon', 'Best Buy', 'Home Depot', 'CVS Pharmacy',
      'Kroger', 'Safeway', 'Walgreens', 'Macy\'s', 'Nike',
      'Apple Store', 'Shell Gas', 'Chevron', 'McDonald\'s', 'Chipotle',
    ];

    final itemNames = [
      'Organic Milk', 'Whole Wheat Bread', 'Fresh Salmon', 'Brown Rice',
      'Olive Oil', 'Greek Yogurt', 'Chicken Breast', 'Mixed Vegetables',
      'Coffee Beans', 'Orange Juice', 'Pasta', 'Tomato Sauce',
      'Avocados', 'Bananas', 'Apples', 'Cheese Block',
      'Paper Towels', 'Hand Soap', 'Shampoo', 'Toothpaste',
    ];

    final List<Receipt> result = [];

    for (int i = 0; i < 20; i++) {
      final daysAgo = _random.nextInt(90);
      final merchant = merchants[i % merchants.length];
      final numItems = 2 + _random.nextInt(6);

      final List<ReceiptItem> items = [];
      double total = 0;

      for (int j = 0; j < numItems; j++) {
        final qty = 1 + _random.nextInt(3);
        final price = 2.0 + _random.nextInt(25).toDouble() + _random.nextDouble();
        final unitPrice = double.parse(price.toStringAsFixed(2));
        final totalPrice = double.parse((unitPrice * qty).toStringAsFixed(2));
        total += totalPrice;

        items.add(ReceiptItem(
          name: itemNames[_random.nextInt(itemNames.length)],
          quantity: qty,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
        ));
      }

      final tax = double.parse((total * 0.08).toStringAsFixed(2));

      result.add(Receipt(
        id: 'rcp_$i',
        merchantName: merchant,
        date: now.subtract(Duration(days: daysAgo)),
        totalAmount: double.parse((total + tax).toStringAsFixed(2)),
        taxAmount: tax,
        categoryId: 'cat_13',
        categoryName: 'Groceries',
        items: items,
        note: _random.nextBool() ? 'Shopping trip at $merchant' : null,
      ));
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  static List<MonthlyReport> _generateMonthlyReports() {
    final now = DateTime.now();
    final List<MonthlyReport> result = [];

    for (int i = 0; i < 12; i++) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;

      final income = 4500.0 + _random.nextInt(3000).toDouble();
      final expense = 2500.0 + _random.nextInt(2500).toDouble();
      final savings = income - expense;
      final savingsRate = savings / income;

      final breakdowns = <CategoryBreakdown>[];
      final expCats = categories.where((c) => c.type == CategoryType.expense).toList();
      double totalCatAmount = 0;

      for (int j = 0; j < 5; j++) {
        final catAmount = 200.0 + _random.nextInt(600).toDouble();
        totalCatAmount += catAmount;
        breakdowns.add(CategoryBreakdown(
          categoryId: expCats[j].id,
          categoryName: expCats[j].name,
          amount: double.parse(catAmount.toStringAsFixed(2)),
          percentage: 0,
        ));
      }

      final normalizedBreakdowns = breakdowns
          .map((b) => CategoryBreakdown(
                categoryId: b.categoryId,
                categoryName: b.categoryName,
                amount: b.amount,
                percentage: double.parse((b.amount / totalCatAmount).toStringAsFixed(3)),
              ))
          .toList();

      result.add(MonthlyReport(
        id: 'report_$i',
        year: year,
        month: adjustedMonth,
        totalIncome: double.parse(income.toStringAsFixed(2)),
        totalExpense: double.parse(expense.toStringAsFixed(2)),
        savings: double.parse(savings.toStringAsFixed(2)),
        savingsRate: double.parse(savingsRate.toStringAsFixed(3)),
        transactionCount: 15 + _random.nextInt(25),
        topCategories: normalizedBreakdowns,
        averageDailySpend: double.parse((expense / 30).toStringAsFixed(2)),
      ));
    }

    return result;
  }

  static Map<String, double> getSpendingTrend() {
    final map = <String, double>{};
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 5; i >= 0; i--) {
      final month = now.month - i;
      final adjustedMonth = month <= 0 ? month + 12 : month;
      map[monthNames[adjustedMonth - 1]] = 2000.0 + _random.nextInt(3000).toDouble();
    }

    return map;
  }

  static Map<String, double> getIncomeTrend() {
    final map = <String, double>{};
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 5; i >= 0; i--) {
      final month = now.month - i;
      final adjustedMonth = month <= 0 ? month + 12 : month;
      map[monthNames[adjustedMonth - 1]] = 4000.0 + _random.nextInt(3000).toDouble();
    }

    return map;
  }

  static double getTotalBalance() {
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return income - expense;
  }

  static double getMonthlyIncome() {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getMonthlyExpense() {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static List<Transaction> getRecentTransactions({int limit = 10}) {
    return transactions.take(limit).toList();
  }

  static Map<String, double> getCategoryBreakdown() {
    final now = DateTime.now();
    final thisMonthExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.month == now.month &&
        t.date.year == now.year);

    final map = <String, double>{};
    for (final t in thisMonthExpenses) {
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    return map;
  }
}
