import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/customer.dart';

/// Search query state.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider — instant results from Hive.
final searchResultsProvider = Provider<List<Customer>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  return StorageService.searchCustomers(query.trim());
});
