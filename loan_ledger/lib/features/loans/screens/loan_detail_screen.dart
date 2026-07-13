import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/enums.dart';
import '../providers/loan_providers.dart';
import '../../customers/widgets/payment_history.dart';

/// Loan detail screen — full view of a single loan.
///
/// Shows loan breakdown, customer info, payment history,
/// and action buttons (receive payment, edit, delete).
class LoanDetailScreen extends ConsumerWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loan = ref.watch(loanProvider(loanId));
    final theme = Theme.of(context);

    if (loan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Loan not found')),
      );
    }

    final customer = StorageService.getCustomer(loan.customerId);
    final payments = StorageService.getPaymentsForLoan(loanId);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Loan Details'),
            actions: [
              IconButton(
                onPressed: () => context.push('/loans/$loanId/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _handleMenu(context, ref, v),
                itemBuilder: (_) => [
                  if (loan.status != LoanStatus.closed)
                    const PopupMenuItem(
                      value: 'close',
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline,
                            color: AppColors.moneyIn),
                        title: Text('Mark as Closed'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline,
                          color: AppColors.moneyOut),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.moneyOut)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Customer header
                if (customer != null)
                  GestureDetector(
                    onTap: () =>
                        context.push('/customers/${customer.id}'),
                    child: Row(
                      children: [
                        CustomerAvatar(
                          name: customer.fullName,
                          photoPath: customer.photoPath,
                          size: 44,
                          fontSize: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.fullName,
                                  style: theme.textTheme.titleMedium),
                              Text(customer.phoneNumber,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        StatusChip(
                          status: loan.status,
                          isOverdue: loan.isOverdue,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Financial breakdown
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Loan Amount',
                        value: CurrencyFormatter.formatShort(loan.loanAmount),
                        icon: Icons.account_balance_outlined,
                        iconColor: AppColors.primaryLight,
                        animationDelay: 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Total Interest',
                        value: CurrencyFormatter.formatShort(loan.totalInterest),
                        icon: Icons.percent_rounded,
                        iconColor: AppColors.warning,
                        animationDelay: 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Repayable',
                        value: CurrencyFormatter.formatShort(loan.totalRepayable),
                        icon: Icons.calculate_outlined,
                        iconColor: AppColors.info,
                        animationDelay: 200,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Outstanding',
                        value: CurrencyFormatter.formatShort(loan.remainingBalance),
                        icon: Icons.money_off_rounded,
                        iconColor: loan.remainingBalance > 0
                            ? AppColors.moneyOut
                            : AppColors.moneyIn,
                        animationDelay: 300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress
                Text('Repayment Progress', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: loan.repaymentProgress,
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      loan.status == LoanStatus.closed
                          ? AppColors.moneyIn
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(loan.repaymentProgress * 100).toStringAsFixed(0)}% paid',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${CurrencyFormatter.formatCompact(loan.totalPaid)} of ${CurrencyFormatter.formatCompact(loan.totalRepayable)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Loan details
                _DetailSection(
                  items: [
                    _DetailItem('Interest Rate',
                        '${loan.interestRate}% ${loan.interestType.suffix}'),
                    _DetailItem('Interest Type', loan.interestType.label),
                    _DetailItem(
                        'Loan Date', DateFormatter.format(loan.loanDate)),
                    _DetailItem('Due Date', DateFormatter.format(loan.dueDate)),
                    _DetailItem(
                        'Due Status', DateFormatter.formatDueStatus(loan.dueDate)),
                    if (loan.notes != null && loan.notes!.isNotEmpty)
                      _DetailItem('Notes', loan.notes!),
                  ],
                ),

                const SizedBox(height: 24),

                // Payments for this loan
                if (payments.isNotEmpty) ...[
                  Text(
                    'Payments (${payments.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...payments.map((p) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.moneyIn.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: AppColors.moneyIn, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormatter.format(p.paymentDate),
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontSize: 13),
                                  ),
                                  if (p.notes != null)
                                    Text(p.notes!,
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(p.amount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.moneyIn,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: loan.remainingBalance > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                  '/payments/receive?loanId=$loanId&customerId=${loan.customerId}'),
              icon: const Icon(Icons.payments_rounded, size: 20),
              label: const Text('Receive Payment'),
            )
          : null,
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'close':
        final loan = StorageService.getLoan(loanId);
        if (loan != null) {
          loan.statusName = 'closed';
          loan.updatedAt = DateTime.now();
          await StorageService.saveLoan(loan);
          refreshLoans(ref);
        }
        break;
      case 'delete':
        final confirmed = await ConfirmDialog.show(
          context,
          title: 'Delete Loan?',
          description:
              'This will permanently delete this loan and all its payments.',
          icon: Icons.delete_outline,
        );
        if (confirmed && context.mounted) {
          await StorageService.deleteLoan(loanId);
          refreshLoans(ref);
          if (context.mounted) context.pop();
        }
        break;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final List<_DetailItem> items;

  const _DetailSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      item.value,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 10),
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);
}
