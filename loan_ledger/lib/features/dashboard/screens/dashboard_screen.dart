import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/summary_cards.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/upcoming_dues.dart';
import '../widgets/overdue_customers.dart';

/// Main dashboard screen — the app's home.
///
/// Shows all KPI metrics, quick actions, recent transactions,
/// upcoming dues, and overdue loans at a glance.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ─── App Bar ─────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              toolbarHeight: 64,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Ledger',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                // Search
                IconButton(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                ),
                // Notifications
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: dataAsync.maybeWhen(
                    data: (data) => Badge(
                      isLabelVisible: data.overdueLoans > 0,
                      label: Text(data.overdueLoans.toString()),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    orElse: () => const Icon(Icons.notifications_outlined),
                  ),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ─── Content ─────────────────────────────────
            dataAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading dashboard: $err')),
              ),
              data: (data) => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // KPI Cards
                    SummaryCards(
                      totalLent: data.totalMoneyLent,
                      totalOutstanding: data.totalOutstanding,
                      collectedToday: data.collectedToday,
                      activeLoans: data.activeLoans,
                      overdueLoans: data.overdueLoans,
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const QuickActions(),

                    const SizedBox(height: 28),

                    // Overdue Loans (shown first for urgency)
                    if (data.overdueLoanslist.isNotEmpty) ...[
                      OverdueCustomers(overdueLoans: data.overdueLoanslist),
                      const SizedBox(height: 28),
                    ],

                    // Upcoming Dues
                    UpcomingDues(loans: data.upcomingDues),

                    const SizedBox(height: 28),

                    // Recent Transactions
                    RecentTransactions(payments: data.recentTransactions),

                    // Bottom padding for nav bar
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
