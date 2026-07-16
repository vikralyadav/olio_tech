import 'package:equatable/equatable.dart';

import '../../../core/entities/transaction.dart';

enum TransactionStatus { initial, loading, loaded, error }

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc }

extension TransactionSortLabel on TransactionSort {
  String get label {
    switch (this) {
      case TransactionSort.dateDesc:
        return 'Newest first';
      case TransactionSort.dateAsc:
        return 'Oldest first';
      case TransactionSort.amountDesc:
        return 'Amount: high to low';
      case TransactionSort.amountAsc:
        return 'Amount: low to high';
    }
  }
}

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<Transaction> all;
  final String searchQuery;
  final TransactionType? typeFilter;
  final String? categoryFilter;
  final TransactionSort sort;
  final int page;
  final int pageSize;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.all = const [],
    this.searchQuery = '',
    this.typeFilter,
    this.categoryFilter,
    this.sort = TransactionSort.dateDesc,
    this.page = 1,
    this.pageSize = 15,
    this.errorMessage,
  });

  /// Full result set after search + filters, sorted.
  List<Transaction> get filtered {
    final q = searchQuery.trim().toLowerCase();
    var list = all.where((t) {
      if (typeFilter != null && t.type != typeFilter) return false;
      if (categoryFilter != null && t.categoryId != categoryFilter) return false;
      if (q.isNotEmpty) {
        final hay =
            '${t.title} ${t.categoryName} ${t.note ?? ''}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case TransactionSort.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSort.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSort.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSort.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  /// Paginated slice currently visible.
  List<Transaction> get visible =>
      filtered.take(page * pageSize).toList();

  bool get hasMore => visible.length < filtered.length;

  bool get hasActiveFilters =>
      typeFilter != null || categoryFilter != null || searchQuery.isNotEmpty;

  double get filteredIncome => filtered
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get filteredExpense => filtered
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? all,
    String? searchQuery,
    TransactionType? typeFilter,
    bool clearTypeFilter = false,
    String? categoryFilter,
    bool clearCategoryFilter = false,
    TransactionSort? sort,
    int? page,
    int? pageSize,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      all: all ?? this.all,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      categoryFilter:
          clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        all,
        searchQuery,
        typeFilter,
        categoryFilter,
        sort,
        page,
        pageSize,
        errorMessage,
      ];
}
