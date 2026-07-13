import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../models/customer.dart';
import '../../../models/enums.dart';
import '../../../models/loan.dart';
import '../../../models/payment.dart';
import '../providers/payment_providers.dart';
import '../../loans/providers/loan_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../widgets/payment_summary.dart';
import '../widgets/quick_amount_chips.dart';

/// Receive payment screen — optimized for minimal taps.
///
/// Can be opened with a pre-selected loan/customer, or allows
/// the user to select from active loans. Shows quick amount chips
/// and real-time balance preview.
class ReceivePaymentScreen extends ConsumerStatefulWidget {
  final String? loanId;
  final String? customerId;

  const ReceivePaymentScreen({super.key, this.loanId, this.customerId});

  @override
  ConsumerState<ReceivePaymentScreen> createState() =>
      _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends ConsumerState<ReceivePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Loan? _selectedLoan;
  Customer? _selectedCustomer;
  DateTime _paymentDate = DateTime.now();
  double? _quickAmount;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.loanId != null) {
      _selectedLoan = StorageService.getLoan(widget.loanId!);
      if (_selectedLoan != null) {
        _selectedCustomer =
            StorageService.getCustomer(_selectedLoan!.customerId);
      }
    } else if (widget.customerId != null) {
      _selectedCustomer = StorageService.getCustomer(widget.customerId!);
      // Auto-select the first active loan for this customer
      final loans = StorageService.getLoansForCustomer(widget.customerId!)
          .where((l) => l.statusName != 'closed')
          .toList();
      if (loans.length == 1) {
        _selectedLoan = loans.first;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectLoan() async {
    // Get all active loans
    final activeLoans = StorageService.getActiveLoans();
    if (activeLoans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active loans to receive payment for')),
      );
      return;
    }

    final selected = await showModalBottomSheet<Loan>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Loan',
                          style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeLoans.length,
                    itemBuilder: (context, index) {
                      final loan = activeLoans[index];
                      final customer =
                          StorageService.getCustomer(loan.customerId);

                      return ListTile(
                        leading: CustomerAvatar(
                          name: customer?.fullName ?? '?',
                          size: 40,
                          fontSize: 14,
                        ),
                        title: Text(customer?.fullName ?? 'Unknown'),
                        subtitle: Text(
                          '${CurrencyFormatter.format(loan.remainingBalance)} remaining',
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatCompact(loan.loanAmount),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => Navigator.pop(context, loan),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedLoan = selected;
        _selectedCustomer =
            StorageService.getCustomer(selected.customerId);
        _amountController.clear();
        _quickAmount = null;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedLoan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a loan')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));

      final isFullPayment =
          (amount - _selectedLoan!.remainingBalance).abs() < 0.01;

      // Create payment
      final payment = Payment.create(
        id: const Uuid().v4(),
        loanId: _selectedLoan!.id,
        customerId: _selectedLoan!.customerId,
        amount: amount,
        paymentDate: _paymentDate,
        paymentType: isFullPayment ? PaymentType.full : PaymentType.partial,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      await StorageService.savePayment(payment);

      // Update loan
      _selectedLoan!.totalPaid += amount;
      if (isFullPayment || _selectedLoan!.remainingBalance <= 0) {
        _selectedLoan!.statusName = 'closed';
      }
      _selectedLoan!.updatedAt = DateTime.now();
      await StorageService.saveLoan(_selectedLoan!);

      // Refresh providers
      refreshPayments(ref);
      refreshLoans(ref);
      ref.read(dashboardRefreshProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFullPayment
                ? 'Full payment received! Loan closed.'
                : 'Payment recorded successfully'),
            backgroundColor:
                isFullPayment ? AppColors.moneyIn : null,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentAmount = double.tryParse(
            _amountController.text.replaceAll(',', '')) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Payment'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Loan selector
              Text('Loan *', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectLoan,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedLoan == null
                          ? theme.colorScheme.outline.withValues(alpha: 0.3)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _selectedLoan != null
                      ? Row(
                          children: [
                            CustomerAvatar(
                              name: _selectedCustomer?.fullName ?? '?',
                              size: 36,
                              fontSize: 13,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer?.fullName ?? 'Unknown',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Outstanding: ${CurrencyFormatter.format(_selectedLoan!.remainingBalance)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.moneyOut,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: theme.colorScheme.onSurfaceVariant),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text('Select a loan',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                ),
              ),

              if (_selectedLoan != null) ...[
                const SizedBox(height: 20),

                // Quick amount chips
                Text('Quick Select', style: theme.textTheme.labelLarge),
                const SizedBox(height: 10),
                QuickAmountChips(
                  remainingBalance: _selectedLoan!.remainingBalance,
                  selectedAmount: _quickAmount,
                  onSelect: (amount) {
                    setState(() {
                      _quickAmount = amount;
                      _amountController.text =
                          CurrencyFormatter.formatPlain(amount);
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Amount input
                TextFormField(
                  controller: _amountController,
                  validator: (v) => Validators.paymentAmount(
                      v, _selectedLoan!.remainingBalance),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount *',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                  onChanged: (_) => setState(() => _quickAmount = null),
                ),

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                // Payment summary
                if (paymentAmount > 0)
                  PaymentSummary(
                    remainingBalance: _selectedLoan!.remainingBalance,
                    paymentAmount: paymentAmount,
                  ),
              ],

              const SizedBox(height: 28),

              // Confirm button
              ElevatedButton.icon(
                onPressed:
                    _saving || _selectedLoan == null ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(_saving ? 'Recording...' : 'Confirm Payment'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
