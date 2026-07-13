import 'package:hive/hive.dart';

import 'enums.dart';

part 'loan.g.dart';

/// Represents a loan given to a customer.
///
/// Each loan tracks principal amount, interest, dates, and status.
/// Outstanding balance and interest are computed dynamically from
/// the loan parameters and associated [Payment]s.
@HiveType(typeId: 1)
class Loan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(12)
  final String tenantId;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final double loanAmount;

  @HiveField(3)
  final double interestRate;

  @HiveField(4)
  final String interestTypeName;

  @HiveField(5)
  final DateTime loanDate;

  @HiveField(6)
  final DateTime dueDate;

  @HiveField(7)
  String statusName;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  double totalPaid;

  Loan({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.loanAmount,
    required this.interestRate,
    required this.interestTypeName,
    required this.loanDate,
    required this.dueDate,
    required this.statusName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.totalPaid = 0.0,
  });

  // ─── Enum Getters ──────────────────────────────────────

  InterestType get interestType =>
      InterestType.values.firstWhere((e) => e.name == interestTypeName);

  LoanStatus get status =>
      LoanStatus.values.firstWhere((e) => e.name == statusName);

  set status(LoanStatus value) => statusName = value.name;

  set interestType(InterestType value) =>
      throw UnsupportedError('Interest type cannot be changed after creation');

  // ─── Computed Properties ───────────────────────────────

  /// Calculate total interest based on interest type.
  double get totalInterest {
    switch (interestType) {
      case InterestType.flat:
        return loanAmount * (interestRate / 100);

      case InterestType.monthly:
        final months = _monthsBetween(loanDate, dueDate);
        return loanAmount * (interestRate / 100) * months;

      case InterestType.yearly:
        final years = dueDate.difference(loanDate).inDays / 365.0;
        return loanAmount * (interestRate / 100) * years;
    }
  }

  /// Total amount to be repaid (principal + interest).
  double get totalRepayable => loanAmount + totalInterest;

  /// Outstanding balance (total repayable minus payments received).
  double get outstandingAmount => totalRepayable - totalPaid;

  /// Remaining balance (same as outstanding, for display consistency).
  double get remainingBalance => outstandingAmount > 0 ? outstandingAmount : 0;

  /// Progress of repayment (0.0 to 1.0).
  double get repaymentProgress {
    if (totalRepayable == 0) return 1.0;
    return (totalPaid / totalRepayable).clamp(0.0, 1.0);
  }

  /// Whether this loan is overdue.
  bool get isOverdue {
    if (status == LoanStatus.closed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  /// Days until due (negative if overdue).
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  // ─── Factory ───────────────────────────────────────────

  factory Loan.create({
    required String id,
    required String tenantId,
    required String customerId,
    required double loanAmount,
    required double interestRate,
    required InterestType interestType,
    required DateTime loanDate,
    required DateTime dueDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return Loan(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      loanAmount: loanAmount,
      interestRate: interestRate,
      interestTypeName: interestType.name,
      loanDate: loanDate,
      dueDate: dueDate,
      statusName: LoanStatus.active.name,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── Helpers ───────────────────────────────────────────

  static int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  Loan copyWith({
    double? loanAmount,
    double? interestRate,
    DateTime? dueDate,
    LoanStatus? status,
    String? notes,
    double? totalPaid,
  }) {
    return Loan(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      loanAmount: loanAmount ?? this.loanAmount,
      interestRate: interestRate ?? this.interestRate,
      interestTypeName: interestTypeName,
      loanDate: loanDate,
      dueDate: dueDate ?? this.dueDate,
      statusName: status?.name ?? statusName,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      totalPaid: totalPaid ?? this.totalPaid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'customerId': customerId,
      'loanAmount': loanAmount,
      'interestRate': interestRate,
      'interestTypeName': interestTypeName,
      'loanDate': loanDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'statusName': statusName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalPaid': totalPaid,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String? ?? 'default',
      customerId: map['customerId'] as String,
      loanAmount: (map['loanAmount'] as num).toDouble(),
      interestRate: (map['interestRate'] as num).toDouble(),
      interestTypeName: map['interestTypeName'] as String,
      loanDate: DateTime.parse(map['loanDate'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      statusName: map['statusName'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      totalPaid: (map['totalPaid'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
