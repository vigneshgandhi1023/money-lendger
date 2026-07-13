import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/enums.dart';
import '../providers/report_providers.dart';
import '../widgets/collection_chart.dart';
import '../widgets/report_card.dart';

/// Reports screen — tab 3 in the bottom navigation.
///
/// Shows collection summaries (daily/weekly/monthly),
/// outstanding and closed loan counts, and PDF export.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.daily;

  DateTimeRange _getRange(ReportPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case ReportPeriod.daily:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case ReportPeriod.weekly:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
        );
      case ReportPeriod.monthly:
        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 1);
        return DateTimeRange(start: monthStart, end: monthEnd);
    }
  }

  Map<String, double> _getChartData(ReportPeriod period) {
    final range = _getRange(period);
    final payments = StorageService.getPaymentsInRange(range.start, range.end);
    final dateFormat = DateFormat('d');

    final data = <String, double>{};

    switch (period) {
      case ReportPeriod.daily:
        // Hourly breakdown
        for (int h = 0; h < 24; h += 4) {
          final label = '${h}h';
          data[label] = payments
              .where((p) => p.paymentDate.hour >= h && p.paymentDate.hour < h + 4)
              .fold(0.0, (sum, p) => sum + p.amount);
        }
        break;
      case ReportPeriod.weekly:
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        for (int d = 1; d <= 7; d++) {
          final day = range.start.add(Duration(days: d - 1));
          data[days[d - 1]] = payments
              .where((p) =>
                  p.paymentDate.year == day.year &&
                  p.paymentDate.month == day.month &&
                  p.paymentDate.day == day.day)
              .fold(0.0, (sum, p) => sum + p.amount);
        }
        break;
      case ReportPeriod.monthly:
        // Week by week
        for (int w = 0; w < 4; w++) {
          final weekStart = range.start.add(Duration(days: w * 7));
          final weekEnd = weekStart.add(const Duration(days: 7));
          data['W${w + 1}'] = payments
              .where((p) =>
                  !p.paymentDate.isBefore(weekStart) &&
                  p.paymentDate.isBefore(weekEnd))
              .fold(0.0, (sum, p) => sum + p.amount);
        }
        break;
    }

    return data;
  }

  Future<void> _exportPdf() async {
    final range = _getRange(_period);
    final payments = StorageService.getPaymentsInRange(range.start, range.end);
    final total = payments.fold(0.0, (sum, p) => sum + p.amount);

    try {
      final pdfData = await ExportService.generateCollectionReport(
        title: '${_period.label} Collection Report',
        startDate: range.start,
        endDate: range.end,
        payments: payments,
        totalCollected: total,
      );

      await ExportService.sharePdf(
        pdfData,
        'loan_ledger_${_period.name}_report.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Update provider range when period changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportDateRangeProvider.notifier).state = _getRange(_period);
    });

    final payments = ref.watch(collectionReportProvider);
    final total = ref.watch(periodTotalProvider);
    final outstanding = ref.watch(outstandingLoansReportProvider);
    final closed = ref.watch(closedLoansReportProvider);
    final totalOutstanding = outstanding.fold(
        0.0, (sum, l) => sum + l.remainingBalance);
    final chartData = _getChartData(_period);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Reports', style: theme.textTheme.headlineMedium),
            actions: [
              IconButton(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                tooltip: 'Export PDF',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Period selector
                Row(
                  children: ReportPeriod.values.map((period) {
                    final isSelected = _period == period;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: period != ReportPeriod.monthly ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _period = period),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                period.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Total collected
                ReportCard(
                  title: '${_period.label} Collection',
                  value: CurrencyFormatter.format(total),
                  subtitle: '${payments.length} transactions',
                  icon: Icons.payments_rounded,
                  color: AppColors.moneyIn,
                ),

                const SizedBox(height: 16),

                // Chart
                CollectionChart(data: chartData),

                const SizedBox(height: 20),

                // Outstanding & Closed
                Row(
                  children: [
                    Expanded(
                      child: ReportCard(
                        title: 'Outstanding',
                        value: CurrencyFormatter.formatShort(totalOutstanding),
                        subtitle: '${outstanding.length} loans',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.moneyOut,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReportCard(
                        title: 'Closed',
                        value: '${closed.length}',
                        subtitle: 'loans',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.moneyIn,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
