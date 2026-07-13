import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/stat_card.dart';

/// Dashboard summary KPI cards grid.
///
/// Displays 5 key metrics in a 2-column grid with staggered animations:
/// Total Lent, Outstanding, Collected Today, Active Loans, Overdue Loans.
class SummaryCards extends StatelessWidget {
  final double totalLent;
  final double totalOutstanding;
  final double collectedToday;
  final int activeLoans;
  final int overdueLoans;

  const SummaryCards({
    super.key,
    required this.totalLent,
    required this.totalOutstanding,
    required this.collectedToday,
    required this.activeLoans,
    required this.overdueLoans,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row: 2 cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Money Lent',
                value: CurrencyFormatter.formatShort(totalLent),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.primaryLight,
                animationDelay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Total Outstanding',
                value: CurrencyFormatter.formatShort(totalOutstanding),
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.moneyOut,
                animationDelay: 100,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row: 3 cards (collected + active + overdue)
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Collected Today',
                value: CurrencyFormatter.formatShort(collectedToday),
                icon: Icons.payments_rounded,
                iconColor: AppColors.moneyIn,
                animationDelay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Active Loans',
                value: activeLoans.toString(),
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.info,
                animationDelay: 300,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Overdue card — full width for emphasis
        if (overdueLoans > 0)
          StatCard(
            label: 'Overdue Loans — Needs Attention',
            value: overdueLoans.toString(),
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.moneyOut,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.moneyOutDark.withValues(alpha: 0.3)
                : AppColors.moneyOutLight.withValues(alpha: 0.6),
            animationDelay: 400,
          ).animate().shimmer(
                duration: 2000.ms,
                delay: 1000.ms,
                color: AppColors.moneyOut.withValues(alpha: 0.05),
              ),
      ],
    );
  }
}
