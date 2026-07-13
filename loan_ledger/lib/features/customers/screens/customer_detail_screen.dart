import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/customer_providers.dart';
import '../widgets/loan_timeline.dart';
import '../widgets/payment_history.dart';

/// Customer detail screen — full profile view.
///
/// Shows customer info, financial summary cards (borrowed, paid,
/// remaining, active loans), loan timeline, and payment history.
class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider(customerId));
    final theme = Theme.of(context);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Customer not found')),
      );
    }

    final totalBorrowed = StorageService.totalBorrowedByCustomer(customerId);
    final totalPaid = StorageService.totalPaidByCustomer(customerId);
    final remaining = totalBorrowed - totalPaid;
    final activeLoans = StorageService.getLoansForCustomer(customerId)
        .where((l) => l.statusName != 'closed')
        .length;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            title: Text(customer.fullName),
            actions: [
              IconButton(
                onPressed: () =>
                    context.push('/customers/${customer.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, ref, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'add_loan',
                    child: ListTile(
                      leading: Icon(Icons.add_card_rounded),
                      title: Text('New Loan'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'call',
                    child: ListTile(
                      leading: Icon(Icons.phone_rounded),
                      title: Text('Call'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: AppColors.moneyOut),
                      title: Text('Delete', style: TextStyle(color: AppColors.moneyOut)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Customer Header
                Center(
                  child: Column(
                    children: [
                      CustomerAvatar(
                        name: customer.fullName,
                        photoPath: customer.photoPath,
                        size: 72,
                        fontSize: 26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customer.fullName,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            customer.phoneNumber,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (customer.address != null &&
                          customer.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                customer.address!,
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Financial Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Borrowed',
                        value: CurrencyFormatter.formatShort(totalBorrowed),
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.info,
                        animationDelay: 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Total Paid',
                        value: CurrencyFormatter.formatShort(totalPaid),
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppColors.moneyIn,
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
                        label: 'Remaining Balance',
                        value: CurrencyFormatter.formatShort(remaining > 0 ? remaining : 0),
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: remaining > 0 ? AppColors.moneyOut : AppColors.moneyIn,
                        animationDelay: 200,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Active Loans',
                        value: activeLoans.toString(),
                        icon: Icons.receipt_long_outlined,
                        iconColor: AppColors.primaryLight,
                        animationDelay: 300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Loan Timeline
                LoanTimeline(customerId: customerId),

                const SizedBox(height: 24),

                // Payment History
                PaymentHistory(customerId: customerId),

                // Notes
                if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Notes', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      customer.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // Receive Payment FAB
      floatingActionButton: remaining > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                  '/payments/receive?customerId=$customerId'),
              icon: const Icon(Icons.payments_rounded, size: 20),
              label: const Text('Receive Payment'),
            )
          : null,
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'add_loan':
        context.push('/loans/add?customerId=$customerId');
        break;
      case 'call':
        // Would use url_launcher here
        break;
      case 'delete':
        final confirmed = await ConfirmDialog.show(
          context,
          title: 'Delete Customer?',
          description:
              'This will permanently delete this customer and all their loans and payments. This action cannot be undone.',
          confirmLabel: 'Delete',
          icon: Icons.delete_outline,
        );
        if (confirmed && context.mounted) {
          await StorageService.deleteCustomer(customerId);
          refreshCustomers(ref);
          if (context.mounted) context.pop();
        }
        break;
    }
  }
}
