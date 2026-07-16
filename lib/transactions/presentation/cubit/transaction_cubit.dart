import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionCubit({
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(const TransactionState());

  Future<void> load() async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final list = await getTransactions();
      emit(state.copyWith(status: TransactionStatus.loaded, all: list, page: 1));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() => load();

  void search(String query) =>
      emit(state.copyWith(searchQuery: query, page: 1));

  void filterByType(TransactionType? type) {
    if (type == null) {
      emit(state.copyWith(clearTypeFilter: true, page: 1));
    } else {
      emit(state.copyWith(typeFilter: type, page: 1));
    }
  }

  void filterByCategory(String? categoryId) {
    if (categoryId == null) {
      emit(state.copyWith(clearCategoryFilter: true, page: 1));
    } else {
      emit(state.copyWith(categoryFilter: categoryId, page: 1));
    }
  }

  void setSort(TransactionSort sort) =>
      emit(state.copyWith(sort: sort, page: 1));

  void clearFilters() => emit(state.copyWith(
        clearTypeFilter: true,
        clearCategoryFilter: true,
        searchQuery: '',
        page: 1,
      ));

  void loadMore() {
    if (state.hasMore) {
      emit(state.copyWith(page: state.page + 1));
    }
  }

  Future<void> create(Transaction transaction) async {
    await addTransaction(transaction);
    final list = await getTransactions();
    emit(state.copyWith(all: list, status: TransactionStatus.loaded));
  }

  Future<void> edit(Transaction transaction) async {
    await updateTransaction(transaction);
    final list = await getTransactions();
    emit(state.copyWith(all: list, status: TransactionStatus.loaded));
  }

  Future<void> remove(String id) async {
    await deleteTransaction(id);
    final list = await getTransactions();
    emit(state.copyWith(all: list, status: TransactionStatus.loaded));
  }
}
