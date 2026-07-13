import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../theme/color_schemes.dart';

/// Status chip widget for loan status display.
///
/// Renders a color-coded chip for Active, Overdue, or Closed status.
class StatusChip extends StatelessWidget {
  final LoanStatus status;
  final bool isOverdue;
  final double fontSize;

  const StatusChip({
    super.key,
    required this.status,
    this.isOverdue = false,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String label;

    if (isOverdue && status != LoanStatus.closed) {
      chipColor = AppColors.moneyOut.withValues(alpha: 0.12);
      textColor = AppColors.moneyOut;
      label = 'Overdue';
    } else {
      switch (status) {
        case LoanStatus.active:
          chipColor = AppColors.info.withValues(alpha: 0.12);
          textColor = AppColors.info;
          label = 'Active';
          break;
        case LoanStatus.overdue:
          chipColor = AppColors.moneyOut.withValues(alpha: 0.12);
          textColor = AppColors.moneyOut;
          label = 'Overdue';
          break;
        case LoanStatus.closed:
          chipColor = AppColors.moneyIn.withValues(alpha: 0.12);
          textColor = AppColors.moneyIn;
          label = 'Closed';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
