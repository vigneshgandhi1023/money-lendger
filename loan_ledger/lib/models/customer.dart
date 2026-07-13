import 'package:hive/hive.dart';

part 'customer.g.dart';

/// Represents a borrower/customer in the lending system.
///
/// Each customer can have multiple [Loan]s associated with them.
/// The model stores personal information and is linked to loans
/// and payments via [id].
@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(9)
  final String tenantId;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String phoneNumber;

  @HiveField(3)
  String? address;

  @HiveField(4)
  String? photoPath;

  @HiveField(5)
  String? idProofPath;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.phoneNumber,
    this.address,
    this.photoPath,
    this.idProofPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new customer with auto-generated timestamps.
  factory Customer.create({
    required String id,
    required String tenantId,
    required String fullName,
    required String phoneNumber,
    String? address,
    String? photoPath,
    String? idProofPath,
    String? notes,
  }) {
    final now = DateTime.now();
    return Customer(
      id: id,
      tenantId: tenantId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      photoPath: photoPath,
      idProofPath: idProofPath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns the initials for avatar display (e.g., "John Doe" → "JD").
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Creates a copy with updated fields.
  Customer copyWith({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? photoPath,
    String? idProofPath,
    String? notes,
  }) {
    return Customer(
      id: id,
      tenantId: tenantId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      idProofPath: idProofPath ?? this.idProofPath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to Map for Firebase sync.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoPath': photoPath,
      'idProofPath': idProofPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firebase document.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String? ?? 'default',
      fullName: map['fullName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      address: map['address'] as String?,
      photoPath: map['photoPath'] as String?,
      idProofPath: map['idProofPath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
