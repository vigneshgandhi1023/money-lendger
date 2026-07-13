import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/loan.dart';
import '../providers/notification_providers.dart';

/// Notifications screen showing due and overdue loans.
///
/// Groups loans by urgency: Overdue → Due Today → Due Tomorrow.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(notificationDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: data.totalCount == 0
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All clear!',
              subtitle: 'No due or overdue loans right now',
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
                vertical: 8,
              ),
              children: [
                // Overdue section
                if (data.overdue.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Overdue',
                    count: data.overdue.length,
                    color: AppColors.moneyOut,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 8),
                  ...data.overdue.map((loan) => _NotificationTile(
                        loan: loan,
                        urgency: _Urgency.overdue,
                      )),
                  const SizedBox(height: 20),
                ],

                // Due Today
                if (data.dueToday.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Due Today',
                    count: data.dueToday.length,
                    color: AppColors.warning,
                    icon: Icons.today_rounded,
                  ),
                  const SizedBox(height: 8),
                  ...data.dueToday.map((loan) => _NotificationTile(
                        loan: loan,
                        urgency: _Urgency.today,
                      )),
                  const SizedBox(height: 20),
                ],

                // Due Tomorrow
                if (data.dueTomorrow.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Due Tomorrow',
                    count: data.dueTomorrow.length,
                    color: AppColors.info,
                    icon: Icons.event_rounded,
                  ),
                  const SizedBox(height: 8),
                  ...data.dueTomorrow.map((loan) => _NotificationTile(
                        loan: loan,
                        urgency: _Urgency.tomorrow,
                      )),
                ],

                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

enum _Urgency { overdue, today, tomorrow }

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(color: color),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Loan loan;
  final _Urgency urgency;

  const _NotificationTile({required this.loan, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customer = StorageService.getCustomer(loan.customerId);

    Color borderColor;
    switch (urgency) {
      case _Urgency.overdue:
        borderColor = AppColors.moneyOut.withValues(alpha: 0.3);
        break;
      case _Urgency.today:
        borderColor = AppColors.warning.withValues(alpha: 0.3);
        break;
      case _Urgency.tomorrow:
        borderColor = AppColors.info.withValues(alpha: 0.15);
        break;
    }

    return GestureDetector(
      onTap: () => context.push('/loans/${loan.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            CustomerAvatar(
              name: customer?.fullName ?? '?',
              photoPath: customer?.photoPath,
              size: 40,
              fontSize: 14,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer?.fullName ?? 'Unknown',
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    DateFormatter.formatDueStatus(loan.dueDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: urgency == _Urgency.overdue
                          ? AppColors.moneyOut
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatCompact(loan.remainingBalance),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
