import 'package:hive/hive.dart';

import 'enums.dart';

part 'payment.g.dart';

/// Represents a payment received against a loan.
///
/// Payments are linked to both a [Loan] and a [Customer] via their IDs.
/// Each payment records the amount, date, type (partial/full), and notes.
@HiveType(typeId: 2)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(8)
  final String tenantId;

  @HiveField(1)
  final String loanId;

  @HiveField(2)
  final String customerId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime paymentDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  final String paymentTypeName;

  @HiveField(7)
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.loanId,
    required this.customerId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.paymentTypeName,
    required this.createdAt,
  });

  PaymentType get paymentType =>
      PaymentType.values.firstWhere((e) => e.name == paymentTypeName);

  factory Payment.create({
    required String id,
    required String tenantId,
    required String loanId,
    required String customerId,
    required double amount,
    required DateTime paymentDate,
    required PaymentType paymentType,
    String? notes,
  }) {
    return Payment(
      id: id,
      tenantId: tenantId,
      loanId: loanId,
      customerId: customerId,
      amount: amount,
      paymentDate: paymentDate,
      notes: notes,
      paymentTypeName: paymentType.name,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'loanId': loanId,
      'customerId': customerId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'paymentTypeName': paymentTypeName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String? ?? 'default',
      loanId: map['loanId'] as String,
      customerId: map['customerId'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      notes: map['notes'] as String?,
      paymentTypeName: map['paymentTypeName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
