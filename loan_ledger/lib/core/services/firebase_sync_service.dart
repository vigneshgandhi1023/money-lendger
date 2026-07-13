// Firebase sync service — optional cloud backup via Firestore.
//
// The app works fully offline with Hive local storage.
// This service provides optional sync when Firebase is configured.
// Uncomment and configure after adding google-services.json.

/*
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../models/payment.dart';
import 'storage_service.dart';

/// Optional Firebase Firestore sync service.
///
/// Syncs local Hive data to Firestore for cloud backup.
/// Uses a simple last-write-wins conflict resolution strategy.
class FirebaseSyncService {
  FirebaseSyncService._();

  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference get _customersRef =>
      _firestore.collection('customers');
  static CollectionReference get _loansRef =>
      _firestore.collection('loans');
  static CollectionReference get _paymentsRef =>
      _firestore.collection('payments');

  /// Sync all local data to Firestore.
  static Future<void> syncToCloud() async {
    await _syncCustomers();
    await _syncLoans();
    await _syncPayments();

    await StorageService.setSetting('last_sync', DateTime.now().toIso8601String());
  }

  /// Pull data from Firestore to local.
  static Future<void> syncFromCloud() async {
    await _pullCustomers();
    await _pullLoans();
    await _pullPayments();
  }

  // ─── Customers ─────────────────────────────────────────

  static Future<void> _syncCustomers() async {
    final customers = StorageService.getAllCustomers();
    final batch = _firestore.batch();
    for (final customer in customers) {
      batch.set(_customersRef.doc(customer.id), customer.toMap());
    }
    await batch.commit();
  }

  static Future<void> _pullCustomers() async {
    final snapshot = await _customersRef.get();
    for (final doc in snapshot.docs) {
      final customer = Customer.fromMap(doc.data() as Map<String, dynamic>);
      await StorageService.saveCustomer(customer);
    }
  }

  // ─── Loans ─────────────────────────────────────────────

  static Future<void> _syncLoans() async {
    final loans = StorageService.getAllLoans();
    final batch = _firestore.batch();
    for (final loan in loans) {
      batch.set(_loansRef.doc(loan.id), loan.toMap());
    }
    await batch.commit();
  }

  static Future<void> _pullLoans() async {
    final snapshot = await _loansRef.get();
    for (final doc in snapshot.docs) {
      final loan = Loan.fromMap(doc.data() as Map<String, dynamic>);
      await StorageService.saveLoan(loan);
    }
  }

  // ─── Payments ──────────────────────────────────────────

  static Future<void> _syncPayments() async {
    final payments = StorageService.getAllPayments();
    final batch = _firestore.batch();
    for (final payment in payments) {
      batch.set(_paymentsRef.doc(payment.id), payment.toMap());
    }
    await batch.commit();
  }

  static Future<void> _pullPayments() async {
    final snapshot = await _paymentsRef.get();
    for (final doc in snapshot.docs) {
      final payment = Payment.fromMap(doc.data() as Map<String, dynamic>);
      await StorageService.savePayment(payment);
    }
  }
}
*/

/// Placeholder — Firebase sync is available after configuring Firebase.
/// See README.md for setup instructions.
class FirebaseSyncService {
  FirebaseSyncService._();

  static Future<void> syncToCloud() async {
    // Firebase not configured. Enable by:
    // 1. Adding google-services.json
    // 2. Uncommenting Firebase.initializeApp() in main.dart
    // 3. Uncommenting the sync code above
  }

  static Future<void> syncFromCloud() async {
    // Firebase not configured.
  }
}
