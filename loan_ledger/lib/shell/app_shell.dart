import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell with bottom navigation bar.
///
/// Wraps the 4 main tabs (Dashboard, Customers, Reports, Settings)
/// with a Material 3 navigation bar and handles tab switching.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    ('/', Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    ('/customers', Icons.people_rounded, Icons.people_outlined, 'Customers'),
    ('/reports', Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports'),
    ('/settings', Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.1),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index != currentIndex) {
              context.go(_tabs[index].$1);
            }
          },
          destinations: _tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.$3),
              selectedIcon: Icon(tab.$2),
              label: tab.$4,
            );
          }).toList(),
        ),
      ),
    );
  }
}
