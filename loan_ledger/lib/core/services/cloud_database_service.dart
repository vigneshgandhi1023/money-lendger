import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../models/payment.dart';
import 'cloud_auth_service.dart';

/// Provider for the CloudDatabaseService instance.
final cloudDatabaseProvider = Provider<CloudDatabaseService>((ref) {
  final user = ref.watch(currentUserProvider);
  return CloudDatabaseService(FirebaseFirestore.instance, user?.uid);
});

/// A service to interact with Cloud Firestore for a SaaS environment.
///
/// All queries and writes are scoped to the current user's [tenantId] (their UID).
class CloudDatabaseService {
  final FirebaseFirestore _firestore;
  final String? _tenantId;

  CloudDatabaseService(this._firestore, this._tenantId);

  String get tenantId {
    if (_tenantId == null) throw Exception('User not authenticated');
    return _tenantId;
  }

  // ─── Collections ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _customersRef =>
      _firestore.collection('customers');
  CollectionReference<Map<String, dynamic>> get _loansRef =>
      _firestore.collection('loans');
  CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection('payments');

  // ─── Customers ─────────────────────────────────────────

  /// Get all customers for the current tenant.
  Stream<List<Customer>> getCustomers() {
    if (_tenantId == null) return Stream.value([]);
    return _customersRef
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromMap(doc.data()))
            .toList());
  }

  /// Get a single customer by ID.
  Stream<Customer?> getCustomer(String id) {
    if (_tenantId == null) return Stream.value(null);
    return _customersRef.doc(id).snapshots().map((doc) =>
        doc.exists ? Customer.fromMap(doc.data()!) : null);
  }

  /// Save or update a customer.
  Future<void> saveCustomer(Customer customer) async {
    // Ensure the customer belongs to the current tenant
    if (customer.tenantId != tenantId) {
      throw Exception('Unauthorized to save customer for another tenant');
    }
    await _customersRef.doc(customer.id).set(customer.toMap());
  }

  /// Delete a customer.
  Future<void> deleteCustomer(String id) async {
    // Also need to delete associated loans and payments?
    // In a real SaaS, maybe soft-delete, but we'll do hard delete here.
    final batch = _firestore.batch();
    batch.delete(_customersRef.doc(id));

    // Get all loans for this customer
    final loansSnapshot = await _loansRef
        .where('tenantId', isEqualTo: tenantId)
        .where('customerId', isEqualTo: id)
        .get();
    
    for (final doc in loansSnapshot.docs) {
      batch.delete(doc.reference);
      // Get payments for this loan
      final paymentsSnapshot = await _paymentsRef
          .where('tenantId', isEqualTo: tenantId)
          .where('loanId', isEqualTo: doc.id)
          .get();
      for (final pDoc in paymentsSnapshot.docs) {
        batch.delete(pDoc.reference);
      }
    }

    await batch.commit();
  }

  // ─── Loans ─────────────────────────────────────────────

  /// Get all loans for the current tenant.
  Stream<List<Loan>> getLoans() {
    if (_tenantId == null) return Stream.value([]);
    return _loansRef
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Loan.fromMap(doc.data())).toList());
  }

  /// Get loans for a specific customer.
  Stream<List<Loan>> getLoansForCustomer(String customerId) {
    if (_tenantId == null) return Stream.value([]);
    return _loansRef
        .where('tenantId', isEqualTo: tenantId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Loan.fromMap(doc.data())).toList());
  }

  /// Save or update a loan.
  Future<void> saveLoan(Loan loan) async {
    if (loan.tenantId != tenantId) {
      throw Exception('Unauthorized to save loan for another tenant');
    }
    await _loansRef.doc(loan.id).set(loan.toMap());
  }

  // ─── Payments ──────────────────────────────────────────

  /// Get all payments for the current tenant.
  Stream<List<Payment>> getPayments() {
    if (_tenantId == null) return Stream.value([]);
    return _paymentsRef
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromMap(doc.data())).toList());
  }

  /// Get payments for a specific loan.
  Stream<List<Payment>> getPaymentsForLoan(String loanId) {
    if (_tenantId == null) return Stream.value([]);
    return _paymentsRef
        .where('tenantId', isEqualTo: tenantId)
        .where('loanId', isEqualTo: loanId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromMap(doc.data())).toList());
  }

  /// Get payments for a specific customer.
  Stream<List<Payment>> getPaymentsForCustomer(String customerId) {
    if (_tenantId == null) return Stream.value([]);
    return _paymentsRef
        .where('tenantId', isEqualTo: tenantId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromMap(doc.data())).toList());
  }

  /// Save a payment.
  Future<void> savePayment(Payment payment) async {
    if (payment.tenantId != tenantId) {
      throw Exception('Unauthorized to save payment for another tenant');
    }
    
    final batch = _firestore.batch();
    
    // Save the payment
    batch.set(_paymentsRef.doc(payment.id), payment.toMap());
    
    // Update the loan's totalPaid
    final loanDoc = await _loansRef.doc(payment.loanId).get();
    if (loanDoc.exists) {
      final loan = Loan.fromMap(loanDoc.data()!);
      final newTotalPaid = loan.totalPaid + payment.amount;
      batch.update(loanDoc.reference, {'totalPaid': newTotalPaid});
    }

    await batch.commit();
  }
}
