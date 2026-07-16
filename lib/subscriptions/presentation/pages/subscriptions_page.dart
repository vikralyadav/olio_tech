import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/subscription.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/subscription_card.dart';
import 'subscription_form_page.dart';

class SubscriptionsPage extends StatefulWidget {
  final bool showAppBar;
  const SubscriptionsPage({super.key, this.showAppBar = true});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<SubscriptionCubit>();
    if (cubit.state.status == SubscriptionStatusState.initial) cubit.load();
  }

  void _openForm({Subscription? initial}) {
    final cubit = context.read<SubscriptionCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionFormPage(cubit: cubit, initial: initial),
      ),
    );
  }

  void _showActions(Subscription s) {
    final cubit = context.read<SubscriptionCubit>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _openForm(initial: s);
              },
            ),
            if (s.status == SubscriptionStatus.active)
              ListTile(
                leading: const Icon(Icons.pause_circle_outline),
                title: const Text('Pause'),
                onTap: () {
                  Navigator.pop(context);
                  cubit.setStatus(s, SubscriptionStatus.paused);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Resume'),
                onTap: () {
                  Navigator.pop(context);
                  cubit.setStatus(s, SubscriptionStatus.active);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Cancel subscription'),
              onTap: () {
                Navigator.pop(context);
                cubit.setStatus(s, SubscriptionStatus.cancelled);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                final ok = await showConfirmDialog(
                  context,
                  title: 'Delete Subscription',
                  message: 'Delete ${s.name}?',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (ok) cubit.remove(s.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubscriptionCubit>();
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Subscriptions'))
          : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_subscriptions',
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionListState>(
        builder: (context, state) {
          if (state.status == SubscriptionStatusState.loading &&
              state.subscriptions.isEmpty) {
            return const LoadingView(message: 'Loading subscriptions...');
          }
          if (state.status == SubscriptionStatusState.error) {
            return ErrorView(
                message: state.errorMessage ?? 'Failed', onRetry: cubit.load);
          }
          if (state.subscriptions.isEmpty) {
            return EmptyView(
              icon: Icons.subscriptions_outlined,
              title: 'No subscriptions',
              message: 'Track recurring payments in one place.',
              actionLabel: 'Add Subscription',
              onAction: () => _openForm(),
            );
          }
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _SummaryCard(state: state),
                const SizedBox(height: 16),
                ...state.upcoming.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SubscriptionCard(
                      subscription: s,
                      onTap: () => _showActions(s),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final SubscriptionListState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Subscriptions',
                style: TextStyle(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metric(context, 'Monthly',
                      AppFormatters.currency(state.monthlyTotal)),
                ),
                Container(
                    width: 1,
                    height: 40,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.2)),
                Expanded(
                  child: _metric(context, 'Yearly',
                      AppFormatters.currency(state.yearlyTotal)),
                ),
                Container(
                    width: 1,
                    height: 40,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.2)),
                Expanded(
                  child: _metric(context, 'Count', '${state.active.length}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                fontSize: 12)),
      ],
    );
  }
}
