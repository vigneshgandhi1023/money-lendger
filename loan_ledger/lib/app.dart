import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_providers.dart';

/// Root widget for Loan Ledger.
///
/// Configures Material 3 theming (light/dark), routing via GoRouter,
/// and watches the user's theme preference from settings.
class LoanLedgerApp extends ConsumerWidget {
  const LoanLedgerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Loan Ledger',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: router,
    );
  }
}
