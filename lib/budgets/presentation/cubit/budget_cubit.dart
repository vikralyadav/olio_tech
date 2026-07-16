import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/budget.dart';
import '../../domain/usecases/budget_usecases.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgets getBudgets;
  final AddBudget addBudget;
  final UpdateBudget updateBudget;
  final DeleteBudget deleteBudget;

  BudgetCubit({
    required this.getBudgets,
    required this.addBudget,
    required this.updateBudget,
    required this.deleteBudget,
  }) : super(const BudgetState());

  Future<void> load() async {
    emit(state.copyWith(status: BudgetStatus.loading));
    try {
      final list = await getBudgets();
      emit(state.copyWith(status: BudgetStatus.loaded, budgets: list));
    } catch (e) {
      emit(state.copyWith(
          status: BudgetStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> create(Budget budget) async {
    await addBudget(budget);
    await load();
  }

  Future<void> edit(Budget budget) async {
    await updateBudget(budget);
    await load();
  }

  Future<void> remove(String id) async {
    await deleteBudget(id);
    await load();
  }
}
