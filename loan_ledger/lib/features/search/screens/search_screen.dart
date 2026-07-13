import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../customers/widgets/customer_card.dart';
import '../providers/search_providers.dart';

/// Full-screen search overlay.
///
/// Provides instant search by customer name or phone number
/// with debounced input and animated results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          onPressed: () {
            ref.read(searchQueryProvider.notifier).state = '';
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
              vertical: 8,
            ),
            child: AppSearchBar(
              controller: _controller,
              autofocus: true,
              hint: 'Search by name or phone number...',
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Results
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Type to search customers',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No results found',
                        subtitle: 'Try a different name or phone number',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.horizontalPadding,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final customer = results[index];
                          final totalBorrowed =
                              StorageService.totalBorrowedByCustomer(
                                  customer.id);
                          final totalPaid =
                              StorageService.totalPaidByCustomer(customer.id);
                          final activeLoans =
                              StorageService.getLoansForCustomer(customer.id)
                                  .where((l) => l.statusName != 'closed')
                                  .length;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CustomerCard(
                              customer: customer,
                              totalBorrowed: totalBorrowed,
                              totalPaid: totalPaid,
                              activeLoans: activeLoans,
                              onTap: () {
                                ref.read(searchQueryProvider.notifier).state = '';
                                context.push('/customers/${customer.id}');
                              },
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 200.ms,
                                delay: Duration(milliseconds: index * 30),
                              )
                              .slideY(begin: 0.03, end: 0, duration: 200.ms);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
