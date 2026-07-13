import 'package:flutter/material.dart';

import '../../../core/widgets/status_chip.dart';
import '../../../models/enums.dart';

/// Loan status chip — re-exports the core StatusChip for convenience.
class LoanStatusChip extends StatelessWidget {
  final LoanStatus status;
  final bool isOverdue;

  const LoanStatusChip({
    super.key,
    required this.status,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatusChip(status: status, isOverdue: isOverdue);
  }
}
