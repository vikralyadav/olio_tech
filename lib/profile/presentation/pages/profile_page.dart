import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/ auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/entities/category.dart';
import '../../../core/routes/routes_name.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/confirm_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _ProfileHeader(),
          const SizedBox(height: 16),
          _sectionLabel(context, 'Preferences'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: Text(mode == ThemeMode.system
                    ? 'Following system'
                    : (isDark ? 'On' : 'Off')),
                value: isDark,
                onChanged: (v) => context.read<ThemeCubit>().toggleDark(v),
              );
            },
          ),
          _CurrencyTile(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.notifications),
          ),
          const Divider(),
          _sectionLabel(context, 'Data'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('CSV, JSON or summary'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, RouteNames.export),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categories'),
            subtitle: const Text('20 categories available'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCategories(context),
          ),
          const Divider(),
          _sectionLabel(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy policy (demo)')),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _CategoriesPage()),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final email = state.userEmail ?? 'user@olio.app';
        final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';
        return Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primaryContainer,
              child: Text(initial,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer)),
            ),
            const SizedBox(height: 12),
            Text(email.split('@').first,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(email,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        );
      },
    );
  }
}

class _CurrencyTile extends StatefulWidget {
  @override
  State<_CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<_CurrencyTile> {
  static const _currencies = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
  };
  String _selected = 'USD';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Currency'),
      subtitle: Text('$_selected (${_currencies[_selected]})'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _currencies.entries
                  .map((e) => RadioListTile<String>(
                        title: Text('${e.key} (${e.value})'),
                        value: e.key,
                        groupValue: _selected,
                        onChanged: (v) {
                          setState(() => _selected = v!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Currency set to $v (demo)')),
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage();

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: c.color.withValues(alpha: 0.15),
                    child: Icon(c.icon, color: c.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          c.type == CategoryType.income ? 'Income' : 'Expense',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
