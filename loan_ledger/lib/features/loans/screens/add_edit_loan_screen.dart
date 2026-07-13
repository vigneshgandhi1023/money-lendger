import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../models/customer.dart';
import '../../../models/enums.dart';
import '../../../models/loan.dart';
import '../providers/loan_providers.dart';
import '../widgets/interest_calculator.dart';

/// Add/Edit loan form screen.
///
/// Supports pre-selecting a customer, real-time interest calculation,
/// and date pickers for loan/due dates.
class AddEditLoanScreen extends ConsumerStatefulWidget {
  final String? loanId;
  final String? customerId;

  const AddEditLoanScreen({super.key, this.loanId, this.customerId});

  bool get isEditing => loanId != null;

  @override
  ConsumerState<AddEditLoanScreen> createState() =>
      _AddEditLoanScreenState();
}

class _AddEditLoanScreenState extends ConsumerState<AddEditLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  final _notesController = TextEditingController();

  Customer? _selectedCustomer;
  InterestType _interestType = InterestType.monthly;
  DateTime _loanDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _interestController.text =
        AppConstants.defaultInterestRate.toString();

    if (widget.isEditing) {
      final loan = StorageService.getLoan(widget.loanId!);
      if (loan != null) {
        _amountController.text = loan.loanAmount.toString();
        _interestController.text = loan.interestRate.toString();
        _interestType = loan.interestType;
        _loanDate = loan.loanDate;
        _dueDate = loan.dueDate;
        _notesController.text = loan.notes ?? '';
        _selectedCustomer = StorageService.getCustomer(loan.customerId);
      }
    } else if (widget.customerId != null) {
      _selectedCustomer = StorageService.getCustomer(widget.customerId!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isLoanDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isLoanDate ? _loanDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        if (isLoanDate) {
          _loanDate = picked;
          if (_dueDate.isBefore(_loanDate)) {
            _dueDate = _loanDate.add(const Duration(days: 30));
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _selectCustomer() async {
    final customers = StorageService.getAllCustomers();
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a customer first')),
      );
      return;
    }

    final selected = await showModalBottomSheet<Customer>(
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
                      Text('Select Customer',
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
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        leading: CustomerAvatar(
                          name: c.fullName,
                          photoPath: c.photoPath,
                          size: 40,
                          fontSize: 14,
                        ),
                        title: Text(c.fullName),
                        subtitle: Text(c.phoneNumber),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => Navigator.pop(context, c),
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
      setState(() => _selectedCustomer = selected);
    }
  }

  Future<void> _save() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final rate = double.parse(_interestController.text);

      if (widget.isEditing) {
        final existing = StorageService.getLoan(widget.loanId!);
        if (existing != null) {
          final updated = existing.copyWith(
            loanAmount: amount,
            interestRate: rate,
            dueDate: _dueDate,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );
          await StorageService.saveLoan(updated);
        }
      } else {
        final loan = Loan.create(
          id: const Uuid().v4(),
          customerId: _selectedCustomer!.id,
          loanAmount: amount,
          interestRate: rate,
          interestType: _interestType,
          loanDate: _loanDate,
          dueDate: _dueDate,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        await StorageService.saveLoan(loan);
      }

      refreshLoans(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.isEditing ? 'Loan updated' : 'Loan created'),
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
    final amount = double.tryParse(
        _amountController.text.replaceAll(',', ''));
    final rate = double.tryParse(_interestController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Loan' : 'New Loan'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer selector
              Text('Customer *', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: widget.isEditing ? null : _selectCustomer,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCustomer == null
                          ? theme.colorScheme.outline.withValues(alpha: 0.3)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _selectedCustomer != null
                      ? Row(
                          children: [
                            CustomerAvatar(
                              name: _selectedCustomer!.fullName,
                              photoPath: _selectedCustomer!.photoPath,
                              size: 36,
                              fontSize: 13,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedCustomer!.fullName,
                                      style: theme.textTheme.titleSmall),
                                  Text(_selectedCustomer!.phoneNumber,
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            if (!widget.isEditing)
                              Icon(Icons.chevron_right_rounded,
                                  color: theme.colorScheme.onSurfaceVariant),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.person_add_outlined,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text('Select customer',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Loan Amount
              TextFormField(
                controller: _amountController,
                validator: Validators.amount,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Loan Amount *',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Interest Rate & Type
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestController,
                      validator: Validators.interestRate,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate % *',
                        prefixIcon: Icon(Icons.percent_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<InterestType>(
                      value: _interestType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.calculate_outlined),
                      ),
                      items: InterestType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ))
                          .toList(),
                      onChanged: widget.isEditing
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _interestType = value);
                              }
                            },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Loan Date',
                      date: _loanDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Due Date',
                      date: _dueDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
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

              // Interest Calculator Preview
              InterestCalculator(
                loanAmount: amount,
                interestRate: rate,
                interestType: _interestType,
                loanDate: _loanDate,
                dueDate: _dueDate,
              ),

              const SizedBox(height: 28),

              // Save button
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing ? 'Save Changes' : 'Create Loan'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
